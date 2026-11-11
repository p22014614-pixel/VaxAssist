// Reviews page.

// Asks the server who is signed in.
async function getCurrentUser() {
    return VaxAuth.fetchUser();
}

// Loads the visits that can be reviewed.
async function getCompletedVisits() {
    const appointments = (await VaxApi.get('api/appointments')).appointments;
    return appointments.filter(function (a) { return a.status === 'completed'; }).map(function (a) {
        return {
            id: a.id, doctor_name: a.doctor_name, date: a.appointment_date,
            service: a.vaccine_name + (a.child_name ? ' (' + a.child_name + ')' : '')
        };
    });
}

// Loads the patient's reviews.
async function getMyReviews() {
    return (await VaxApi.get('api/reviews')).reviews;
}

// Saves a review.
async function saveReview(visitId, review) {
    await VaxApi.put('api/appointments/' + encodeURIComponent(visitId) + '/review', { rating: review.rating, comment: review.comment });
    return review;
}

const visitList = document.getElementById('visitList');
const savedMsg = document.getElementById('savedMsg');

let visits = [];
let reviews = {};
let editing = {};
let draft = {};

// Escapes text so it is safe to put in HTML.
function esc(text) {
    const div = document.createElement('div');
    div.textContent = text == null ? '' : text;
    return div.innerHTML;
}

// Formats a date for display.
function niceDate(iso) {
    const p = iso.split('-');
    return new Date(Number(p[0]), Number(p[1]) - 1, Number(p[2]))
        .toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' });
}

// Builds the five star buttons.
function starButtons(visitId, value) {
    let html = '<div class="stars" role="radiogroup" aria-label="Rating">';
    for (let i = 1; i <= 5; i++) {
        html += '<button type="button" class="star-btn' + (i <= value ? ' on' : '') + '" data-visit="' + visitId + '" data-star="' + i +
            '" role="radio" aria-checked="' + (i === value) + '" aria-label="' + i + (i === 1 ? ' star' : ' stars') + '">&#9733;</button>';
    }
    return html + '</div>';
}

// Draws the visits with their review forms.
function render() {
    if (!visits.length) {
        visitList.innerHTML = '<div class="empty-box">You have no completed visits to review yet.</div>';
        return;
    }
    visitList.innerHTML = visits.map(function (v) {
        const r = reviews[v.id];
        const head = '<h3>' + esc(v.doctor_name) + '</h3><div class="review-meta">' + esc(v.service) + ' &middot; ' + esc(niceDate(v.date)) + '</div>';

        if (r && !editing[v.id]) {
            return '<div class="review-card">' + head +
                '<div class="done-stars" aria-label="' + r.rating + ' out of 5 stars">' + '&#9733;'.repeat(r.rating) + '<span style="color:#d3dde0">' + '&#9733;'.repeat(5 - r.rating) + '</span></div>' +
                (r.comment ? '<p class="done-comment">' + esc(r.comment) + '</p>' : '') +
                '<button type="button" class="edit-link" data-edit="' + v.id + '">Edit review</button></div>';
        }

        const current = draft[v.id] || r || { rating: 0, comment: '' };
        return '<div class="review-card">' + head + starButtons(v.id, current.rating) +
            '<textarea class="form-control" rows="3" maxlength="500" data-comment="' + v.id + '" placeholder="What went well? What could be better? (optional)">' + esc(current.comment) + '</textarea>' +
            '<div class="text-danger small mt-2 d-none" data-error="' + v.id + '">Please choose a star rating.</div>' +
            '<button type="button" class="btn appointment-btn mt-3" data-submit="' + v.id + '">Submit review</button></div>';
    }).join('');
}

// Keeps the comment as a draft.
visitList.addEventListener('input', function (e) {
    const box = e.target.closest('[data-comment]');
    if (!box) return;
    const id = Number(box.dataset.comment);
    const current = draft[id] || reviews[id] || { rating: 0 };
    draft[id] = { rating: current.rating, comment: box.value };
});

// Handles the stars, edit and submit buttons.
visitList.addEventListener('click', async function (e) {
    const star = e.target.closest('[data-star]');
    if (star) {
        const id = Number(star.dataset.visit);
        const box = visitList.querySelector('[data-comment="' + id + '"]');
        draft[id] = { rating: Number(star.dataset.star), comment: box ? box.value : '' };
        render();
        return;
    }
    const edit = e.target.closest('[data-edit]');
    if (edit) {
        editing[Number(edit.dataset.edit)] = true;
        render();
        return;
    }
    const submit = e.target.closest('[data-submit]');
    if (submit) {
        const id = Number(submit.dataset.submit);
        const box = visitList.querySelector('[data-comment="' + id + '"]');
        const rating = (draft[id] || reviews[id] || { rating: 0 }).rating;
        if (!rating) {
            visitList.querySelector('[data-error="' + id + '"]').classList.remove('d-none');
            return;
        }
        const errorBox = visitList.querySelector('[data-error="' + id + '"]');
        submit.disabled = true;
        try {
            reviews[id] = await saveReview(id, { rating: rating, comment: box.value.trim() });
        } catch (err) {
            errorBox.textContent = err.status && err.status < 500 ? err.message : 'Sorry, your review could not be saved. Please try again.';
            errorBox.classList.remove('d-none');
            submit.disabled = false;
            return;
        }
        delete draft[id];
        delete editing[id];
        render();
        savedMsg.classList.remove('d-none');
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
});

(async function init() {
    const user = await getCurrentUser();
    if (!user) {
        window.location.href = 'login.html?next=' + encodeURIComponent('reviews.html');
        return;
    }
    visits = await getCompletedVisits();
    reviews = await getMyReviews();
    render();
})();
