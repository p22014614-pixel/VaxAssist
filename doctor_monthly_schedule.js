// Renders the selected month of the signed-in doctor's working days, leave, and bookings.
(() => {
    const title = document.getElementById('monthTitle');
    const grid = document.getElementById('monthlyScheduleGrid');
    const status = document.getElementById('monthlyScheduleStatus');
    const dayTitle = document.getElementById('dailyScheduleTitle');
    const dayStatus = document.getElementById('dailyScheduleStatus');
    const daySlots = document.getElementById('dailyScheduleSlots');
    const dayModalElement = document.getElementById('dailyScheduleModal');
    const pickerModalElement = document.getElementById('monthYearPickerModal');
    const pickerInput = document.getElementById('monthYearPickerInput');
    let activeDay = '';
    let visibleMonth = new Date();

    const hourlySlots = [
        ['08:00', '8:00 AM'], ['09:00', '9:00 AM'], ['10:00', '10:00 AM'],
        ['11:00', '11:00 AM'], ['12:00', '12:00 PM'], ['14:00', '2:00 PM'],
        ['15:00', '3:00 PM'], ['16:00', '4:00 PM'], ['17:00', '5:00 PM'],
    ];

    // Formats calendar dates without changing the date through timezone conversion.
    function dateLabel(year, month, day) {
        return new Intl.DateTimeFormat(undefined, { dateStyle: 'medium' }).format(new Date(year, month, day, 12));
    }

    // Shows load errors in the schedule panel.
    function showStatus(message, error = false) {
        status.textContent = message;
        status.hidden = !message;
        status.classList.toggle('is-error', error);
        status.classList.toggle('is-success', Boolean(message) && !error);
    }

    // Builds the month grid from the doctor's schedule endpoint.
    function renderMonth(data) {
        const year = Number(data.year);
        const month = Number(data.month) - 1;
        title.replaceChildren(document.createTextNode(new Intl.DateTimeFormat(undefined, { month: 'long', year: 'numeric' }).format(new Date(year, month, 1, 12))));
        const pickerIcon = document.createElement('i');
        pickerIcon.className = 'bi bi-chevron-down';
        pickerIcon.setAttribute('aria-hidden', 'true');
        title.append(' ', pickerIcon);
        grid.replaceChildren();
        const firstWeekday = (new Date(year, month, 1).getDay() + 6) % 7;
        const daysInMonth = new Date(year, month + 1, 0).getDate();
        const appointmentsByDate = new Map();
        (data.appointments || []).forEach((appointment) => {
            const entries = appointmentsByDate.get(appointment.appointment_date) || [];
            entries.push(appointment);
            appointmentsByDate.set(appointment.appointment_date, entries);
        });
        const leaves = data.approved_leave || [];
        const availability = new Set((data.availability_weekdays || []).map(Number));
        const today = new Date();
        for (let index = 0; index < firstWeekday; index += 1) {
            const blank = document.createElement('div');
            blank.className = 'monthly-calendar-day is-empty';
            blank.setAttribute('aria-hidden', 'true');
            grid.append(blank);
        }
        for (let day = 1; day <= daysInMonth; day += 1) {
            const date = new Date(year, month, day, 12);
            const isoDate = `${year}-${String(month + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
            const weekday = date.getDay() === 0 ? 7 : date.getDay();
            const dayAppointments = appointmentsByDate.get(isoDate) || [];
            const bookingCount = dayAppointments.filter((appointment) => appointment.status === 'Scheduled').length;
            const dayLeaves = leaves.filter((leave) => isoDate >= leave.start_date && isoDate <= leave.end_date);
            const cell = document.createElement('article');
            cell.className = 'monthly-calendar-day';
            if (availability.has(weekday)) cell.classList.add('is-working-day');
            if (dayLeaves.length) cell.classList.add('has-approved-leave');
            if (date.toDateString() === today.toDateString()) cell.classList.add('is-today');
            const heading = document.createElement('div');
            heading.className = 'monthly-day-heading';
            const dayNumber = document.createElement('strong');
            dayNumber.textContent = String(day);
            const dayLabel = document.createElement('time');
            dayLabel.dateTime = isoDate;
            dayLabel.textContent = dateLabel(year, month, day);
            heading.append(dayNumber, dayLabel);
            cell.append(heading);
            if (availability.has(weekday)) {
                const working = document.createElement('small');
                working.className = 'monthly-day-tag is-working';
                working.textContent = 'Working day';
                cell.append(working);
            }
            if (bookingCount > 0) {
                const bookingTag = document.createElement('button');
                bookingTag.type = 'button';
                bookingTag.className = 'monthly-day-booking-count';
                bookingTag.textContent = `${bookingCount} ${bookingCount === 1 ? 'booking' : 'bookings'}`;
                bookingTag.dataset.openDay = isoDate;
                bookingTag.setAttribute('aria-label', `View ${bookingTag.textContent} on ${dateLabel(year, month, day)}`);
                cell.append(bookingTag);
            }
            dayLeaves.forEach((leave) => {
                const leaveTag = document.createElement('small');
                leaveTag.className = 'monthly-day-tag is-leave';
                leaveTag.textContent = leave.reason ? `Approved leave · ${leave.reason}` : 'Approved leave';
                cell.append(leaveTag);
            });
            if (!availability.has(weekday) && !dayLeaves.length && !dayAppointments.length) {
                const off = document.createElement('small');
                off.className = 'monthly-day-off';
                off.textContent = 'No schedule';
                cell.append(off);
            }
            grid.append(cell);
        }
    }

    // Fetches monthly schedule data for the selected month.
    async function loadMonth() {
        showStatus('');
        grid.replaceChildren();
        const year = visibleMonth.getFullYear();
        const month = visibleMonth.getMonth() + 1;
        try {
            const data = await VaxApi.get(`doctor_monthly_schedule_backend.php?year=${year}&month=${month}`);
            if (data.status !== 'success') throw new Error(data.message || 'Could not load the monthly schedule.');
            renderMonth(data);
        } catch (error) {
            title.textContent = 'Schedule unavailable';
            showStatus(error.message || 'Could not load the monthly schedule.', true);
        }
    }

    // Formats a stored 24-hour time for the day schedule.
    function clockLabel(value) {
        if (!value || value.length < 5) return 'Time not set';
        return new Intl.DateTimeFormat(undefined, { hour: 'numeric', minute: '2-digit' }).format(new Date(`2000-01-01T${value.slice(0, 5)}:00`));
    }

    // Creates a patient row with record and completion actions.
    function bookingRow(booking) {
        const row = document.createElement('div');
        row.className = 'appointment-booking-row';
        if (booking.appointment_time) {
            const time = document.createElement('time');
            time.className = 'appointment-booking-time';
            time.textContent = clockLabel(booking.appointment_time);
            row.append(time);
        }
        const name = document.createElement('strong');
        name.textContent = booking.name;
        const reason = document.createElement('span');
        reason.className = 'appointment-booking-reason';
        reason.textContent = `— ${booking.reason || 'No visit notes'}`;
        const actions = document.createElement('span');
        actions.className = 'appointment-actions';
        const record = document.createElement('a');
        record.className = 'btn secondary-btn btn-sm';
        record.textContent = 'Patient file';
        record.href = `doctor_patientRecord.html?search=${encodeURIComponent(booking.name)}&patient_id=${encodeURIComponent(booking.patient_id)}&open=history`;
        const complete = document.createElement('button');
        complete.type = 'button';
        complete.className = 'btn primary-btn btn-sm';
        complete.textContent = 'Complete appointment';
        complete.dataset.completeAppointment = String(booking.appointment_id);
        actions.append(record, complete);
        row.append(name, reason, actions);
        return row;
    }

    // Renders the same hourly slots for a selected day that were shown in the former week view.
    function renderDaySchedule(data) {
        const appointments = data.data || {};
        daySlots.replaceChildren();
        const knownHours = new Set(hourlySlots.map(([key]) => key));
        const appendSlot = (key, label, bookings) => {
            const card = document.createElement('article');
            card.className = 'time-slot-card appointment-hour-card';
            const time = document.createElement('time');
            time.className = 'appointment-hour-label';
            time.textContent = label;
            const details = document.createElement('div');
            details.className = 'slot-details';
            if (bookings?.length) details.replaceChildren(...bookings.map(bookingRow));
            else {
                const available = document.createElement('span');
                available.className = 'appointment-slot-empty';
                available.textContent = 'Available';
                details.append(available);
            }
            card.append(time, details);
            daySlots.append(card);
        };
        hourlySlots.forEach(([key, label]) => appendSlot(key, label, appointments[key] || []));
        Object.keys(appointments).filter((key) => !knownHours.has(key)).sort().forEach((key) => {
            appendSlot(key, key === 'other' ? 'Other time' : clockLabel(key), appointments[key]);
        });
    }

    // Loads the selected date's bookings into the day schedule dialog.
    async function loadDaySchedule(date) {
        activeDay = date;
        const dateObject = new Date(`${date}T12:00:00`);
        dayTitle.textContent = new Intl.DateTimeFormat(undefined, { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' }).format(dateObject);
        dayStatus.hidden = true;
        dayStatus.classList.remove('is-success', 'is-error');
        daySlots.replaceChildren();
        const loading = document.createElement('p');
        loading.className = 'text-muted';
        loading.textContent = 'Loading this day’s appointments…';
        daySlots.append(loading);
        try {
            const data = await VaxApi.get(`doctor_appointments_backend.php?action=get_day&date=${encodeURIComponent(date)}`);
            if (data.status !== 'success') throw new Error(data.message || 'Could not load this day’s appointments.');
            renderDaySchedule(data);
        } catch (error) {
            daySlots.replaceChildren();
            dayStatus.textContent = error.message || 'Could not load this day’s appointments.';
            dayStatus.hidden = false;
            dayStatus.classList.add('is-error');
        }
    }

    grid.addEventListener('click', async (event) => {
        const button = event.target.closest('[data-open-day]');
        if (!button) return;
        window.bootstrap?.Modal.getOrCreateInstance(dayModalElement).show();
        loadDaySchedule(button.dataset.openDay);
    });

    document.getElementById('monthTitle').addEventListener('click', () => {
        pickerInput.value = `${visibleMonth.getFullYear()}-${String(visibleMonth.getMonth() + 1).padStart(2, '0')}`;
        window.bootstrap?.Modal.getOrCreateInstance(pickerModalElement).show();
    });

    document.getElementById('monthYearPickerForm').addEventListener('submit', (event) => {
        event.preventDefault();
        const match = pickerInput.value.match(/^(\d{4})-(\d{2})$/);
        if (!match) return;
        visibleMonth = new Date(Number(match[1]), Number(match[2]) - 1, 1);
        window.bootstrap?.Modal.getOrCreateInstance(pickerModalElement).hide();
        loadMonth();
    });

    document.addEventListener('click', async (event) => {
        const button = event.target.closest('[data-complete-appointment]');
        if (!button) return;
        if (!window.confirm('Mark this appointment as completed?')) return;
        button.disabled = true;
        const actionStatus = document.getElementById('appointment-action-status');
        actionStatus.hidden = true;
        actionStatus.classList.remove('is-success', 'is-error');
        try {
            const result = await VaxApi.post('doctor_appointments_backend.php?action=complete', {
                appointment_id: Number(button.dataset.completeAppointment),
            });
            if (result.status !== 'success') throw new Error(result.message || 'Could not complete appointment.');
            actionStatus.textContent = result.message;
            actionStatus.classList.add('is-success');
            actionStatus.hidden = false;
            await Promise.all([loadMonth(), loadDaySchedule(activeDay)]);
            dayStatus.textContent = result.message;
            dayStatus.classList.remove('is-error');
            dayStatus.classList.add('is-success');
            dayStatus.hidden = false;
        } catch (error) {
            const message = error.message || 'Could not complete appointment. Please try again.';
            actionStatus.textContent = message;
            actionStatus.classList.add('is-error');
            actionStatus.hidden = false;
            dayStatus.textContent = message;
            dayStatus.classList.add('is-error');
            dayStatus.hidden = false;
            button.disabled = false;
        }
    });

    document.getElementById('previousMonth').addEventListener('click', () => { visibleMonth = new Date(visibleMonth.getFullYear(), visibleMonth.getMonth() - 1, 1); loadMonth(); });
    document.getElementById('nextMonth').addEventListener('click', () => { visibleMonth = new Date(visibleMonth.getFullYear(), visibleMonth.getMonth() + 1, 1); loadMonth(); });
    document.addEventListener('DOMContentLoaded', loadMonth);
})();
