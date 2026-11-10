async function getCurrentUser() {
    return VaxAuth.fetchUser();
}

async function getProfile() {
    return (await VaxApi.get('api/me')).profile;
}

async function saveProfile(data) {
    return VaxApi.put('api/me', data);
}

async function getHealthProfile() {
    return (await VaxApi.get('api/me/health')).health;
}

async function saveHealthProfile(data) {
    return VaxApi.put('api/me/health', data);
}

async function getChildren() {
    return (await VaxApi.get('api/children')).children;
}

async function addChild(child) {
    return VaxApi.post('api/children', child);
}

async function deleteChild(id) {
    return VaxApi.delete('api/children/' + encodeURIComponent(id));
}

async function changePassword(current, next) {
    return VaxApi.put('api/me/password', { current: current, new: next });
}

const reduceMotion = !!(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches);
const RING_LENGTH = 226.2;      // 2 * PI * r (r = 36)
const MAX_TAGS = 20;

let profile = {};
let health = { allergies: [], conditions: [], medications: [] };
let children = [];

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

function val(id) { return document.getElementById(id).value.trim(); }

function showError(id, message) {
    const box = document.getElementById(id);
    box.textContent = message;
    box.classList.remove('d-none');
    box.scrollIntoView({ behavior: 'smooth', block: 'center' });
}

// Shows the server's own field message (for example a bad phone number) when it sent one.
function apiMessage(err, fallback) {
    if (!err.status || err.status >= 500) return fallback;
    const fields = err.fields ? Object.values(err.fields) : [];
    return fields.length ? fields[0] : err.message;
}

function hideError(id) { document.getElementById(id).classList.add('d-none'); }

let toastTimer = null;
function toast(message) {
    const t = document.getElementById('toast');
    t.textContent = message;
    t.classList.add('show');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(function () { t.classList.remove('show'); }, 3200);
}

function ageText(dob) {
    const b = parseISO(dob), n = new Date();
    let months = (n.getFullYear() - b.getFullYear()) * 12 + (n.getMonth() - b.getMonth());
    if (n.getDate() < b.getDate()) months--;
    if (months < 1) return 'Newborn';
    if (months < 24) return months + (months === 1 ? ' month old' : ' months old');
    return Math.floor(months / 12) + ' years old';
}

function niceDate(s) {
    return parseISO(s).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' });
}

function bmiOf(h, w) {
    if (!h || !w) return null;
    return w / Math.pow(h / 100, 2);
}

function bmiLabel(b) {
    if (b < 18.5) return 'Underweight range';
    if (b < 25) return 'Healthy range';
    if (b < 30) return 'Overweight range';
    return 'Obese range';
}

function completion() {
    const checks = [
        profile.first_name, profile.last_name, profile.phone, profile.dob, profile.gender,
        profile.address, profile.emergency_contact_name, profile.emergency_contact_phone,
        health.blood_type, health.height_cm && health.weight_kg,
        (health.allergies && health.allergies.length) || health.no_known_allergies
    ];
    const done = checks.filter(Boolean).length;
    return Math.round(done / checks.length * 100);
}

function updateHeader() {
    const first = profile.first_name || '', last = profile.last_name || '';
    document.getElementById('fullName').textContent = (first + ' ' + last).trim() || 'Your profile';
    document.getElementById('emailLine').textContent = profile.email || '';
    document.getElementById('avatar').textContent = ((first[0] || '') + (last[0] || '')).toUpperCase() || '?';

    const pct = completion();
    document.getElementById('ringPct').textContent = pct + '%';
    document.getElementById('ringBar').style.strokeDashoffset = RING_LENGTH * (1 - pct / 100);
    document.getElementById('ringText').textContent = pct === 100
        ? 'Your profile is complete. Thank you!'
        : 'Complete your profile so clinics have the details they need.';
}

const tabButtons = document.querySelectorAll('.tab-btn');

function showTab(name) {
    tabButtons.forEach(function (b) {
        const on = b.dataset.tab === name;
        b.classList.toggle('active', on);
        b.setAttribute('aria-selected', on ? 'true' : 'false');
    });
    ['personal', 'health', 'children', 'security'].forEach(function (n) {
        document.getElementById('panel-' + n).classList.toggle('show', n === name);
    });
}
tabButtons.forEach(function (b) {
    b.addEventListener('click', function () { showTab(b.dataset.tab); });
});

function fillPersonal() {
    ['first_name', 'last_name', 'email', 'phone', 'dob', 'gender', 'address',
     'emergency_contact_name', 'emergency_contact_phone'].forEach(function (f) {
        document.getElementById(f).value = profile[f] || '';
    });
    document.getElementById('dob').max = daysFromToday(0);
}

document.getElementById('personalForm').addEventListener('submit', async function (e) {
    e.preventDefault();
    hideError('personalError');

    const data = {
        first_name: val('first_name'), last_name: val('last_name'), phone: val('phone'),
        dob: val('dob'), gender: val('gender'), address: val('address'),
        emergency_contact_name: val('emergency_contact_name'), emergency_contact_phone: val('emergency_contact_phone')
    };
    const phoneOk = /^[0-9+\s-]{8,15}$/;   // same rule the server uses

    if (!data.first_name || !data.last_name) return showError('personalError', 'Please enter your first and last name.');
    if (!phoneOk.test(data.phone)) return showError('personalError', 'Please enter a valid phone number.');
    if (!data.dob) return showError('personalError', 'Please enter your date of birth.');
    if (data.dob > daysFromToday(0)) return showError('personalError', 'Your date of birth cannot be in the future.');
    if (data.dob < daysFromToday(-365 * 120)) return showError('personalError', 'Please check your date of birth.');
    if (data.emergency_contact_phone && !phoneOk.test(data.emergency_contact_phone)) {
        return showError('personalError', 'Please enter a valid emergency contact phone number.');
    }

    const btn = document.getElementById('personalBtn');
    btn.disabled = true; btn.textContent = 'Saving...';
    try {
        await saveProfile(data);
        Object.assign(profile, data);
        updateHeader();
        toast('Personal details saved');
    } catch (err) {
        showError('personalError', apiMessage(err, 'Sorry, we could not save your details. Please try again.'));
    }
    btn.disabled = false; btn.textContent = 'Save changes';
});

const TAG_BOXES = { allergies: 'allergiesBox', conditions: 'conditionsBox', medications: 'medicationsBox' };
const TAG_EMPTY = {
    allergies: 'No allergies added', conditions: 'No conditions added', medications: 'No medications added'
};

function renderTags(kind) {
    const box = document.getElementById(TAG_BOXES[kind]);
    const items = health[kind];
    box.innerHTML = items.length
        ? items.map(function (t, i) {
            return '<span class="tag' + (kind === 'allergies' ? ' allergy' : '') + '">' + esc(t) +
                '<button type="button" data-remove="' + kind + '" data-index="' + i + '" aria-label="Remove ' + esc(t) + '">&times;</button></span>';
        }).join('')
        : '<span class="tag-empty">' + TAG_EMPTY[kind] + '</span>';
}

function syncAllergyState() {
    const none = document.getElementById('no_known_allergies').checked;
    document.getElementById('allergyInput').disabled = none;
    document.querySelector('[data-add="allergies"]').disabled = none;
    document.getElementById('allergiesBox').style.opacity = none ? '0.4' : '1';
}

function addTag(kind, inputId) {
    const input = document.getElementById(inputId);
    const text = input.value.trim().replace(/\s+/g, ' ');
    if (!text) return;
    hideError('healthError');
    if (health[kind].length >= MAX_TAGS) return showError('healthError', 'You can add up to ' + MAX_TAGS + ' items in each list.');
    const exists = health[kind].some(function (t) { return t.toLowerCase() === text.toLowerCase(); });
    if (!exists) health[kind].push(text);
    input.value = '';
    renderTags(kind);
}

function fillHealth() {
    document.getElementById('blood_type').value = health.blood_type || '';
    document.getElementById('height_cm').value = health.height_cm || '';
    document.getElementById('weight_kg').value = health.weight_kg || '';
    document.getElementById('no_known_allergies').checked = !!health.no_known_allergies;
    renderTags('allergies'); renderTags('conditions'); renderTags('medications');
    syncAllergyState();
    updateBmi();
}

function updateBmi() {
    const b = bmiOf(parseFloat(document.getElementById('height_cm').value), parseFloat(document.getElementById('weight_kg').value));
    document.getElementById('bmiBox').innerHTML = b
        ? '<strong>' + b.toFixed(1) + '</strong><span>' + esc(bmiLabel(b)) + '</span>'
        : 'Enter height and weight';
}

document.getElementById('height_cm').addEventListener('input', updateBmi);
document.getElementById('weight_kg').addEventListener('input', updateBmi);
document.getElementById('no_known_allergies').addEventListener('change', function () {
    if (this.checked) { health.allergies = []; renderTags('allergies'); }
    syncAllergyState();
});

document.getElementById('panel-health').addEventListener('click', function (e) {
    const add = e.target.closest('button[data-add]');
    if (add) { addTag(add.dataset.add, add.dataset.input); return; }
    const rem = e.target.closest('button[data-remove]');
    if (rem) {
        health[rem.dataset.remove].splice(Number(rem.dataset.index), 1);
        renderTags(rem.dataset.remove);
    }
});

['allergyInput', 'conditionInput', 'medicationInput'].forEach(function (id) {
    document.getElementById(id).addEventListener('keydown', function (e) {
        if (e.key !== 'Enter') return;
        e.preventDefault();
        const btn = document.querySelector('[data-input="' + id + '"]');
        addTag(btn.dataset.add, id);
    });
});

document.getElementById('healthForm').addEventListener('submit', async function (e) {
    e.preventDefault();
    hideError('healthError');

    [['allergies', 'allergyInput'], ['conditions', 'conditionInput'], ['medications', 'medicationInput']].forEach(function (p) {
        if (document.getElementById(p[1]).value.trim() && !document.getElementById(p[1]).disabled) addTag(p[0], p[1]);
    });

    const h = parseFloat(val('height_cm')), w = parseFloat(val('weight_kg'));
    if (val('height_cm') && (isNaN(h) || h < 30 || h > 250)) return showError('healthError', 'Height must be between 30 and 250 cm.');
    if (val('weight_kg') && (isNaN(w) || w < 2 || w > 400)) return showError('healthError', 'Weight must be between 2 and 400 kg.');

    const data = {
        blood_type: val('blood_type'),
        height_cm: val('height_cm') ? h : null,
        weight_kg: val('weight_kg') ? w : null,
        no_known_allergies: document.getElementById('no_known_allergies').checked,
        allergies: health.allergies.slice(), conditions: health.conditions.slice(), medications: health.medications.slice()
    };

    const btn = document.getElementById('healthBtn');
    btn.disabled = true; btn.textContent = 'Saving...';
    try {
        await saveHealthProfile(data);
        health = data;
        updateHeader();
        toast('Health profile saved');
    } catch (err) {
        showError('healthError', apiMessage(err, 'Sorry, we could not save your health profile. Please try again.'));
    }
    btn.disabled = false; btn.textContent = 'Save health profile';
});

function renderChildren() {
    const list = document.getElementById('childList');
    list.innerHTML = children.length
        ? children.map(function (c, i) {
            return '<div class="child-card" style="animation-delay:' + (i * 80) + 'ms" data-child="' + esc(c.id) + '">' +
                '<div class="child-avatar" aria-hidden="true">&#129490;</div>' +
                '<div><div class="name">' + esc(c.first_name) + '</div>' +
                '<div class="meta">' + esc(ageText(c.dob)) + ' &middot; born ' + esc(niceDate(c.dob)) + '</div></div>' +
                '<a class="btn-remove ms-auto text-decoration-none" style="color:#126a78;border-color:#b9d4d9" href="vaccinations.html?patient=' + encodeURIComponent(c.first_name) + '">Records</a>' +
                '<button type="button" class="btn-remove" style="margin-left:0" data-delete="' + esc(c.id) + '">Remove</button>' +
            '</div>';
        }).join('')
        : '<div class="empty-note">No children added yet.<br>Add one using the form to book vaccines for them.</div>';
}

document.getElementById('childList').addEventListener('click', async function (e) {
    const btn = e.target.closest('button[data-delete]');
    if (!btn) return;
    const child = children.find(function (c) { return String(c.id) === btn.dataset.delete; });
    if (!child) return;
    if (!window.confirm('Remove ' + child.first_name + ' from your profile?')) return;
    try {
        await deleteChild(child.id);
        const card = btn.closest('.child-card');
        if (card && !reduceMotion) card.classList.add('removing');
        setTimeout(function () {
            children = children.filter(function (c) { return c.id !== child.id; });
            renderChildren();
            toast(child.first_name + ' was removed');
        }, reduceMotion ? 0 : 350);
    } catch (err) {
        showError('childError', apiMessage(err, 'Sorry, we could not remove this child. Please try again.'));
    }
});

document.getElementById('childForm').addEventListener('submit', async function (e) {
    e.preventDefault();
    hideError('childError');
    const data = { first_name: val('child_first_name'), dob: val('child_dob'), gender: val('child_gender') };

    if (!data.first_name) return showError('childError', "Please enter your child's name.");
    if (!data.dob) return showError('childError', "Please enter your child's date of birth.");
    if (data.dob > daysFromToday(0)) return showError('childError', 'The birth date cannot be in the future.');
    if (data.dob < daysFromToday(-365 * 18)) return showError('childError', 'Children must be under 18. Adults can create their own account.');
    if (children.length >= 10) return showError('childError', 'You can save up to 10 children.');

    const btn = document.getElementById('childBtn');
    btn.disabled = true; btn.textContent = 'Adding...';
    try {
        const res = await addChild(data);
        children.push({ id: res.id, first_name: data.first_name, dob: data.dob, gender: data.gender });
        renderChildren();
        document.getElementById('childForm').reset();
        toast(data.first_name + ' was added');
    } catch (err) {
        showError('childError', apiMessage(err, 'Sorry, we could not add your child. Please try again.'));
    }
    btn.disabled = false; btn.textContent = 'Add child';
});

function strengthScore(pw) {
    let s = 0;
    if (pw.length >= 8) s++;
    if (pw.length >= 12) s++;
    if (/[a-z]/.test(pw) && /[A-Z]/.test(pw)) s++;
    if (/\d/.test(pw) && /[^A-Za-z0-9]/.test(pw)) s++;
    return pw.length < 8 ? Math.min(s, 1) : s;
}

document.getElementById('new_password').addEventListener('input', function () {
    const pw = this.value;
    const s = pw ? strengthScore(pw) : 0;
    const levels = [
        { w: '0%',   c: '#e8eef0', t: 'Type a new password' },
        { w: '25%',  c: '#d9534f', t: 'Weak' },
        { w: '50%',  c: '#e0a030', t: 'Fair' },
        { w: '75%',  c: '#5fb5c0', t: 'Good' },
        { w: '100%', c: '#167d8d', t: 'Strong' }
    ];
    const lv = pw ? levels[Math.max(1, s)] : levels[0];
    const bar = document.getElementById('strengthBar');
    bar.style.width = lv.w;
    bar.style.background = lv.c;
    document.getElementById('strengthText').textContent = lv.t;
});

document.getElementById('togglePw').addEventListener('click', function () {
    const input = document.getElementById('new_password');
    const show = input.type === 'password';
    input.type = show ? 'text' : 'password';
    this.textContent = show ? 'Hide' : 'Show';
});

document.getElementById('passwordForm').addEventListener('submit', async function (e) {
    e.preventDefault();
    hideError('passwordError');
    const current = document.getElementById('current_password').value;
    const next = document.getElementById('new_password').value;
    const confirm = document.getElementById('confirm_password').value;

    if (!current) return showError('passwordError', 'Please enter your current password.');
    if (next.length < 8) return showError('passwordError', 'Your new password must be at least 8 characters.');
    if (!/[A-Za-z]/.test(next) || !/\d/.test(next)) return showError('passwordError', 'Your new password needs both letters and numbers.');
    if (next === current) return showError('passwordError', 'Your new password must be different from the current one.');
    if (next !== confirm) return showError('passwordError', 'The new passwords do not match.');

    const btn = document.getElementById('passwordBtn');
    btn.disabled = true; btn.textContent = 'Updating...';
    try {
        await changePassword(current, next);
        document.getElementById('passwordForm').reset();
        document.getElementById('new_password').dispatchEvent(new Event('input'));
        toast('Password updated');
    } catch (err) {
        showError('passwordError', err.status && err.status < 500 ? err.message : 'Sorry, we could not update your password. Check your current password and try again.');
    }
    btn.disabled = false; btn.textContent = 'Update password';
});

(async function init() {
    const user = await getCurrentUser();
    if (!user) {
        window.location.href = 'login.html?next=' + encodeURIComponent('profile.html');
        return;
    }
    try {
        const loaded = await Promise.all([getProfile(), getHealthProfile(), getChildren()]);
        profile = loaded[0];
        health = loaded[1];
        children = loaded[2];
        fillPersonal();
        fillHealth();
        renderChildren();
        if (reduceMotion) updateHeader(); else setTimeout(updateHeader, 150);

        const tab = new URLSearchParams(window.location.search).get('tab');
        if (['personal', 'health', 'children', 'security'].indexOf(tab) !== -1) showTab(tab);
    } catch (err) {
        showError('personalError', 'Sorry, we could not load your profile. Please try again later.');
    }
})();
