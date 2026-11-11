// Book Appointment page.

// Asks the server who is signed in.
async function getCurrentUser() {
    return VaxAuth.fetchUser();
}

// Loads the doctor list from the API.
async function getDoctors() {
    return (await VaxApi.get('api/doctors')).doctors;
}

// Loads the vaccine list from the API.
async function getVaccines() {
    return (await VaxApi.get('api/vaccines')).vaccines;
}

// Loads the free times for a doctor on a date.
async function getAvailableSlots(doctorId, date) {
    return (await VaxApi.get('api/doctors/' + encodeURIComponent(doctorId) + '/slots?date=' + encodeURIComponent(date))).slots;
}

// Sends the new booking to the API.
async function saveBooking(booking) {
    return VaxApi.post('api/appointments', booking);
}

const form = document.getElementById('bookingForm');
const doctorSel = document.getElementById('doctor');
const vaccineSel = document.getElementById('vaccine');
const dateInput = document.getElementById('date');
const slotGrid = document.getElementById('slotGrid');
const slotMessage = document.getElementById('slotMessage');
const slotError = document.getElementById('slotError');
const workingDays = document.getElementById('workingDays');
const childFields = document.getElementById('childFields');
const childName = document.getElementById('childName');
const childDob = document.getElementById('childDob');
const formError = document.getElementById('formError');
const submitBtn = document.getElementById('submitBtn');

const DAY_NAMES = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
let doctors = [];
let vaccines = [];

// Adds a leading zero to numbers under 10.
function pad(n) { return String(n).padStart(2, '0'); }

// Escapes text so it is safe to put in HTML.
function esc(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Formats a date as YYYY-MM-DD.
function isoDate(d) {
    return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate());
}

// Turns a YYYY-MM-DD text into a date.
function parseISO(s) {
    const p = s.split('-').map(Number);
    return new Date(p[0], p[1] - 1, p[2]);
}

// Formats a 24-hour time as 12-hour text.
function timeText(t) {
    const p = t.split(':').map(Number);
    return ((p[0] % 12) || 12) + ':' + pad(p[1]) + ' ' + (p[0] < 12 ? 'AM' : 'PM');
}

// Formats a date as a long readable date.
function dateText(s) {
    return parseISO(s).toLocaleDateString('en-GB', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' });
}

// Returns the doctor chosen in the form.
function selectedDoctor() {
    return doctors.find(function (d) { return String(d.id) === doctorSel.value; });
}

// Returns the vaccine chosen in the form.
function selectedVaccine() {
    return vaccines.find(function (v) { return String(v.id) === vaccineSel.value; });
}

// Returns the time chosen in the form.
function selectedTime() {
    const checked = form.querySelector('input[name="appointment_time"]:checked');
    return checked ? checked.value : '';
}

// Finds the next day the doctor works.
function nextWorkingDate(days) {
    const now = new Date();
    for (let i = 0; i < 14; i++) {
        const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() + i);
        if (i === 0 && now.getHours() >= 16) continue;
        if (days.indexOf(d.getDay()) !== -1) return isoDate(d);
    }
    return '';
}

// Fills one line of the booking summary.
function setSummary(id, text) {
    const el = document.getElementById(id);
    el.textContent = text || 'Not chosen yet';
    el.classList.toggle('summary-empty', !text);
}

// Refreshes the booking summary box.
function updateSummary() {
    const d = selectedDoctor();
    const v = selectedVaccine();
    const t = selectedTime();
    setSummary('sumDoctor', d ? d.name + ' (' + d.specialty + ')' : '');
    setSummary('sumVaccine', v ? v.name : '');
    setSummary('sumDate', dateInput.value ? dateText(dateInput.value) : '');
    setSummary('sumTime', t ? timeText(t) : '');
    const forChild = form.elements.patient_type.value === 'child';
    document.getElementById('sumPatient').textContent =
        forChild ? (childName.value.trim() ? childName.value.trim() + ' (child)' : 'My child') : 'Myself';
}

// Loads and draws the free times for the chosen doctor and date.
async function loadSlots() {
    slotGrid.innerHTML = '';
    slotError.classList.add('d-none');
    const d = selectedDoctor();

    workingDays.textContent = d
        ? 'Dr. ' + d.name.replace('Dr. ', '') + ' works: ' + d.days.map(function (n) { return DAY_NAMES[n].slice(0, 3); }).join(', ')
        : '';

    if (!d || !dateInput.value) {
        slotMessage.textContent = 'Choose a doctor and a date to see available times.';
        updateSummary();
        return;
    }

    const slots = await getAvailableSlots(d.id, dateInput.value);

    if (!slots.length) {
        slotMessage.textContent = d.name + ' does not work on ' + DAY_NAMES[parseISO(dateInput.value).getDay()] + 's. Please choose one of the days shown above.';
    } else if (!slots.some(function (s) { return s.available; })) {
        slotMessage.textContent = 'All times are taken on this date. Please try another day.';
    } else {
        slotMessage.textContent = 'Choose a time:';
    }

    slotGrid.innerHTML = slots.map(function (s, i) {
        const id = 'slot' + i;
        return '<div>' +
            '<input type="radio" class="btn-check" name="appointment_time" id="' + id + '" value="' + esc(s.time) + '"' + (s.available ? '' : ' disabled') + '>' +
            '<label class="btn slot-label w-100" for="' + id + '">' + esc(timeText(s.time)) + '</label>' +
            '</div>';
    }).join('');

    updateSummary();
}

// Reloads the times when the doctor changes.
doctorSel.addEventListener('change', function () {
    const d = selectedDoctor();
    if (d && (!dateInput.value || d.days.indexOf(parseISO(dateInput.value).getDay()) === -1)) {
        dateInput.value = nextWorkingDate(d.days);
    }
    doctorSel.classList.remove('is-invalid');
    loadSlots();
});

// Updates the summary when the vaccine changes.
vaccineSel.addEventListener('change', function () {
    vaccineSel.classList.remove('is-invalid');
    updateSummary();
});

// Reloads the times for the new date.
dateInput.addEventListener('change', function () {
    dateInput.classList.remove('is-invalid');
    loadSlots();
});

// Updates the summary when a time is chosen.
slotGrid.addEventListener('change', function () {
    slotError.classList.add('d-none');
    updateSummary();
});

form.querySelectorAll('input[name="patient_type"]').forEach(function (radio) {
    radio.addEventListener('change', function () {
        const forChild = form.elements.patient_type.value === 'child';
        childFields.classList.toggle('d-none', !forChild);
        updateSummary();
    });
});

// Clears the error mark while typing.
childName.addEventListener('input', function () { childName.classList.remove('is-invalid'); updateSummary(); });
// Clears the error mark while typing.
childDob.addEventListener('input', function () { childDob.classList.remove('is-invalid'); });

// Shows a form error message.
function showFormError(message) {
    formError.textContent = message;
    formError.classList.remove('d-none');
    formError.scrollIntoView({ behavior: 'smooth', block: 'center' });
}

// Checks the form and sends the booking.
form.addEventListener('submit', async function (e) {
    e.preventDefault();
    formError.classList.add('d-none');

    const forChild = form.elements.patient_type.value === 'child';
    const time = selectedTime();
    let valid = true;

    // Marks a field valid or invalid.
    function check(input, ok) {
        input.classList.toggle('is-invalid', !ok);
        if (!ok) valid = false;
    }

    check(doctorSel, !!doctorSel.value);
    check(vaccineSel, !!vaccineSel.value);

    let dateOk = !!dateInput.value;
    if (dateOk) {
        const picked = parseISO(dateInput.value);
        const today = parseISO(isoDate(new Date()));
        const limit = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 60);
        dateOk = picked >= today && picked <= limit;
    }
    check(dateInput, dateOk);

    if (!time) { slotError.classList.remove('d-none'); valid = false; }

    if (forChild) {
        check(childName, childName.value.trim().length > 0);
        let dobOk = !!childDob.value;
        if (dobOk) {
            const dob = parseISO(childDob.value);
            const now = new Date();
            const eighteenAgo = new Date(now.getFullYear() - 18, now.getMonth(), now.getDate());
            dobOk = dob <= now && dob >= eighteenAgo;
        }
        check(childDob, dobOk);
    }

    if (!valid) return showFormError('Please fix the highlighted fields and try again.');

    const booking = {
        doctor_id: Number(doctorSel.value),
        vaccine_id: Number(vaccineSel.value),
        appointment_date: dateInput.value,
        appointment_time: time,
        patient_type: forChild ? 'child' : 'self',
        child_name: forChild ? childName.value.trim() : '',
        child_dob: forChild ? childDob.value : '',
        notes: document.getElementById('notes').value.trim()
    };

    submitBtn.disabled = true;
    submitBtn.textContent = 'Booking...';
    try {
        const result = await saveBooking(booking);
        showSuccess(booking, result);
    } catch (err) {
        showFormError(err.status && err.status < 500 ? err.message : 'Sorry, we could not complete your booking. Please try again.');
        submitBtn.disabled = false;
        submitBtn.textContent = 'Confirm booking';
    }
});

// Shows the booking confirmation.
function showSuccess(booking, result) {
    const d = selectedDoctor();
    const v = selectedVaccine();
    const appointmentId = result && (result.id ?? result.appointment_id);
    document.getElementById('doneRef').textContent = appointmentId ? 'VAX-' + String(appointmentId).padStart(5, '0') : 'Confirmed';
    document.getElementById('doneDoctor').textContent = d.name + ' (' + d.specialty + ')';
    document.getElementById('doneVaccine').textContent = v.name;
    document.getElementById('doneWhen').textContent = dateText(booking.appointment_date) + ', ' + timeText(booking.appointment_time);
    document.getElementById('donePatient').textContent =
        booking.patient_type === 'child' ? booking.child_name + ' (child)' : 'Myself';
    document.getElementById('bookingArea').classList.add('d-none');
    document.getElementById('successArea').classList.remove('d-none');
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

(async function init() {
    const user = await getCurrentUser();
    if (!user) {
        window.location.href = 'login.html?next=' + encodeURIComponent('booking.html' + window.location.search);
        return;
    }
    document.getElementById('userBox').textContent = 'Booking as ' + user.first_name + ' ' + user.last_name;

    doctors = await getDoctors();
    vaccines = await getVaccines();

    doctorSel.innerHTML = '<option value="">Choose a doctor</option>' + doctors.map(function (d) {
        return '<option value="' + esc(d.id) + '">' + esc(d.name) + ' - ' + esc(d.specialty) + '</option>';
    }).join('');

    const groups = {};
    vaccines.forEach(function (v) { (groups[v.category] = groups[v.category] || []).push(v); });
    vaccineSel.innerHTML = '<option value="">Choose a vaccine or service</option>' + Object.keys(groups).map(function (cat) {
        return '<optgroup label="' + esc(cat) + '">' + groups[cat].map(function (v) {
            return '<option value="' + esc(v.id) + '">' + esc(v.name) + '</option>';
        }).join('') + '</optgroup>';
    }).join('');

    const today = new Date();
    dateInput.min = isoDate(today);
    dateInput.max = isoDate(new Date(today.getFullYear(), today.getMonth(), today.getDate() + 60));
    childDob.max = isoDate(today);

    const params = new URLSearchParams(window.location.search);
    if (params.get('doctor_id') && doctors.some(function (d) { return String(d.id) === params.get('doctor_id'); })) {
        doctorSel.value = params.get('doctor_id');
        dateInput.value = nextWorkingDate(selectedDoctor().days);
    }
    const wanted = (params.get('vaccine') || '').toLowerCase();
    if (wanted) {
        const match = vaccines.find(function (v) { return v.name.toLowerCase() === wanted; });
        if (match) vaccineSel.value = String(match.id);
    }

    loadSlots();
    updateSummary();
})();
