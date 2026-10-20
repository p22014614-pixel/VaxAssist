async function getCurrentUser() {
    return VaxAuth.getUser();
}

async function getDoctors() {
    return [
        { id: 1, name: 'Dr. Aisha Rahman', specialty: 'Travel Medicine',     days: [1, 3, 5] },
        { id: 2, name: 'Dr. Daniel Lim',   specialty: 'Paediatrics',         days: [1, 2, 4] },
        { id: 3, name: 'Dr. Priya Nair',   specialty: 'General Practice',    days: [1, 2, 3, 4, 5] },
        { id: 4, name: 'Dr. Ahmad Farid',  specialty: 'Internal Medicine',   days: [2, 3, 5] },
        { id: 5, name: 'Dr. Mei Ling Tan', specialty: 'Infectious Diseases', days: [2, 4] },
        { id: 6, name: 'Dr. Rajesh Kumar', specialty: 'Preventive Medicine', days: [1, 3] },
        { id: 7, name: 'Dr. Siti Aminah',  specialty: 'Paediatrics',         days: [3, 4, 5] },
        { id: 8, name: 'Dr. Jason Wong',   specialty: 'General Practice',    days: [1, 2, 3, 4, 5] }
    ];
}

async function getAppointments() {
    return [
        { id: 1042, doctor_id: 1, doctor_name: 'Dr. Aisha Rahman', specialty: 'Travel Medicine', vaccine_name: 'Yellow Fever',
          appointment_date: workingDayFrom(3, [1, 3, 5]), appointment_time: '10:00', patient_type: 'self', child_name: '',
          notes: 'Travelling to Ghana next month.', status: 'booked' },
        { id: 1043, doctor_id: 2, doctor_name: 'Dr. Daniel Lim', specialty: 'Paediatrics', vaccine_name: 'MMR',
          appointment_date: workingDayFrom(9, [1, 2, 4]), appointment_time: '14:30', patient_type: 'child', child_name: 'Aiden',
          notes: '', status: 'booked' },
        { id: 1044, doctor_id: 3, doctor_name: 'Dr. Priya Nair', specialty: 'General Practice', vaccine_name: 'Influenza',
          appointment_date: workingDayFrom(20, [1, 2, 3, 4, 5]), appointment_time: '09:30', patient_type: 'self', child_name: '',
          notes: '', status: 'booked' },
        { id: 1031, doctor_id: 1, doctor_name: 'Dr. Aisha Rahman', specialty: 'Travel Medicine', vaccine_name: 'Typhoid',
          appointment_date: daysFromToday(-12), appointment_time: '11:00', patient_type: 'self', child_name: '',
          notes: '', status: 'completed' },
        { id: 1027, doctor_id: 7, doctor_name: 'Dr. Siti Aminah', specialty: 'Paediatrics', vaccine_name: 'DTaP-IPV-Hib',
          appointment_date: daysFromToday(-30), appointment_time: '15:00', patient_type: 'child', child_name: 'Aiden',
          notes: '', status: 'completed' },
        { id: 1022, doctor_id: 8, doctor_name: 'Dr. Jason Wong', specialty: 'General Practice', vaccine_name: 'Hepatitis A',
          appointment_date: daysFromToday(-41), appointment_time: '10:30', patient_type: 'self', child_name: '',
          notes: '', status: 'cancelled' },
        { id: 1015, doctor_id: 3, doctor_name: 'Dr. Priya Nair', specialty: 'General Practice', vaccine_name: 'Td Booster',
          appointment_date: daysFromToday(-60), appointment_time: '16:00', patient_type: 'self', child_name: '',
          notes: '', status: 'missed' }
    ];
}

async function getAvailableSlots(doctorId, date) {
    const doctor = (await getDoctors()).find(function (d) { return d.id === doctorId; });
    const day = parseISO(date);
    if (!doctor || doctor.days.indexOf(day.getDay()) === -1) return [];

    const times = [];
    for (let h = 9; h < 17; h++) {
        if (h === 13) continue;                       // lunch break
        times.push(pad(h) + ':00', pad(h) + ':30');
    }
    const now = new Date();
    const isToday = day.toDateString() === now.toDateString();
    return times.map(function (t, i) {
        const taken = ((doctorId * 7 + day.getDate() * 3 + i * 5) % 4) === 0;   // demo only
        const hm = t.split(':').map(Number);
        const passed = isToday && (hm[0] * 60 + hm[1]) < (now.getHours() * 60 + now.getMinutes() + 60);
        return { time: t, available: !taken && !passed };
    });
}

async function rescheduleAppointment(id, date, time) {
    return { ok: true };
}

async function cancelAppointment(id, reason) {
    return { ok: true };
}

const upcomingList = document.getElementById('upcomingList');
const historyList = document.getElementById('historyList');
const tabUpcoming = document.getElementById('tabUpcoming');
const tabHistory = document.getElementById('tabHistory');
const pageAlert = document.getElementById('pageAlert');

const rescheduleModal = new bootstrap.Modal(document.getElementById('rescheduleModal'));
const cancelModal = new bootstrap.Modal(document.getElementById('cancelModal'));
const newDate = document.getElementById('newDate');
const newSlotGrid = document.getElementById('newSlotGrid');
const newSlotMessage = document.getElementById('newSlotMessage');
const confirmRescheduleBtn = document.getElementById('confirmReschedule');
const confirmCancelBtn = document.getElementById('confirmCancel');

const DAY_NAMES = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
const STATUS_TEXT = { booked: 'Booked', completed: 'Completed', cancelled: 'Cancelled', missed: 'Missed' };

let appointments = [];
let doctors = [];
let current = null;           // the appointment open in a modal

function pad(n) { return String(n).padStart(2, '0'); }

function esc(text) {
    const div = document.createElement('div');
    div.textContent = text == null ? '' : text;
    return div.innerHTML;
}

function isoDate(d) {
    return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate());
}

function parseISO(s) {
    const p = s.split('-').map(Number);
    return new Date(p[0], p[1] - 1, p[2]);
}

function daysFromToday(n) {
    const d = new Date();
    return isoDate(new Date(d.getFullYear(), d.getMonth(), d.getDate() + n));
}

function workingDayFrom(n, days) {
    const d = new Date();
    for (let i = n; i < n + 14; i++) {
        const check = new Date(d.getFullYear(), d.getMonth(), d.getDate() + i);
        if (days.indexOf(check.getDay()) !== -1) return isoDate(check);
    }
    return daysFromToday(n);
}

function timeText(t) {
    const p = t.split(':').map(Number);
    return ((p[0] % 12) || 12) + ':' + pad(p[1]) + ' ' + (p[0] < 12 ? 'AM' : 'PM');
}

function longDate(s) {
    return parseISO(s).toLocaleDateString('en-GB', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' });
}

function startOf(a) {
    const p = a.appointment_time.split(':').map(Number);
    const d = parseISO(a.appointment_date);
    d.setHours(p[0], p[1], 0, 0);
    return d;
}

function isUpcoming(a) {
    return a.status === 'booked' && startOf(a) > new Date();
}

function patientText(a) {
    return a.patient_type === 'child' ? a.child_name + ' (child)' : 'Myself';
}

function reference(a) {
    return 'VAX-' + String(a.id).padStart(5, '0');
}

function countdown(a) {
    const today = parseISO(daysFromToday(0));
    const diff = Math.round((parseISO(a.appointment_date) - today) / 86400000);
    if (diff === 0) return 'Today';
    if (diff === 1) return 'Tomorrow';
    return 'In ' + diff + ' days';
}

function showAlert(type, message) {
    pageAlert.className = 'alert-soft ' + type + ' mb-4';
    pageAlert.textContent = message;
    pageAlert.scrollIntoView({ behavior: 'smooth', block: 'center' });
}

function card(a, upcoming) {
    const d = parseISO(a.appointment_date);
    const actions = upcoming
        ? '<div class="appt-actions">' +
            '<button type="button" class="btn btn-sm btn-outline-secondary" data-action="reschedule" data-id="' + esc(a.id) + '">Reschedule</button>' +
            '<button type="button" class="btn btn-sm btn-cancel" data-action="cancel" data-id="' + esc(a.id) + '">Cancel</button>' +
          '</div>'
        : (a.status === 'completed'
            ? '<div class="appt-actions"><a class="btn btn-sm btn-outline-secondary" href="booking.html?doctor_id=' + encodeURIComponent(a.doctor_id) + '">Book again</a></div>'
            : '<div class="appt-actions"></div>');

    return '<div class="appt-card">' +
        '<div class="date-block">' +
            '<div class="month">' + d.toLocaleDateString('en-GB', { month: 'short' }) + '</div>' +
            '<div class="day">' + d.getDate() + '</div>' +
            '<div class="weekday">' + DAY_NAMES[d.getDay()].slice(0, 3) + '</div>' +
        '</div>' +
        '<div>' +
            '<div class="d-flex flex-wrap align-items-center gap-2 mb-1">' +
                '<span class="badge-soft status-' + esc(a.status) + '">' + esc(STATUS_TEXT[a.status] || a.status) + '</span>' +
                (upcoming ? '<span class="soon">' + esc(countdown(a)) + '</span>' : '') +
            '</div>' +
            '<h5>' + esc(a.vaccine_name) + '</h5>' +
            '<div class="appt-meta">' +
                esc(timeText(a.appointment_time)) + ' &middot; ' + esc(a.doctor_name) + ' (' + esc(a.specialty) + ')<br>' +
                'For: ' + esc(patientText(a)) + ' &middot; Ref ' + esc(reference(a)) +
                (a.notes ? '<br>Notes: ' + esc(a.notes) : '') +
            '</div>' +
        '</div>' +
        actions +
    '</div>';
}

function render() {
    const upcoming = appointments.filter(isUpcoming).sort(function (a, b) { return startOf(a) - startOf(b); });
    const history = appointments.filter(function (a) { return !isUpcoming(a); }).sort(function (a, b) { return startOf(b) - startOf(a); });

    document.getElementById('countUpcoming').textContent = upcoming.length;
    document.getElementById('countHistory').textContent = history.length;

    upcomingList.innerHTML = upcoming.length
        ? upcoming.map(function (a) { return card(a, true); }).join('')
        : '<div class="empty-state"><div class="icon">&#128197;</div>You have no upcoming appointments.<br>' +
          '<a href="booking.html" class="btn appointment-btn mt-3">Book an appointment</a></div>';

    historyList.innerHTML = history.length
        ? history.map(function (a) { return card(a, false); }).join('')
        : '<div class="empty-state"><div class="icon">&#128203;</div>Your past and cancelled appointments will appear here.</div>';
}

function showTab(which) {
    const up = which === 'upcoming';
    tabUpcoming.classList.toggle('active', up);
    tabHistory.classList.toggle('active', !up);
    tabUpcoming.setAttribute('aria-selected', up);
    tabHistory.setAttribute('aria-selected', !up);
    upcomingList.classList.toggle('d-none', !up);
    historyList.classList.toggle('d-none', up);
}
tabUpcoming.addEventListener('click', function () { showTab('upcoming'); });
tabHistory.addEventListener('click', function () { showTab('history'); });

upcomingList.addEventListener('click', function (e) {
    const btn = e.target.closest('button[data-action]');
    if (!btn) return;
    current = appointments.find(function (a) { return String(a.id) === btn.dataset.id; });
    if (!current) return;
    if (btn.dataset.action === 'reschedule') openReschedule();
    if (btn.dataset.action === 'cancel') openCancel();
});

function summaryHtml(a) {
    return '<strong>' + esc(a.vaccine_name) + '</strong> with ' + esc(a.doctor_name) + '<br>' +
        esc(longDate(a.appointment_date)) + ', ' + esc(timeText(a.appointment_time)) + '<br>' +
        'For: ' + esc(patientText(a));
}

function selectedNewTime() {
    const checked = newSlotGrid.querySelector('input[name="appointment_time"]:checked');
    return checked ? checked.value : '';
}

async function loadNewSlots() {
    newSlotGrid.innerHTML = '';
    confirmRescheduleBtn.disabled = true;
    if (!newDate.value) {
        newSlotMessage.textContent = 'Choose a date to see available times.';
        return;
    }
    const slots = await getAvailableSlots(current.doctor_id, newDate.value);
    if (!slots.length) {
        newSlotMessage.textContent = current.doctor_name + ' does not work on ' + DAY_NAMES[parseISO(newDate.value).getDay()] + 's.';
        return;
    }
    const anyFree = slots.some(function (s) { return s.available; });
    newSlotMessage.textContent = anyFree ? '' : 'All times are taken on this date. Please try another day.';

    newSlotGrid.innerHTML = slots.map(function (s, i) {
        const same = newDate.value === current.appointment_date && s.time === current.appointment_time;
        const free = s.available && !same;
        return '<div><input type="radio" class="btn-check" name="appointment_time" id="newSlot' + i + '" value="' + esc(s.time) + '"' + (free ? '' : ' disabled') + '>' +
            '<label class="btn slot-label w-100" for="newSlot' + i + '">' + esc(timeText(s.time)) + '</label></div>';
    }).join('');
}

function openReschedule() {
    const doctor = doctors.find(function (d) { return d.id === current.doctor_id; });
    document.getElementById('currentSlot').innerHTML = '<small class="text-secondary">Currently booked</small><br>' + summaryHtml(current);
    document.getElementById('rescheduleError').classList.add('d-none');
    document.getElementById('newWorkingDays').textContent = doctor
        ? current.doctor_name + ' works: ' + doctor.days.map(function (n) { return DAY_NAMES[n].slice(0, 3); }).join(', ')
        : '';
    newDate.min = daysFromToday(0);
    newDate.max = daysFromToday(60);
    newDate.value = current.appointment_date;
    confirmRescheduleBtn.textContent = 'Confirm new time';
    loadNewSlots();
    rescheduleModal.show();
}

newDate.addEventListener('change', loadNewSlots);
newSlotGrid.addEventListener('change', function () { confirmRescheduleBtn.disabled = !selectedNewTime(); });

confirmRescheduleBtn.addEventListener('click', async function () {
    const time = selectedNewTime();
    const errorBox = document.getElementById('rescheduleError');
    if (!newDate.value || !time) return;
    if (newDate.value < daysFromToday(0) || newDate.value > daysFromToday(60)) {
        errorBox.textContent = 'Choose a date within the next 60 days.';
        errorBox.classList.remove('d-none');
        return;
    }
    confirmRescheduleBtn.disabled = true;
    confirmRescheduleBtn.textContent = 'Saving...';
    try {
        await rescheduleAppointment(current.id, newDate.value, time);
        current.appointment_date = newDate.value;
        current.appointment_time = time;
        rescheduleModal.hide();
        render();
        showTab('upcoming');
        showAlert('success', 'Your ' + current.vaccine_name + ' appointment is now on ' + longDate(current.appointment_date) + ' at ' + timeText(time) + '.');
    } catch (err) {
        errorBox.textContent = 'Sorry, we could not change your appointment. Please try again.';
        errorBox.classList.remove('d-none');
        confirmRescheduleBtn.disabled = false;
        confirmRescheduleBtn.textContent = 'Confirm new time';
    }
});

function openCancel() {
    document.getElementById('cancelSummary').innerHTML = summaryHtml(current);
    document.getElementById('cancelError').classList.add('d-none');
    document.getElementById('cancelReason').value = '';
    confirmCancelBtn.disabled = false;
    confirmCancelBtn.textContent = 'Yes, cancel it';
    cancelModal.show();
}

confirmCancelBtn.addEventListener('click', async function () {
    confirmCancelBtn.disabled = true;
    confirmCancelBtn.textContent = 'Cancelling...';
    try {
        await cancelAppointment(current.id, document.getElementById('cancelReason').value);
        current.status = 'cancelled';
        cancelModal.hide();
        render();
        showAlert('success', 'Your ' + current.vaccine_name + ' appointment has been cancelled. You can find it under History.');
    } catch (err) {
        const errorBox = document.getElementById('cancelError');
        errorBox.textContent = 'Sorry, we could not cancel your appointment. Please try again.';
        errorBox.classList.remove('d-none');
        confirmCancelBtn.disabled = false;
        confirmCancelBtn.textContent = 'Yes, cancel it';
    }
});

(async function init() {
    const user = await getCurrentUser();
    if (!user) {
        window.location.href = 'login.html?next=' + encodeURIComponent('appointments.html');
        return;
    }
    try {
        doctors = await getDoctors();
        appointments = await getAppointments();
        render();
        if (new URLSearchParams(window.location.search).get('tab') === 'history') showTab('history');
    } catch (err) {
        upcomingList.innerHTML = '<div class="empty-state">Sorry, we could not load your appointments. Please try again later.</div>';
    }
})();
