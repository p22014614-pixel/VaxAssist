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

async function getVaccines() {
    return [
        { id: 1,  name: 'Yellow Fever',          category: 'Travel vaccines' },
        { id: 2,  name: 'Typhoid',               category: 'Travel vaccines' },
        { id: 3,  name: 'Hepatitis A',           category: 'Travel vaccines' },
        { id: 4,  name: 'Rabies',                category: 'Travel vaccines' },
        { id: 5,  name: 'Japanese Encephalitis', category: 'Travel vaccines' },
        { id: 6,  name: 'Meningococcal ACWY',    category: 'Travel vaccines' },
        { id: 7,  name: 'Cholera',               category: 'Travel vaccines' },
        { id: 8,  name: 'Polio (IPV)',           category: 'Travel vaccines' },
        { id: 9,  name: 'BCG',                   category: 'Childhood vaccines' },
        { id: 10, name: 'Hepatitis B',           category: 'Childhood vaccines' },
        { id: 11, name: 'DTaP-IPV-Hib',          category: 'Childhood vaccines' },
        { id: 12, name: 'Pneumococcal (PCV)',    category: 'Childhood vaccines' },
        { id: 13, name: 'Rotavirus',             category: 'Childhood vaccines' },
        { id: 14, name: 'MMR',                   category: 'Childhood vaccines' },
        { id: 15, name: 'Varicella',             category: 'Childhood vaccines' },
        { id: 16, name: 'Td Booster',            category: 'Boosters' },
        { id: 17, name: 'Influenza',             category: 'Boosters' },
        { id: 18, name: 'Vaccine consultation',  category: 'Consultation' }
    ];
}

async function getAvailableSlots(doctorId, date) {
    const doctor = (await getDoctors()).find(function (d) { return d.id === doctorId; });
    const parts = date.split('-').map(Number);
    const day = new Date(parts[0], parts[1] - 1, parts[2]);
    if (!doctor || doctor.days.indexOf(day.getDay()) === -1) return [];

    const times = [];
    for (let h = 9; h < 17; h++) {
        if (h === 13) continue;                       // lunch break
        times.push(pad(h) + ':00', pad(h) + ':30');
    }

    const now = new Date();
    const isToday = day.toDateString() === now.toDateString();
    return times.map(function (t, i) {
        const taken = ((doctorId * 7 + day.getDate() * 3 + i * 5) % 4) === 0;
        const hm = t.split(':').map(Number);
        const passed = isToday && (hm[0] * 60 + hm[1]) < (now.getHours() * 60 + now.getMinutes() + 60);
        return { time: t, available: !taken && !passed };
    });
}

async function saveBooking(booking) {
    return { id: Math.floor(1000 + Math.random() * 9000) };
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

function pad(n) { return String(n).padStart(2, '0'); }

function esc(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function isoDate(d) {
    return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate());
}

function parseISO(s) {
    const p = s.split('-').map(Number);
    return new Date(p[0], p[1] - 1, p[2]);
}

function timeText(t) {
    const p = t.split(':').map(Number);
    return ((p[0] % 12) || 12) + ':' + pad(p[1]) + ' ' + (p[0] < 12 ? 'AM' : 'PM');
}

function dateText(s) {
    return parseISO(s).toLocaleDateString('en-GB', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' });
}

function selectedDoctor() {
    return doctors.find(function (d) { return String(d.id) === doctorSel.value; });
}

function selectedVaccine() {
    return vaccines.find(function (v) { return String(v.id) === vaccineSel.value; });
}

function selectedTime() {
    const checked = form.querySelector('input[name="appointment_time"]:checked');
    return checked ? checked.value : '';
}

function nextWorkingDate(days) {
    const now = new Date();
    for (let i = 0; i < 14; i++) {
        const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() + i);
        if (i === 0 && now.getHours() >= 16) continue;
        if (days.indexOf(d.getDay()) !== -1) return isoDate(d);
    }
    return '';
}

function setSummary(id, text) {
    const el = document.getElementById(id);
    el.textContent = text || 'Not chosen yet';
    el.classList.toggle('summary-empty', !text);
}

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

doctorSel.addEventListener('change', function () {
    const d = selectedDoctor();
    if (d && (!dateInput.value || d.days.indexOf(parseISO(dateInput.value).getDay()) === -1)) {
        dateInput.value = nextWorkingDate(d.days);
    }
    doctorSel.classList.remove('is-invalid');
    loadSlots();
});

vaccineSel.addEventListener('change', function () {
    vaccineSel.classList.remove('is-invalid');
    updateSummary();
});

dateInput.addEventListener('change', function () {
    dateInput.classList.remove('is-invalid');
    loadSlots();
});

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

childName.addEventListener('input', function () { childName.classList.remove('is-invalid'); updateSummary(); });
childDob.addEventListener('input', function () { childDob.classList.remove('is-invalid'); });

function showFormError(message) {
    formError.textContent = message;
    formError.classList.remove('d-none');
    formError.scrollIntoView({ behavior: 'smooth', block: 'center' });
}

form.addEventListener('submit', async function (e) {
    e.preventDefault();
    formError.classList.add('d-none');

    const forChild = form.elements.patient_type.value === 'child';
    const time = selectedTime();
    let valid = true;

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
        showFormError('Sorry, we could not complete your booking. Please try again.');
        submitBtn.disabled = false;
        submitBtn.textContent = 'Confirm booking';
    }
});

function showSuccess(booking, result) {
    const d = selectedDoctor();
    const v = selectedVaccine();
    document.getElementById('doneRef').textContent = 'VAX-' + String(result.id).padStart(5, '0');
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
