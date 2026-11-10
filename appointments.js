async function getCurrentUser() {
    return VaxAuth.fetchUser();
}

async function getDoctors() {
    return (await VaxApi.get('api/doctors')).doctors;
}

async function getAppointments() {
    return (await VaxApi.get('api/appointments')).appointments;
}

async function getAvailableSlots(doctorId, date, ignoreId) {
    return (await VaxApi.get('api/doctors/' + encodeURIComponent(doctorId) + '/slots?date=' + encodeURIComponent(date) +
        (ignoreId ? '&ignore=' + encodeURIComponent(ignoreId) : ''))).slots;
}

async function rescheduleAppointment(id, date, time) {
    return VaxApi.patch('api/appointments/' + encodeURIComponent(id), { date: date, time: time });
}

async function cancelAppointment(id, reason) {
    return VaxApi.patch('api/appointments/' + encodeURIComponent(id), { status: 'cancelled', reason: reason });
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
    const value = String(s || '').slice(0, 10);
    const p = value.split('-').map(Number);
    return new Date(p[0], p[1] - 1, p[2]);
}

function daysFromToday(n) {
    const d = new Date();
    return isoDate(new Date(d.getFullYear(), d.getMonth(), d.getDate() + n));
}

function timeText(t) {
    const match = String(t || '').match(/^(\d{1,2}):(\d{2})/);
    if (!match) return 'Time to be confirmed';
    const hour = Number(match[1]);
    const minute = Number(match[2]);
    return ((hour % 12) || 12) + ':' + pad(minute) + ' ' + (hour < 12 ? 'AM' : 'PM');
}

function longDate(s) {
    return parseISO(s).toLocaleDateString('en-GB', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' });
}

function startOf(a) {
    const d = parseISO(a.appointment_date);
    const match = String(a.appointment_time || '').match(/^(\d{1,2}):(\d{2})/);
    if (!match) return new Date(NaN);
    d.setHours(Number(match[1]), Number(match[2]), 0, 0);
    return d;
}

function isUpcoming(a) {
    const status = String(a.status || '').toLowerCase();
    if (status !== 'booked' && status !== 'scheduled') return false;

    const appointmentDay = parseISO(a.appointment_date);
    if (Number.isNaN(appointmentDay.getTime())) return false;
    appointmentDay.setHours(0, 0, 0, 0);

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    if (appointmentDay > today) return true;
    if (appointmentDay < today) return false;

    const scheduledTime = startOf(a);
    return Number.isNaN(scheduledTime.getTime()) || scheduledTime > new Date();
}

function patientText(a) {
    return a.patient_type === 'child' ? a.child_name + ' (child)' : 'Myself';
}

function reference(a) {
    const id = a.id ?? a.appointment_id;
    return 'VAX-' + String(id ?? 'confirmed').padStart(5, '0');
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
    const slots = await getAvailableSlots(current.doctor_id, newDate.value, current.id);
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
        errorBox.textContent = err.status && err.status < 500 ? err.message : 'Sorry, we could not change your appointment. Please try again.';
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
        errorBox.textContent = err.status && err.status < 500 ? err.message : 'Sorry, we could not cancel your appointment. Please try again.';
        errorBox.classList.remove('d-none');
        confirmCancelBtn.disabled = false;
        confirmCancelBtn.textContent = 'Yes, cancel it';
    }
});

// A doctor or admin changed a visit while this page is open: show the new details.
window.addEventListener('vax:refresh', async function (e) {
    if (!e.detail || !e.detail.data) return;
    try {
        appointments = await getAppointments();
        render();
    } catch (err) { /* the next refresh will try again */ }
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
