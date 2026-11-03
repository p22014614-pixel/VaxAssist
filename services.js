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

function item(v) {
    const note = v.category === 'Travel vaccines' ? '<div class="catalogue-note">Best booked ' + esc(v.lead_days) + ' days before you travel</div>' : '';
    return '<div class="catalogue-item">' +
        '<div><div class="catalogue-name">' + esc(v.name) + '</div>' + note + '</div>' +
        '<div class="catalogue-side"><span class="catalogue-price">RM ' + esc(v.price.toFixed(2)) + '</span>' +
        '<a class="btn btn-sm appointment-btn" href="' + esc(bookHref(v)) + '">Book</a></div>' +
        '</div>';
}

function render(vaccines) {
    const groups = {};
    vaccines.forEach(function (v) {
        (groups[v.category] = groups[v.category] || []).push(v);
    });

    catalogue.innerHTML = CATEGORY_ORDER.filter(function (name) { return groups[name]; }).map(function (name) {
        return '<div class="catalogue-group"><h3>' + esc(name) + '</h3>' +
            '<div class="catalogue-list">' + groups[name].map(item).join('') + '</div></div>';
    }).join('');
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
