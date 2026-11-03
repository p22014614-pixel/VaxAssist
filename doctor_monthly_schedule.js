// Renders the selected month of the signed-in doctor's working days, leave, and bookings.
(() => {
    const title = document.getElementById('monthTitle');
    const grid = document.getElementById('monthlyScheduleGrid');
    const status = document.getElementById('monthlyScheduleStatus');
    let visibleMonth = new Date();

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

    // Creates a text-only appointment entry for one day.
    function appointmentNode(appointment) {
        const item = document.createElement('div');
        item.className = `monthly-appointment is-${String(appointment.status).toLowerCase()}`;
        const time = document.createElement('strong');
        time.textContent = appointment.appointment_time ? String(appointment.appointment_time).slice(0, 5) : appointment.time_slot;
        const patient = document.createElement('span');
        patient.textContent = appointment.full_name;
        const vaccine = document.createElement('small');
        vaccine.textContent = appointment.vaccine_name || appointment.status;
        item.append(time, patient, vaccine);
        return item;
    }

    // Builds the month grid from the doctor's schedule endpoint.
    function renderMonth(data) {
        const year = Number(data.year);
        const month = Number(data.month) - 1;
        title.textContent = new Intl.DateTimeFormat(undefined, { month: 'long', year: 'numeric' }).format(new Date(year, month, 1, 12));
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
                const bookingTag = document.createElement('small');
                bookingTag.className = 'monthly-day-booking-count';
                bookingTag.textContent = `${bookingCount} ${bookingCount === 1 ? 'booking' : 'bookings'}`;
                cell.append(bookingTag);
            }
            dayLeaves.forEach((leave) => {
                const leaveTag = document.createElement('small');
                leaveTag.className = 'monthly-day-tag is-leave';
                leaveTag.textContent = leave.reason ? `Approved leave · ${leave.reason}` : 'Approved leave';
                cell.append(leaveTag);
            });
            dayAppointments.forEach((appointment) => cell.append(appointmentNode(appointment)));
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

    document.getElementById('previousMonth').addEventListener('click', () => { visibleMonth = new Date(visibleMonth.getFullYear(), visibleMonth.getMonth() - 1, 1); loadMonth(); });
    document.getElementById('nextMonth').addEventListener('click', () => { visibleMonth = new Date(visibleMonth.getFullYear(), visibleMonth.getMonth() + 1, 1); loadMonth(); });
    document.getElementById('currentMonth').addEventListener('click', () => { visibleMonth = new Date(); loadMonth(); });
    document.addEventListener('DOMContentLoaded', loadMonth);
})();
