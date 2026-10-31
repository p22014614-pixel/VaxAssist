async function getCurrentUser() {
    return VaxAuth.fetchUser();
}

async function getVaccinations() {
    return (await VaxApi.get('api/vaccination-records')).records;
}

const recordList = document.getElementById('recordList');
const patientChips = document.getElementById('patientChips');
const searchBox = document.getElementById('searchBox');
const categoryFilter = document.getElementById('categoryFilter');
const sortOrder = document.getElementById('sortOrder');
const resultCount = document.getElementById('resultCount');
const nextBanner = document.getElementById('nextBanner');

const CATEGORY_ICON = { Travel: '&#9992;&#65039;', Childhood: '&#129490;', Seasonal: '&#127810;', Adult: '&#129489;' };
const SOON_DAYS = 60;

const reduceMotion = !!(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches);

let records = [];
let patientFilter = 'all';     // 'all' or a patient_name

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

function daysUntil(s) {
    const today = parseISO(daysFromToday(0));
    return Math.round((parseISO(s) - today) / 86400000);
}

function niceDate(s) {
    return parseISO(s).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' });
}

function dueState(r) {
    if (!r.next_dose_date) return { cls: 'none', text: 'No further doses', days: null };
    const d = daysUntil(r.next_dose_date);
    if (d < 0) return { cls: 'overdue', text: 'Overdue by ' + Math.abs(d) + (Math.abs(d) === 1 ? ' day' : ' days'), days: d };
    if (d === 0) return { cls: 'soon', text: 'Next dose due today', days: d };
    if (d <= SOON_DAYS) return { cls: 'soon', text: 'Next dose in ' + d + (d === 1 ? ' day' : ' days'), days: d };
    return { cls: 'ok', text: 'Next dose ' + niceDate(r.next_dose_date), days: d };
}

function bookLink(r) {
    return 'booking.html?vaccine=' + encodeURIComponent(r.vaccine_name);
}

function countUp(el, target) {
    if (reduceMotion || !window.requestAnimationFrame) { el.textContent = target; return; }
    const start = performance.now();
    const duration = 800;
    function step(now) {
        const t = Math.min(1, (now - start) / duration);
        const eased = 1 - Math.pow(1 - t, 3);
        el.textContent = Math.round(target * eased);
        if (t < 1) requestAnimationFrame(step);
    }
    requestAnimationFrame(step);
}

let observer = null;
function revealCards() {
    const cards = recordList.querySelectorAll('.rec');
    if (!('IntersectionObserver' in window)) {
        cards.forEach(function (c) { c.classList.add('in'); });
        return;
    }
    if (observer) observer.disconnect();
    observer = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
            if (entry.isIntersecting) {
                entry.target.classList.add('in');
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.1 });
    cards.forEach(function (c) { observer.observe(c); });
}

function filtered() {
    const q = searchBox.value.trim().toLowerCase();
    const cat = categoryFilter.value;
    const list = records.filter(function (r) {
        if (patientFilter !== 'all' && r.patient_name !== patientFilter) return false;
        if (cat && r.category !== cat) return false;
        if (q) {
            const hay = (r.vaccine_name + ' ' + r.doctor_name + ' ' + r.batch_number).toLowerCase();
            if (hay.indexOf(q) === -1) return false;
        }
        return true;
    });
    const dir = sortOrder.value === 'oldest' ? 1 : -1;
    list.sort(function (a, b) {
        return a.date_given < b.date_given ? -dir : a.date_given > b.date_given ? dir : 0;
    });
    return list;
}

function pips(r) {
    let out = '';
    for (let i = 1; i <= r.total_doses; i++) {
        out += '<span class="pip' + (i <= r.dose_number ? ' done' : '') + '" style="--p:' + (i - 1) + '"></span>';
    }
    return '<div class="pips" aria-label="Dose ' + esc(r.dose_number) + ' of ' + esc(r.total_doses) + '">' + out +
        '<span class="pip-text">Dose ' + esc(r.dose_number) + ' of ' + esc(r.total_doses) + '</span></div>';
}

function recordCard(r, index) {
    const due = dueState(r);
    const showBook = due.cls === 'overdue' || due.cls === 'soon';
    const catClass = 'cat-' + String(r.category).toLowerCase();
    const detailId = 'details' + r.id;

    return '<article class="rec" style="--i:' + index + '">' +
        '<span class="rec-dot"></span>' +
        '<div class="rec-card">' +
            '<div class="rec-top">' +
                '<div class="rec-icon ' + esc(catClass) + '" aria-hidden="true">' + (CATEGORY_ICON[r.category] || '&#128137;') + '</div>' +
                '<div>' +
                    '<div class="mb-1">' +
                        '<span class="badge-soft badge-cat">' + esc(r.category) + '</span>' +
                        '<span class="badge-soft badge-patient">' + esc(r.patient_type === 'child' ? r.patient_name + ' (child)' : 'Myself') + '</span>' +
                    '</div>' +
                    '<h5>' + esc(r.vaccine_name) + '</h5>' +
                    '<div class="rec-meta">' + esc(niceDate(r.date_given)) + ' &middot; ' + esc(r.doctor_name) + '</div>' +
                    pips(r) +
                '</div>' +
                '<div class="rec-side">' +
                    '<span class="due ' + due.cls + '">' + esc(due.text) + '</span>' +
                    (showBook ? '<a class="btn-small-outline" href="' + bookLink(r) + '">Book next dose</a>' : '') +
                    '<button type="button" class="toggle-btn no-print" aria-expanded="false" aria-controls="' + detailId + '" data-toggle="' + esc(r.id) + '">' +
                        'Details <span class="arrow">&#9662;</span></button>' +
                '</div>' +
            '</div>' +
            '<div class="rec-details" id="' + detailId + '">' +
                '<div class="rec-details-inner">' +
                    '<div class="detail-grid">' +
                        '<div><div class="k">Date given</div><div class="v">' + esc(niceDate(r.date_given)) + '</div></div>' +
                        '<div><div class="k">Batch number</div><div class="v">' + esc(r.batch_number || 'Not recorded') + '</div></div>' +
                        '<div><div class="k">Manufacturer</div><div class="v">' + esc(r.manufacturer || 'Not recorded') + '</div></div>' +
                        '<div><div class="k">Given by</div><div class="v">' + esc(r.doctor_name) + '</div></div>' +
                        '<div><div class="k">Clinic</div><div class="v">' + esc(r.clinic) + '</div></div>' +
                        '<div><div class="k">Next dose</div><div class="v">' + esc(r.next_dose_date ? niceDate(r.next_dose_date) : 'None needed') + '</div></div>' +
                        (r.notes ? '<div style="grid-column: 1 / -1"><div class="k">Notes</div><div class="v">' + esc(r.notes) + '</div></div>' : '') +
                    '</div>' +
                '</div>' +
            '</div>' +
        '</div>' +
    '</article>';
}

function renderStats(list) {
    const names = {};
    list.forEach(function (r) { names[r.patient_name + '|' + r.vaccine_name] = true; });
    let soon = 0, overdue = 0;
    list.forEach(function (r) {
        const d = dueState(r);
        if (d.cls === 'overdue') overdue++;
        if (d.cls === 'soon') soon++;
    });
    countUp(document.getElementById('statRecords'), list.length);
    countUp(document.getElementById('statVaccines'), Object.keys(names).length);
    countUp(document.getElementById('statSoon'), soon);
    countUp(document.getElementById('statOverdue'), overdue);
}

function renderBanner(list) {
    const withNext = list.filter(function (r) { return r.next_dose_date; });
    if (!withNext.length) { nextBanner.innerHTML = ''; return; }
    withNext.sort(function (a, b) { return a.next_dose_date < b.next_dose_date ? -1 : 1; });
    const r = withNext[0];
    const due = dueState(r);
    const who = r.patient_type === 'child' ? r.patient_name + "'s " : 'Your ';
    const when = due.cls === 'overdue' ? 'is overdue' : (due.days === 0 ? 'is due today' : 'is due ' + niceDate(r.next_dose_date));
    nextBanner.innerHTML = '<div class="next-banner fade-in">' +
        '<div>' +
            '<div class="small-label">' + (due.cls === 'overdue' ? 'Needs attention' : 'Coming up next') + '</div>' +
            '<div class="big">' + esc(who + r.vaccine_name + ' (dose ' + (r.dose_number + 1) + ') ' + when) + '</div>' +
        '</div>' +
        '<a class="btn-light-teal" href="' + bookLink(r) + '">Book now</a>' +
    '</div>';
}

function renderChips() {
    const names = [];
    records.forEach(function (r) { if (names.indexOf(r.patient_name) === -1) names.push(r.patient_name); });
    let html = '<button type="button" class="chip' + (patientFilter === 'all' ? ' active' : '') + '" data-patient="all">Everyone</button>';
    names.forEach(function (n) {
        html += '<button type="button" class="chip' + (patientFilter === n ? ' active' : '') + '" data-patient="' + esc(n) + '">' + esc(n) + '</button>';
    });
    patientChips.innerHTML = html;
}

function render() {
    const list = filtered();

    renderStats(list);
    renderBanner(patientFilter === 'all' && !searchBox.value && !categoryFilter.value ? records : list);
    resultCount.textContent = list.length === 1 ? '1 record' : list.length + ' records';

    if (!list.length) {
        recordList.innerHTML = '<div class="empty-state"><div class="icon">&#128269;</div>' +
            (records.length ? 'No records match your search.' : 'You have no vaccination records yet.<br><a href="booking.html" class="btn appointment-btn mt-3">Book your first vaccine</a>') +
            '</div>';
        return;
    }

    const groups = [];
    list.forEach(function (r) {
        const year = r.date_given.slice(0, 4);
        let g = groups[groups.length - 1];
        if (!g || g.year !== year) { g = { year: year, items: [] }; groups.push(g); }
        g.items.push(r);
    });

    let index = 0;
    recordList.innerHTML = groups.map(function (g) {
        return '<div class="year-heading">' + esc(g.year) + '</div>' +
            '<div class="timeline">' +
                g.items.map(function (r) { return recordCard(r, index++ % 8); }).join('') +
            '</div>';
    }).join('');

    revealCards();
}

patientChips.addEventListener('click', function (e) {
    const btn = e.target.closest('button[data-patient]');
    if (!btn) return;
    patientFilter = btn.dataset.patient;
    renderChips();
    render();
});

searchBox.addEventListener('input', render);
categoryFilter.addEventListener('change', render);
sortOrder.addEventListener('change', render);

recordList.addEventListener('click', function (e) {
    const btn = e.target.closest('button[data-toggle]');
    if (!btn) return;
    const panel = document.getElementById(btn.getAttribute('aria-controls'));
    const open = btn.getAttribute('aria-expanded') !== 'true';
    btn.setAttribute('aria-expanded', open ? 'true' : 'false');
    panel.classList.toggle('open', open);
});

document.getElementById('printBtn').addEventListener('click', function () {
    recordList.querySelectorAll('.rec-details').forEach(function (p) { p.classList.add('open'); });
    window.print();
});

(async function init() {
    const user = await getCurrentUser();
    if (!user) {
        window.location.href = 'login.html?next=' + encodeURIComponent('vaccinations.html');
        return;
    }
    try {
        records = await getVaccinations();
        const who = new URLSearchParams(window.location.search).get('patient');
        if (who && records.some(function (r) { return r.patient_name === who; })) patientFilter = who;
        renderChips();
        render();
    } catch (err) {
        recordList.innerHTML = '<div class="empty-state">Sorry, we could not load your vaccination records. Please try again later.</div>';
    }
})();
