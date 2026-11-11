async function getVaccines() {
    return (await VaxApi.get('api/vaccines')).vaccines;
}

const catalogue = document.getElementById('catalogue');

const CATEGORY_ORDER = ['Travel vaccines', 'Childhood vaccines', 'Boosters', 'Consultation'];

function esc(text) {
    const div = document.createElement('div');
    div.textContent = text == null ? '' : text;
    return div.innerHTML;
}

function bookHref(v) {
    return 'booking.html?vaccine=' + encodeURIComponent(v.name) + (v.doctor_id ? '&doctor_id=' + encodeURIComponent(v.doctor_id) : '');
}

const SEARCH_ICON = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/></svg>';

const ICONS = {
    'Travel vaccines': '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z"/></svg>',
    'Childhood vaccines': '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><path d="M8 14s1.5 2 4 2 4-2 4-2M9 9h.01M15 9h.01"/></svg>',
    'Boosters': '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>',
    'Consultation': '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"/></svg>'
};

const TAB_LABEL = { 'Travel vaccines': 'Travel', 'Childhood vaccines': 'Childhood', 'Boosters': 'Boosters', 'Consultation': 'Consultation' };
const CLASSES = { 'Travel vaccines': 'cat-travel', 'Childhood vaccines': 'cat-childhood', 'Boosters': 'cat-boosters', 'Consultation': 'cat-consultation' };

let allVaccines = [];
let activeTab = CATEGORY_ORDER[0];
let query = '';

function item(v, i) {
    const note = v.category === 'Travel vaccines' ? '<div class="catalogue-note">Best booked ' + esc(v.lead_days) + ' days before you travel</div>' : '';
    return '<div class="catalogue-item ' + CLASSES[v.category] + '" style="--i:' + Math.min(i || 0, 9) + '">' +
        '<span class="catalogue-icon">' + ICONS[v.category] + '</span>' +
        '<div class="catalogue-text"><div class="catalogue-name">' + esc(v.name) + '</div>' + note + '</div>' +
        '<div class="catalogue-price"><small>RM</small>' + esc(v.price.toFixed(2)) + '</div>' +
        '<a class="catalogue-book" href="' + esc(bookHref(v)) + '" aria-label="Book ' + esc(v.name) + '"><span>Book</span>' + ARROW_ICON + '</a>' +
        '</div>';
}

function visibleList() {
    const q = query.trim().toLowerCase();
    if (q) return allVaccines.filter(function (v) { return v.name.toLowerCase().indexOf(q) !== -1; });
    return allVaccines.filter(function (v) { return v.category === activeTab; });
}

const ARROW_ICON = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14M13 6l6 6-6 6"/></svg>';

// animate = true on first paint and tab switches; typing in the search box updates without replaying the motion.
function renderList(animate) {
    const list = visibleList();
    const hint = query.trim() ? '<div class="catalogue-hint">Showing ' + list.length + ' result' + (list.length === 1 ? '' : 's') + ' from all vaccines</div>' : '';
    const body = document.getElementById('catalogueBody');
    body.classList.toggle('animate', !!animate);
    body.innerHTML = list.length
        ? hint + '<div class="catalogue-list">' + list.map(function (v, i) { return item(v, i); }).join('') + '</div>'
        : '<div class="catalogue-empty">No vaccines match your search.</div>';
}

function buildTabs() {
    const counts = {};
    allVaccines.forEach(function (v) { counts[v.category] = (counts[v.category] || 0) + 1; });
    document.getElementById('catalogueTabs').innerHTML = '<span class="catalogue-pill" aria-hidden="true"></span>' +
        CATEGORY_ORDER.filter(function (n) { return counts[n]; }).map(function (n) {
            return '<button type="button" role="tab" class="catalogue-tab" data-tab="' + esc(n) + '">' +
                ICONS[n] + '<span>' + esc(TAB_LABEL[n]) + '</span><span class="n">' + counts[n] + '</span></button>';
        }).join('');
}

// Sets the selected tab directly, then slides the highlight under it. The state never waits on the animation.
function updateTabs() {
    const holder = document.getElementById('catalogueTabs');
    const pill = holder.querySelector('.catalogue-pill');
    let active = null;
    holder.querySelectorAll('.catalogue-tab').forEach(function (tab) {
        const on = !query.trim() && tab.getAttribute('data-tab') === activeTab;
        tab.classList.toggle('active', on);
        tab.setAttribute('aria-selected', on ? 'true' : 'false');
        if (on) active = tab;
    });
    if (active) {
        pill.style.width = active.offsetWidth + 'px';
        pill.style.height = active.offsetHeight + 'px';
        pill.style.transform = 'translate(' + active.offsetLeft + 'px, ' + active.offsetTop + 'px)';
        pill.classList.add('on');
    } else {
        pill.classList.remove('on');
    }
}

function render(vaccines) {
    allVaccines = vaccines;
    catalogue.innerHTML =
        '<div class="catalogue-panel">' +
        '<div class="catalogue-bar"><div class="catalogue-tabs" id="catalogueTabs" role="tablist" aria-label="Vaccine type"></div>' +
        '<label class="catalogue-search">' + SEARCH_ICON + '<input type="search" id="catalogueSearch" placeholder="Search vaccines" aria-label="Search vaccines"></label></div>' +
        '<div id="catalogueBody"></div></div>';
    buildTabs();
    const pill = document.querySelector('.catalogue-pill');
    pill.classList.add('no-t');
    updateTabs();
    requestAnimationFrame(function () { requestAnimationFrame(function () { pill.classList.remove('no-t'); }); });
    renderList(true);

    document.getElementById('catalogueTabs').addEventListener('click', function (event) {
        const tab = event.target.closest('[data-tab]');
        if (!tab) return;
        activeTab = tab.getAttribute('data-tab');
        query = '';
        document.getElementById('catalogueSearch').value = '';
        updateTabs();
        renderList(true);
    });
    document.getElementById('catalogueSearch').addEventListener('input', function (event) {
        query = event.target.value;
        updateTabs();
        renderList(false);
    });
    window.addEventListener('resize', updateTabs);
    if (document.fonts && document.fonts.ready) document.fonts.ready.then(updateTabs);
}

(async function init() {
    try {
        const vaccines = await getVaccines();
        if (!vaccines.length) {
            catalogue.innerHTML = '<p class="text-center text-secondary">Our price list is not available yet.</p>';
            return;
        }
        render(vaccines);
    } catch (err) {
        catalogue.innerHTML = '<p class="text-center text-secondary">Sorry, we could not load the price list. Please try again later.</p>';
    }
})();
