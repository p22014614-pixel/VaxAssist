async function getDoctors() {
    return [
        { id: 1, name: 'Dr. Aisha Rahman',  specialty: 'Travel Medicine',  years_experience: 12, rating: 4.9, languages: 'English, Malay',
          bio: 'Advises travellers on vaccines, malaria prevention and health planning for overseas trips.',
          days: [1, 3, 5], treats: ['travel', 'yellow fever', 'typhoid', 'hepatitis a', 'rabies', 'malaria'] },
        { id: 2, name: 'Dr. Daniel Lim',    specialty: 'Paediatrics',      years_experience: 9,  rating: 4.8, languages: 'English, Mandarin',
          bio: 'Looks after babies and children, including growth checks and the childhood vaccination schedule.',
          days: [1, 2, 4], treats: ['child', 'baby', 'fever', 'mmr', 'booster', 'rotavirus', 'bcg'] },
        { id: 3, name: 'Dr. Priya Nair',    specialty: 'General Practice', years_experience: 15, rating: 4.7, languages: 'English, Tamil, Malay',
          bio: 'Family doctor for everyday health concerns, check-ups and vaccine advice for all ages.',
          days: [1, 2, 3, 4, 5], treats: ['cough', 'cold', 'fever', 'flu', 'influenza', 'check-up', 'vaccine', 'tetanus'] },
        { id: 4, name: 'Dr. Ahmad Farid',   specialty: 'Internal Medicine', years_experience: 18, rating: 4.8, languages: 'English, Malay',
          bio: 'Manages long-term conditions such as diabetes, blood pressure and liver health.',
          days: [2, 3, 5], treats: ['diabetes', 'blood pressure', 'hepatitis b', 'liver', 'fatigue'] },
        { id: 5, name: 'Dr. Mei Ling Tan',  specialty: 'Infectious Diseases', years_experience: 8, rating: 4.6, languages: 'English, Mandarin',
          bio: 'Treats infections and advises on vaccine-preventable diseases, outbreaks and post-exposure care.',
          days: [2, 4], treats: ['infection', 'hepatitis b', 'rabies', 'post-exposure', 'measles', 'dengue', 'allergy', 'vaccine reaction'] },
        { id: 6, name: 'Dr. Rajesh Kumar',  specialty: 'Preventive Medicine', years_experience: 14, rating: 4.7, languages: 'English, Hindi',
          bio: 'Plans adult immunisation, health screening and workplace or community vaccination programmes.',
          days: [1, 3], treats: ['adult vaccine', 'screening', 'influenza', 'tetanus', 'workplace', 'pneumococcal', 'booster'] },
        { id: 7, name: 'Dr. Siti Aminah',   specialty: 'Paediatrics',      years_experience: 6,  rating: 4.8, languages: 'English, Malay',
          bio: 'Child health and development, with a special interest in newborn care and immunisation.',
          days: [3, 4, 5], treats: ['newborn', 'baby', 'child', 'hepatitis b', 'dtap', 'pneumococcal', 'vaccine'] },
        { id: 8, name: 'Dr. Jason Wong',    specialty: 'General Practice', years_experience: 10, rating: 4.5, languages: 'English, Mandarin, Cantonese',
          bio: 'Walk-in friendly family doctor offering vaccinations, travel health letters and minor procedures.',
          days: [1, 2, 3, 4, 5], treats: ['vaccine', 'travel', 'typhoid', 'hepatitis a', 'cough', 'fever', 'headache'] }
    ];
}

const searchInput = document.getElementById('search');
const specialtySelect = document.getElementById('specialty');
const availabilitySelect = document.getElementById('availability');
const list = document.getElementById('doctorList');
const count = document.getElementById('count');

const DAY_NAMES = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
let doctors = [];

function esc(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function initials(name) {
    return name.replace('Dr. ', '').split(' ').map(function (w) { return w[0]; }).slice(0, 2).join('');
}

function nextAvailable(days) {
    const d = new Date();
    for (let i = 0; i < 8; i++) {
        const check = new Date(d.getFullYear(), d.getMonth(), d.getDate() + i);
        const usable = i > 0 || d.getHours() < 17;
        if (usable && days.indexOf(check.getDay()) !== -1) return { date: check, today: i === 0 };
    }
    return null;
}

function nextText(days) {
    const next = nextAvailable(days);
    if (!next) return 'No upcoming availability';
    if (next.today) return 'Available today';
    return next.date.toLocaleDateString('en-GB', { weekday: 'short', day: 'numeric', month: 'short' });
}

function card(d) {
    const pills = [1, 2, 3, 4, 5].map(function (n) {
        return '<span class="day-pill' + (d.days.indexOf(n) !== -1 ? ' on' : '') + '">' + DAY_NAMES[n] + '</span>';
    }).join('');

    return '<div class="col-md-6 col-lg-4"><div class="doctor-card">' +
        '<div class="d-flex align-items-center gap-3 mb-3">' +
            '<div class="avatar">' + esc(initials(d.name)) + '</div>' +
            '<div><h5>' + esc(d.name) + '</h5><div class="specialty">' + esc(d.specialty) + '</div></div>' +
        '</div>' +
        '<p class="bio">' + esc(d.bio) + '</p>' +
        '<div class="meta mb-2">' + esc(d.years_experience) + ' years experience &middot; &#9733; ' + esc(d.rating) + '</div>' +
        '<div class="meta mb-3">Languages: ' + esc(d.languages) + '</div>' +
        '<div class="mb-3">' + pills + '</div>' +
        '<div class="mt-auto d-flex justify-content-between align-items-center gap-2">' +
            '<span class="meta">Next: <strong>' + esc(nextText(d.days)) + '</strong></span>' +
            '<a class="btn btn-sm appointment-btn" href="booking.html?doctor_id=' + encodeURIComponent(d.id) + '">Book</a>' +
        '</div>' +
        '</div></div>';
}

function matchesSearch(d, term) {
    if (!term) return true;
    const haystack = [d.name, d.specialty].concat(d.treats).join(' ').toLowerCase();
    return haystack.indexOf(term) !== -1;
}

function matchesAvailability(d, value) {
    if (!value) return true;
    if (value === 'today') {
        const next = nextAvailable(d.days);
        return !!next && next.today;
    }
    return d.days.indexOf(Number(value)) !== -1;
}

function render() {
    const term = searchInput.value.trim().toLowerCase();
    const spec = specialtySelect.value;
    const avail = availabilitySelect.value;

    const shown = doctors.filter(function (d) {
        return matchesSearch(d, term) &&
            (!spec || d.specialty === spec) &&
            matchesAvailability(d, avail);
    });

    count.textContent = shown.length === 1 ? 'Showing 1 doctor' : 'Showing ' + shown.length + ' doctors';
    list.innerHTML = shown.length
        ? shown.map(card).join('')
        : '<div class="col-12"><div class="empty-state">No doctors match your search. Try a different symptom, specialty or day.</div></div>';
}

document.getElementById('filterForm').addEventListener('submit', function (e) { e.preventDefault(); });

searchInput.addEventListener('input', render);
specialtySelect.addEventListener('change', render);
availabilitySelect.addEventListener('change', render);

document.getElementById('resetBtn').addEventListener('click', function () {
    searchInput.value = '';
    specialtySelect.value = '';
    availabilitySelect.value = '';
    render();
});

(async function init() {
    try {
        doctors = await getDoctors();
    } catch (err) {
        list.innerHTML = '<div class="col-12"><div class="empty-state">Sorry, we could not load the doctors. Please try again later.</div></div>';
        return;
    }

    const specialties = Array.from(new Set(doctors.map(function (d) { return d.specialty; }))).sort();
    specialtySelect.innerHTML = '<option value="">All specialties</option>' + specialties.map(function (s) {
        return '<option value="' + esc(s) + '">' + esc(s) + '</option>';
    }).join('');

    const params = new URLSearchParams(window.location.search);
    if (params.get('search')) searchInput.value = params.get('search');

    render();
})();
