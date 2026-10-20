async function getChildren() {
    return [{ id: 1, first_name: 'Aiden', dob: daysFromToday(-430) }];
}

const TRAVEL_VACCINES = {
    'Yellow Fever':          { lead: 10, doctor: 1 },
    'Typhoid':               { lead: 14, doctor: 1 },
    'Hepatitis A':           { lead: 14, doctor: 1 },
    'Rabies':                { lead: 28, doctor: 1 },
    'Japanese Encephalitis': { lead: 28, doctor: 1 },
    'Meningococcal ACWY':    { lead: 10, doctor: 1 },
    'Cholera':               { lead: 14, doctor: 1 },
    'Polio (IPV)':           { lead: 28, doctor: 1 },
    'Influenza':             { lead: 14, doctor: 3 },
    'Td Booster':            { lead: 14, doctor: 3 },
    'MMR':                   { lead: 28, doctor: 3 }
};

function item(name, level, why) {
    return { name: name, level: level, why: why };
}

const HEP_A  = item('Hepatitis A', 'recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.');
const TYPHOID = item('Typhoid', 'recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.');
const RABIES = item('Rabies', 'recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.');
const JE     = item('Japanese Encephalitis', 'recommended', 'Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.');
const FLU    = item('Influenza', 'recommended', 'Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.');
const TD     = item('Td Booster', 'recommended', 'Keeps tetanus and diphtheria cover up to date (every 10 years).');
const MMR    = item('MMR', 'recommended', 'Measles outbreaks happen worldwide. Make sure you have had two doses.');
const POLIO  = item('Polio (IPV)', 'recommended', 'Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.');
const CHOLERA = item('Cholera', 'recommended', 'Mainly for aid workers or travellers to areas with active outbreaks.');
const MEN_REC = item('Meningococcal ACWY', 'recommended', 'Advised for the African meningitis belt, especially during the dry season.');
const YF_REC  = item('Yellow Fever', 'recommended', 'Mosquito-borne and present in this region. One dose gives lifelong protection.');
const YF_REQ  = item('Yellow Fever', 'required', 'A yellow fever certificate is required to enter. One dose gives lifelong protection.');
const MEN_REQ = item('Meningococcal ACWY', 'required', 'Proof of vaccination is required for Hajj and Umrah visas.');

async function getDestinations() {
    return [
        { id: 'AU', country: 'Australia',      region: 'Oceania',      vaccines: [FLU, TD, MMR] },
        { id: 'BR', country: 'Brazil',         region: 'South America', vaccines: [YF_REC, HEP_A, TYPHOID, RABIES, FLU] },
        { id: 'KH', country: 'Cambodia',       region: 'Asia',          vaccines: [HEP_A, TYPHOID, RABIES, JE] },
        { id: 'CN', country: 'China',          region: 'Asia',          vaccines: [HEP_A, TYPHOID, JE, FLU, MMR] },
        { id: 'EG', country: 'Egypt',          region: 'Middle East',   vaccines: [HEP_A, TYPHOID, POLIO, TD] },
        { id: 'GH', country: 'Ghana',          region: 'Africa',        vaccines: [YF_REQ, HEP_A, TYPHOID, MEN_REC, RABIES, POLIO] },
        { id: 'IN', country: 'India',          region: 'Asia',          vaccines: [HEP_A, TYPHOID, RABIES, JE, POLIO, CHOLERA] },
        { id: 'ID', country: 'Indonesia',      region: 'Asia',          vaccines: [HEP_A, TYPHOID, RABIES, JE, TD] },
        { id: 'JP', country: 'Japan',          region: 'Asia',          vaccines: [HEP_A, JE, FLU, MMR] },
        { id: 'KE', country: 'Kenya',          region: 'Africa',        vaccines: [YF_REC, HEP_A, TYPHOID, RABIES, MEN_REC, POLIO] },
        { id: 'NP', country: 'Nepal',          region: 'Asia',          vaccines: [HEP_A, TYPHOID, RABIES, JE, POLIO, MEN_REC] },
        { id: 'NG', country: 'Nigeria',        region: 'Africa',        vaccines: [YF_REQ, HEP_A, TYPHOID, MEN_REC, POLIO, CHOLERA] },
        { id: 'PE', country: 'Peru',           region: 'South America', vaccines: [YF_REC, HEP_A, TYPHOID, RABIES] },
        { id: 'PH', country: 'Philippines',    region: 'Asia',          vaccines: [HEP_A, TYPHOID, RABIES, JE, CHOLERA] },
        { id: 'SA', country: 'Saudi Arabia',   region: 'Middle East',   vaccines: [MEN_REQ, HEP_A, TYPHOID, FLU, POLIO] },
        { id: 'SG', country: 'Singapore',      region: 'Asia',          vaccines: [HEP_A, TD] },
        { id: 'ZA', country: 'South Africa',   region: 'Africa',        vaccines: [HEP_A, TYPHOID, RABIES, TD] },
        { id: 'KR', country: 'South Korea',    region: 'Asia',          vaccines: [HEP_A, FLU, MMR] },
        { id: 'TZ', country: 'Tanzania',       region: 'Africa',        vaccines: [YF_REC, HEP_A, TYPHOID, RABIES, MEN_REC, POLIO] },
        { id: 'TH', country: 'Thailand',       region: 'Asia',          vaccines: [HEP_A, TYPHOID, RABIES, JE, TD] },
        { id: 'UG', country: 'Uganda',         region: 'Africa',        vaccines: [YF_REQ, HEP_A, TYPHOID, RABIES, MEN_REC, POLIO] },
        { id: 'GB', country: 'United Kingdom', region: 'Europe',        vaccines: [FLU, TD, MMR] },
        { id: 'US', country: 'United States',  region: 'North America', vaccines: [FLU, TD, MMR] },
        { id: 'VN', country: 'Vietnam',        region: 'Asia',          vaccines: [HEP_A, TYPHOID, RABIES, JE, TD] }
    ];
}

async function getChildSchedule() {
    return [
        { months: 0,  name: 'BCG',                level: 'required',    dose: 'Single dose',  why: 'Protects against severe forms of tuberculosis.' },
        { months: 0,  name: 'Hepatitis B',        level: 'required',    dose: 'Dose 1 of 3',  why: 'Protects the liver against hepatitis B infection.' },
        { months: 1,  name: 'Hepatitis B',        level: 'required',    dose: 'Dose 2 of 3',  why: 'Second dose of the hepatitis B course.' },
        { months: 2,  name: 'DTaP-IPV-Hib',       level: 'required',    dose: 'Dose 1 of 4',  why: 'Covers diphtheria, tetanus, whooping cough, polio and Hib in one injection.' },
        { months: 2,  name: 'Pneumococcal (PCV)', level: 'required',    dose: 'Dose 1 of 4',  why: 'Protects against pneumonia, meningitis and ear infections.' },
        { months: 2,  name: 'Rotavirus',          level: 'recommended', dose: 'Dose 1 of 2',  why: 'Oral vaccine that prevents severe diarrhoea in babies.' },
        { months: 3,  name: 'DTaP-IPV-Hib',       level: 'required',    dose: 'Dose 2 of 4',  why: 'Second dose of the five-in-one vaccine.' },
        { months: 3,  name: 'Pneumococcal (PCV)', level: 'required',    dose: 'Dose 2 of 4',  why: 'Second dose of the pneumococcal course.' },
        { months: 3,  name: 'Rotavirus',          level: 'recommended', dose: 'Dose 2 of 2',  why: 'Completes the rotavirus course.' },
        { months: 5,  name: 'DTaP-IPV-Hib',       level: 'required',    dose: 'Dose 3 of 4',  why: 'Third dose of the five-in-one vaccine.' },
        { months: 5,  name: 'Pneumococcal (PCV)', level: 'required',    dose: 'Dose 3 of 4',  why: 'Third dose of the pneumococcal course.' },
        { months: 6,  name: 'Hepatitis B',        level: 'required',    dose: 'Dose 3 of 3',  why: 'Completes the hepatitis B course.' },
        { months: 6,  name: 'Influenza',          level: 'recommended', dose: 'Yearly',       why: 'Flu vaccine is advised every year from 6 months old.' },
        { months: 9,  name: 'MMR',                level: 'required',    dose: 'Dose 1 of 2',  why: 'Protects against measles, mumps and rubella.' },
        { months: 12, name: 'Pneumococcal (PCV)', level: 'required',    dose: 'Booster',      why: 'Booster dose to keep protection strong.' },
        { months: 12, name: 'MMR',                level: 'required',    dose: 'Dose 2 of 2',  why: 'Second dose gives long-lasting protection.' },
        { months: 12, name: 'Varicella',          level: 'recommended', dose: 'Dose 1 of 2',  why: 'Protects against chickenpox and shingles later in life.' },
        { months: 18, name: 'DTaP-IPV-Hib',       level: 'required',    dose: 'Booster',      why: 'Booster dose of the five-in-one vaccine.' },
        { months: 36, name: 'Varicella',          level: 'recommended', dose: 'Dose 2 of 2',  why: 'Second dose completes chickenpox protection.' }
    ];
}

const travelForm = document.getElementById('travelPanel');
const childForm = document.getElementById('childPanel');
const tabTravel = document.getElementById('tabTravel');
const tabChild = document.getElementById('tabChild');
const destinationSel = document.getElementById('destination');
const departDate = document.getElementById('departDate');
const childDob = document.getElementById('childDob');
const childDobError = document.getElementById('childDobError');
const savedChildren = document.getElementById('savedChildren');
const results = document.getElementById('results');

let destinations = [];
let childSchedule = [];
let records = [];

function esc(text) {
    const div = document.createElement('div');
    div.textContent = text == null ? '' : text;
    return div.innerHTML;
}

function parseISO(iso) {
    const p = iso.split('-');
    return new Date(Number(p[0]), Number(p[1]) - 1, Number(p[2]));
}

function startOfToday() {
    const t = new Date();
    return new Date(t.getFullYear(), t.getMonth(), t.getDate());
}

function addDays(date, n) {
    return new Date(date.getFullYear(), date.getMonth(), date.getDate() + n);
}

function addMonths(date, n) {
    const d = new Date(date.getFullYear(), date.getMonth() + n, date.getDate());
    if (d.getDate() !== date.getDate()) d.setDate(0);
    return d;
}

function daysBetween(a, b) {
    return Math.round((b - a) / 86400000);
}

function formatDate(d) {
    return d.toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' });
}

function plural(n, word) {
    return n + ' ' + word + (n === 1 ? '' : 's');
}

function doseNumber(v) {
    const m = /Dose (\d+)/.exec(v.dose);
    if (m) return Number(m[1]);
    if (v.dose === 'Single dose') return 1;
    if (v.dose === 'Booster') return 4;
    return 0;
}

function latestRecord(list, name) {
    const found = list.filter(function (r) { return r.vaccine_name === name; });
    found.sort(function (a, b) { return a.date_given < b.date_given ? 1 : -1; });
    return found[0] || null;
}

function isProtected(v) {
    const rec = latestRecord(records.filter(function (r) { return r.patient_type === 'self'; }), v.name);
    return !!rec && rec.dose_number >= rec.total_doses && (!rec.next_dose_date || rec.next_dose_date >= daysFromToday(0));
}

function bookingLink(name, doctorId) {
    return 'booking.html?vaccine=' + encodeURIComponent(name) + '&doctor_id=' + encodeURIComponent(doctorId);
}

function levelBadge(level) {
    return level === 'required'
        ? '<span class="badge-req">Required</span>'
        : '<span class="badge-rec">Recommended</span>';
}

function showTab(which) {
    const travel = which === 'travel';
    tabTravel.classList.toggle('active', travel);
    tabChild.classList.toggle('active', !travel);
    tabTravel.setAttribute('aria-selected', travel);
    tabChild.setAttribute('aria-selected', !travel);
    travelForm.classList.toggle('d-none', !travel);
    childForm.classList.toggle('d-none', travel);
    clearResults();
}

function clearResults() {
    results.innerHTML =
        '<div class="empty-state" id="emptyState">' +
        '<div class="empty-icon">&#128137;</div>' +
        '<h2>Your schedule will appear here</h2>' +
        '<p>Choose a destination or enter a date of birth above to get started.</p>' +
        '</div>';
}

function printButton() {
    return '<button type="button" class="print-btn" id="printBtn">Print schedule</button>';
}

function travelCard(v, departure) {
    const info = TRAVEL_VACCINES[v.name] || { lead: 14, doctor: 1 };
    const rec = latestRecord(records.filter(function (r) { return r.patient_type === 'self'; }), v.name);

    if (isProtected(v)) {
        return '<div class="vax-card done">' +
            '<div class="vax-main">' +
            '<h3 class="vax-name">' + esc(v.name) + '</h3><span class="badge-done">Already protected</span>' +
            '<p class="vax-why">' + esc(v.why) + '</p>' +
            '<div class="vax-when ok">&#10003; Given on ' + esc(formatDate(parseISO(rec.date_given))) + ' (batch ' + esc(rec.batch_number) + ')' +
            (rec.next_dose_date ? ', next dose ' + esc(formatDate(parseISO(rec.next_dose_date))) : '') + '</div>' +
            '</div></div>';
    }

    let when = 'Ideally ' + plural(info.lead, 'day') + ' before you travel';
    let cls = '';

    if (rec) {
        when = 'Dose ' + rec.dose_number + ' of ' + rec.total_doses + ' given on ' + formatDate(parseISO(rec.date_given)) +
            (rec.next_dose_date ? '. Next dose ' + formatDate(parseISO(rec.next_dose_date)) : '');
        cls = 'soon';
    } else if (departure) {
        const bookBy = addDays(departure, -info.lead);
        const left = daysBetween(startOfToday(), bookBy);
        if (left < 0) {
            when = 'Short notice: book now, as protection may not be complete by departure';
            cls = 'urgent';
        } else if (left <= 14) {
            when = 'Book within ' + plural(left, 'day') + ' (by ' + formatDate(bookBy) + ')';
            cls = 'soon';
        } else {
            when = 'Book by ' + formatDate(bookBy);
        }
    }

    return '<div class="vax-card ' + esc(v.level) + '">' +
        '<div class="vax-main">' +
        '<h3 class="vax-name">' + esc(v.name) + '</h3>' + levelBadge(v.level) +
        '<p class="vax-why">' + esc(v.why) + '</p>' +
        '<div class="vax-when ' + cls + '">&#128197; ' + esc(when) + '</div>' +
        '</div>' +
        '<a class="btn appointment-btn" href="' + bookingLink(v.name, info.doctor) + '">' + (rec ? 'Book next dose' : 'Book this vaccine') + '</a>' +
        '</div>';
}

function renderTravel(dest, departure) {
    const required = dest.vaccines.filter(function (v) { return v.level === 'required'; });
    const recommended = dest.vaccines.filter(function (v) { return v.level === 'recommended'; });
    const protectedCount = dest.vaccines.filter(isProtected).length;
    const requiredLeft = required.filter(function (v) { return !isProtected(v); }).length;
    const recommendedLeft = recommended.filter(function (v) { return !isProtected(v); }).length;

    let sub = 'Based on the general guidance for ' + dest.region + '.';
    if (departure) {
        const days = daysBetween(startOfToday(), departure);
        sub = 'You leave in ' + plural(days, 'day') + ', on ' + formatDate(departure) + '.';
    }

    let html = '<div class="summary-card fade-in">' +
        '<div><h2>Your schedule for ' + esc(dest.country) + '</h2><p>' + esc(sub) + '</p></div>' +
        '<div class="summary-counts">' +
        '<div><strong>' + requiredLeft + '</strong><span>Required</span></div>' +
        '<div><strong>' + recommendedLeft + '</strong><span>Recommended</span></div>' +
        '<div><strong>' + protectedCount + '</strong><span>Already done</span></div>' +
        '</div>' + printButton() + '</div>';

    if (departure && daysBetween(startOfToday(), departure) < 14) {
        html += '<div class="note-banner">&#9888;&#65039; You are travelling soon. Book a travel-medicine consultation as soon as you can so the doctor can advise on what is still possible.</div>';
    }

    if (required.length) {
        html += '<div class="group-title">Required to enter the country</div>' +
            required.map(function (v) { return travelCard(v, departure); }).join('');
    } else {
        html += '<div class="note-banner">No vaccine is required to enter ' + esc(dest.country) +
            ' for most travellers, but the recommended ones below are worth considering.</div>';
    }

    html += '<div class="group-title">Recommended for your health</div>' +
        recommended.map(function (v) { return travelCard(v, departure); }).join('');

    html += '<div class="group-title">Not sure what you need?</div>' +
        '<div class="vax-card"><div class="vax-main"><h3 class="vax-name">Travel consultation</h3>' +
        '<p class="vax-why">Talk through your itinerary, health and budget with a travel-medicine doctor.</p></div>' +
        '<a class="btn appointment-btn" href="' + bookingLink('Vaccine consultation', 1) + '">Book a consultation</a></div>';

    results.innerHTML = html;
}

function ageInMonths(dob, onDate) {
    let m = (onDate.getFullYear() - dob.getFullYear()) * 12 + (onDate.getMonth() - dob.getMonth());
    if (onDate.getDate() < dob.getDate()) m -= 1;
    return m;
}

function ageText(months) {
    if (months < 1) return 'under 1 month old';
    if (months < 24) return plural(months, 'month') + ' old';
    const y = Math.floor(months / 12), r = months % 12;
    return plural(y, 'year') + (r ? ' ' + plural(r, 'month') : '') + ' old';
}

function milestoneName(months) {
    if (months === 0) return 'At birth';
    if (months < 24) return months + (months === 1 ? ' month' : ' months');
    return (months / 12) + ' years';
}

function childStatus(due) {
    const diff = daysBetween(startOfToday(), due);
    if (diff < -30) return { cls: 'urgent', text: 'Past due since ' + formatDate(due) + ' - check your child\'s record or book a catch-up' };
    if (diff <= 30)  return { cls: 'soon',   text: diff < 0 ? 'Due now (was due ' + formatDate(due) + ')' : 'Due now - by ' + formatDate(due) };
    return { cls: '', text: 'Due ' + formatDate(due) + ' (in ' + plural(diff, 'day') + ')' };
}

function childCard(v, due, rec) {
    if (rec) {
        return '<div class="vax-card done">' +
            '<div class="vax-main">' +
            '<h3 class="vax-name">' + esc(v.name) + '</h3><span class="badge-done">Done</span>' +
            '<p class="vax-why">' + esc(v.dose) + ' &middot; ' + esc(v.why) + '</p>' +
            '<div class="vax-when ok">&#10003; Given on ' + esc(formatDate(parseISO(rec.date_given))) + ' (batch ' + esc(rec.batch_number) + ')</div>' +
            '</div></div>';
    }
    const st = childStatus(due);
    return '<div class="vax-card ' + esc(v.level) + '">' +
        '<div class="vax-main">' +
        '<h3 class="vax-name">' + esc(v.name) + '</h3>' + levelBadge(v.level) +
        '<p class="vax-why">' + esc(v.dose) + ' &middot; ' + esc(v.why) + '</p>' +
        '<div class="vax-when ' + st.cls + '">&#128197; ' + esc(st.text) + '</div>' +
        '</div>' +
        '<a class="btn appointment-btn" href="' + bookingLink(v.name, 2) + '">Book this dose</a>' +
        '</div>';
}

function renderChild(dobIso, childName) {
    const dob = parseISO(dobIso);
    const today = startOfToday();
    const months = ageInMonths(dob, today);

    const childRecords = childName
        ? records.filter(function (r) { return r.patient_type === 'child' && r.patient_name === childName; })
        : [];
    const items = childSchedule.map(function (v) {
        const n = doseNumber(v);
        const rec = n ? childRecords.find(function (r) { return r.vaccine_name === v.name && r.dose_number >= n; }) : null;
        return { v: v, due: addMonths(dob, v.months), rec: rec || null };
    });
    const todo = items.filter(function (x) { return !x.rec; });
    const required = todo.filter(function (x) { return x.v.level === 'required'; }).length;
    const recommended = todo.length - required;
    const doneCount = items.length - todo.length;

    let html = '<div class="summary-card fade-in">' +
        '<div><h2>Childhood schedule</h2><p>Your child is ' + esc(ageText(months)) +
        ' (born ' + esc(formatDate(dob)) + ').</p></div>' +
        '<div class="summary-counts">' +
        '<div><strong>' + required + '</strong><span>Required</span></div>' +
        '<div><strong>' + recommended + '</strong><span>Recommended</span></div>' +
        (childName ? '<div><strong>' + doneCount + '</strong><span>Already done</span></div>' : '') +
        '</div>' + printButton() + '</div>';

    if (months > 42) {
        html += '<div class="note-banner">This schedule covers the first three years. For an older child, ask a doctor about catch-up vaccines and school-age boosters.</div>' +
            '<div class="group-title">Next step</div>' +
            '<div class="vax-card"><div class="vax-main"><h3 class="vax-name">Vaccine consultation</h3>' +
            '<p class="vax-why">A paediatrician can check which vaccines your child still needs.</p></div>' +
            '<a class="btn appointment-btn" href="' + bookingLink('Vaccine consultation', 2) + '">Book a consultation</a></div>';
        results.innerHTML = html;
        return;
    }

    html += childName
        ? '<div class="note-banner">Doses already given are ticked using ' + esc(childName) + '\'s record under <a href="vaccinations.html">My Vaccinations</a>.</div>'
        : '<div class="note-banner">Doses marked past due may already have been given. Check your child\'s record under <a href="vaccinations.html">My Vaccinations</a>, or use a saved child above to tick them off automatically.</div>';

    const groups = {};
    items.forEach(function (x) { (groups[x.v.months] = groups[x.v.months] || []).push(x); });

    Object.keys(groups).map(Number).sort(function (a, b) { return a - b; }).forEach(function (m) {
        const list = groups[m];
        html += '<div class="milestone-title"><h3>' + esc(milestoneName(m)) + '</h3><span>' +
            esc(formatDate(list[0].due)) + '</span></div>' +
            list.map(function (x) { return childCard(x.v, x.due, x.rec); }).join('');
    });

    results.innerHTML = html;
}

tabTravel.addEventListener('click', function () { showTab('travel'); });
tabChild.addEventListener('click', function () { showTab('child'); });

travelForm.addEventListener('submit', function (e) {
    e.preventDefault();

    const dest = destinations.find(function (d) { return d.id === destinationSel.value; });
    destinationSel.classList.toggle('is-invalid', !dest);

    const departure = departDate.value ? parseISO(departDate.value) : null;
    const pastDate = !!departure && departure < startOfToday();
    departDate.classList.toggle('is-invalid', pastDate);

    if (!dest || pastDate) return;
    renderTravel(dest, departure);
});

childForm.addEventListener('submit', function (e) {
    e.preventDefault();

    let problem = '';
    if (!childDob.value) problem = 'Please enter your child\'s date of birth.';
    else if (parseISO(childDob.value) > startOfToday()) problem = 'Date of birth cannot be in the future.';
    else if (ageInMonths(parseISO(childDob.value), startOfToday()) > 216) problem = 'This planner is for children under 18.';

    childDobError.textContent = problem;
    childDob.classList.toggle('is-invalid', !!problem);
    if (problem) return;
    renderChild(childDob.value, '');
});

results.addEventListener('click', function (e) {
    if (e.target.id === 'printBtn') window.print();
});

savedChildren.addEventListener('click', function (e) {
    const chip = e.target.closest('.chip');
    if (!chip) return;
    childDob.value = chip.dataset.dob;
    childDob.classList.remove('is-invalid');
    renderChild(childDob.value, chip.dataset.name);
});

async function init() {
    destinations = await getDestinations();
    childSchedule = await getChildSchedule();
    const signedIn = !!VaxAuth.getUser();
    const children = signedIn ? await getChildren() : [];
    records = signedIn ? await getVaccinations() : [];

    destinationSel.innerHTML = '<option value="">Choose a country</option>' + destinations.map(function (d) {
        return '<option value="' + esc(d.id) + '">' + esc(d.country) + '</option>';
    }).join('');

    departDate.min = daysFromToday(0);
    childDob.max = daysFromToday(0);

    savedChildren.innerHTML = children.map(function (c) {
        return '<button type="button" class="chip" data-dob="' + esc(c.dob) + '" data-name="' + esc(c.first_name) + '">Use ' + esc(c.first_name) + '</button>';
    }).join('');

    const params = new URLSearchParams(window.location.search);
    if (params.get('tab') === 'child' || params.get('mode') === 'child') showTab('child');

    const wantedDob = params.get('child_dob');
    if (params.get('mode') === 'child' && wantedDob) {
        childDob.value = wantedDob;
        childForm.requestSubmit();
    }

    const wantedCountry = (params.get('destination') || '').trim().toLowerCase();
    if (params.get('mode') !== 'child' && wantedCountry) {
        const match = destinations.find(function (d) {
            return d.country.toLowerCase() === wantedCountry || d.id.toLowerCase() === wantedCountry;
        });
        if (match) {
            destinationSel.value = match.id;
            travelForm.requestSubmit();
        } else {
            results.innerHTML = '<div class="note-banner">We do not have guidance for &quot;' + esc(params.get('destination')) +
                '&quot; yet. Please choose a country from the list above.</div>';
        }
    }
}

init();
