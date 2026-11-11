// Doctors page: search and filter doctors.

// Loads the doctor list from the API.
async function getDoctors() {
    return (await VaxApi.get('api/doctors')).doctors;
}

const searchInput = document.getElementById('search');
const specialtySelect = document.getElementById('specialty');
const availabilitySelect = document.getElementById('availability');
const list = document.getElementById('doctorList');
const count = document.getElementById('count');

const DAY_NAMES = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
let doctors = [];

// Escapes text so it is safe to put in HTML.
function esc(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Makes the initials shown in an avatar.
function initials(name) {
    return name.replace('Dr. ', '').split(' ').map(function (w) { return w[0]; }).slice(0, 2).join('');
}

// Finds the doctor's next working day.
function nextAvailable(days) {
    const d = new Date();
    for (let i = 0; i < 8; i++) {
        const check = new Date(d.getFullYear(), d.getMonth(), d.getDate() + i);
        const usable = i > 0 || d.getHours() < 17;
        if (usable && days.indexOf(check.getDay()) !== -1) return { date: check, today: i === 0 };
    }
    return null;
}

// Describes the next available day as text.
function nextText(days) {
    const next = nextAvailable(days);
    if (!next) return 'No upcoming availability';
    if (next.today) return 'Available today';
    return next.date.toLocaleDateString('en-GB', { weekday: 'short', day: 'numeric', month: 'short' });
}

// Builds the HTML card for one doctor.
function card(d) {
    const pills = [1, 2, 3, 4, 5].map(function (n) {
        return '<span class="day-pill' + (d.days.indexOf(n) !== -1 ? ' on' : '') + '">' + DAY_NAMES[n] + '</span>';
    }).join('');

    const experience = d.years_experience ? esc(d.years_experience) + ' years experience' : '';
    const rating = d.rating === null ? 'No reviews yet' : '&#9733; ' + esc(d.rating) + ' (' + esc(d.review_count) + ')';

    return '<div class="col-md-6 col-lg-4"><div class="doctor-card">' +
        '<div class="d-flex align-items-center gap-3 mb-3">' +
            '<div class="avatar">' + esc(initials(d.name)) + '</div>' +
            '<div><h5>' + esc(d.name) + '</h5><div class="specialty">' + esc(d.specialty) + '</div></div>' +
        '</div>' +
        (d.bio ? '<p class="bio">' + esc(d.bio) + '</p>' : '') +
        '<div class="meta mb-2">' + [experience, rating].filter(Boolean).join(' &middot; ') + '</div>' +
        (d.languages ? '<div class="meta mb-3">Languages: ' + esc(d.languages) + '</div>' : '') +
        '<div class="mb-3">' + pills + '</div>' +
        '<div class="mt-auto d-flex justify-content-between align-items-center gap-2">' +
            '<span class="meta">Next: <strong>' + esc(nextText(d.days)) + '</strong></span>' +
            '<a class="btn btn-sm appointment-btn" href="booking.html?doctor_id=' + encodeURIComponent(d.id) + '">Book</a>' +
        '</div>' +
        '</div></div>';
}

// Checks if a doctor matches the search text.
function matchesSearch(d, term) {
    if (!term) return true;
    const haystack = [d.name, d.specialty].concat(d.treats).join(' ').toLowerCase();
    return haystack.indexOf(term) !== -1;
}

// Checks if a doctor works on the chosen day.
function matchesAvailability(d, value) {
    if (!value) return true;
    if (value === 'today') {
        const next = nextAvailable(d.days);
        return !!next && next.today;
    }
    return d.days.indexOf(Number(value)) !== -1;
}

// Filters the doctors and draws the list.
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

// Stops the page from reloading.
document.getElementById('filterForm').addEventListener('submit', function (e) { e.preventDefault(); });

// Filters the list while typing.
searchInput.addEventListener('input', render);
// Filters the list by specialty.
specialtySelect.addEventListener('change', render);
// Filters the list by day.
availabilitySelect.addEventListener('change', render);

// Clears all filters.
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
