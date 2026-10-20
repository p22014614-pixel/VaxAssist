const QUESTIONS = [
    { id: 'fever',    text: 'Do you have a fever (38\u00B0C or higher) or feel unwell today?' },
    { id: 'reaction', text: 'Have you ever had a severe allergic reaction (anaphylaxis) to a vaccine or to something in it?' },
    { id: 'immune',   text: 'Do you have a weakened immune system, or take steroids, chemotherapy or similar medicine?' },
    { id: 'pregnant', text: 'Are you pregnant, planning a pregnancy, or breastfeeding?', selfOnly: true },
    { id: 'recent',   text: 'Have you had any other vaccine in the last 4 weeks?' },
    { id: 'bleeding', text: 'Do you have a bleeding disorder or take blood thinners?' }
];

const VACCINE_NAMES = ['Yellow Fever', 'Typhoid', 'Hepatitis A', 'Rabies', 'Japanese Encephalitis', 'Meningococcal ACWY',
    'Cholera', 'Polio (IPV)', 'BCG', 'Hepatitis B', 'DTaP-IPV-Hib', 'Pneumococcal (PCV)', 'Rotavirus', 'MMR',
    'Varicella', 'Td Booster', 'Influenza'];

async function getChildren() {
    return [{ id: 1, first_name: 'Aiden' }];
}

async function getPreconsultations() {
    try { return JSON.parse(localStorage.getItem('vaxPrecheck')) || []; } catch (e) { return []; }
}

async function savePreconsultation(form) {
    const all = await getPreconsultations();
    all.unshift(form);
    try { localStorage.setItem('vaxPrecheck', JSON.stringify(all.slice(0, 20))); } catch (e) {}
    return form;
}

const formEl = document.getElementById('precheckForm');
const patientSel = document.getElementById('patient');
const vaccineSel = document.getElementById('vaccine');
const questionsBox = document.getElementById('questions');
const formError = document.getElementById('formError');
const resultArea = document.getElementById('resultArea');
const historyBox = document.getElementById('history');
const consent = document.getElementById('consent');

function esc(text) {
    const div = document.createElement('div');
    div.textContent = text == null ? '' : text;
    return div.innerHTML;
}

function renderQuestions() {
    const self = patientSel.value === 'self';
    questionsBox.innerHTML = QUESTIONS.filter(function (q) { return !q.selfOnly || self; }).map(function (q) {
        return '<div class="question" data-q="' + q.id + '"><p>' + esc(q.text) + '</p>' +
            '<div class="yn" role="radiogroup" aria-label="' + esc(q.text) + '">' +
            '<input type="radio" name="' + q.id + '" id="' + q.id + 'No" value="no"><label for="' + q.id + 'No">No</label>' +
            '<input type="radio" name="' + q.id + '" id="' + q.id + 'Yes" value="yes"><label for="' + q.id + 'Yes">Yes</label>' +
            '</div></div>';
    }).join('');
}

function answer(id) {
    const checked = formEl.querySelector('input[name="' + id + '"]:checked');
    return checked ? checked.value : null;
}

function buildFlags(a) {
    const flags = [];
    if (a.fever === 'yes') flags.push({ serious: true, text: 'You feel unwell or have a fever. Vaccines are usually postponed until you recover, so please reschedule or call the clinic.' });
    if (a.reaction === 'yes') flags.push({ serious: true, text: 'A previous severe reaction means the doctor must review you before any vaccine is given.' });
    if (a.immune === 'yes') flags.push({ serious: false, text: 'Live vaccines (such as Yellow Fever, MMR and Varicella) may not be suitable. The doctor will advise.' });
    if (a.pregnant === 'yes') flags.push({ serious: false, text: 'Some vaccines are avoided during pregnancy. Tell the doctor which vaccine you want.' });
    if (a.recent === 'yes') flags.push({ serious: false, text: 'Some vaccines need a gap between doses. The doctor will check the timing.' });
    if (a.bleeding === 'yes') flags.push({ serious: false, text: 'Mention this at your visit so the injection can be given safely.' });
    return flags;
}

function renderResult(saved, flags) {
    const bookHref = 'booking.html' + (saved.vaccine ? '?vaccine=' + encodeURIComponent(saved.vaccine) : '');
    let html = '<div class="result-card fade-in"><h2>Form received</h2>' +
        '<p class="text-secondary">Thank you. The doctor will see this before your appointment.</p>';
    if (flags.length) {
        html += flags.map(function (f) {
            return '<div class="flag' + (f.serious ? ' serious' : '') + '">' + esc(f.text) + '</div>';
        }).join('');
    } else {
        html += '<div class="flag" style="border-left-color:#167d8d;background:#e8f5f6;color:#0f5e6b">Nothing in your answers needs special attention.</div>';
    }
    html += '<a class="btn appointment-btn mt-3" href="' + bookHref + '">Continue to booking</a> ' +
        '<button type="button" class="btn btn-outline-secondary mt-3" id="anotherBtn">Fill in another form</button></div>';
    resultArea.innerHTML = html;
    resultArea.classList.remove('d-none');
    formEl.classList.add('d-none');
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

async function renderHistory() {
    const all = await getPreconsultations();
    if (!all.length) {
        historyBox.innerHTML = '<p class="text-secondary small mb-0">No forms yet. Your submitted forms will be listed here.</p>';
        return;
    }
    historyBox.innerHTML = all.slice(0, 5).map(function (f) {
        return '<div class="history-item"><strong>' + esc(f.patient_name) + '</strong>' +
            '<small>' + esc(f.vaccine || 'No vaccine chosen') + ' &middot; ' + esc(new Date(f.submitted_at).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' })) + '</small></div>';
    }).join('');
}

patientSel.addEventListener('change', renderQuestions);

formEl.addEventListener('submit', async function (e) {
    e.preventDefault();
    formError.classList.add('d-none');

    const visible = QUESTIONS.filter(function (q) { return !q.selfOnly || patientSel.value === 'self'; });
    let missing = false;
    visible.forEach(function (q) {
        const unanswered = answer(q.id) === null;
        questionsBox.querySelector('[data-q="' + q.id + '"]').classList.toggle('missing', unanswered);
        if (unanswered) missing = true;
    });
    consent.classList.toggle('is-invalid', !consent.checked);

    if (missing) {
        formError.textContent = 'Please answer every health question.';
        formError.classList.remove('d-none');
        return;
    }
    if (!consent.checked) return;

    const answers = {};
    visible.forEach(function (q) { answers[q.id] = answer(q.id); });

    const saved = await savePreconsultation({
        patient_name: patientSel.options[patientSel.selectedIndex].text,
        vaccine: vaccineSel.value,
        answers: answers,
        allergies: document.getElementById('allergies').value.trim(),
        medications: document.getElementById('medications').value.trim(),
        notes: document.getElementById('notes').value.trim(),
        submitted_at: new Date().toISOString()
    });

    renderResult(saved, buildFlags(answers));
    renderHistory();
});

resultArea.addEventListener('click', function (e) {
    if (e.target.id !== 'anotherBtn') return;
    formEl.reset();
    renderQuestions();
    resultArea.classList.add('d-none');
    formEl.classList.remove('d-none');
});

(async function init() {
    const user = await getCurrentUser();
    if (!user) {
        window.location.href = 'login.html?next=' + encodeURIComponent('precheck.html');
        return;
    }
    const children = await getChildren();
    patientSel.innerHTML = '<option value="self">Myself</option>' + children.map(function (c) {
        return '<option value="child-' + esc(c.id) + '">' + esc(c.first_name) + ' (child)</option>';
    }).join('');
    vaccineSel.innerHTML = '<option value="">Not sure yet</option>' + VACCINE_NAMES.map(function (n) {
        return '<option value="' + esc(n) + '">' + esc(n) + '</option>';
    }).join('');

    const wanted = new URLSearchParams(window.location.search).get('vaccine');
    if (wanted && VACCINE_NAMES.indexOf(wanted) !== -1) vaccineSel.value = wanted;

    renderQuestions();
    renderHistory();
})();

async function getCurrentUser() {
    return VaxAuth.getUser();
}
