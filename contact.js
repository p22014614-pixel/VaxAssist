const form = document.getElementById('contactForm');
const formCard = document.getElementById('formCard');
const successCard = document.getElementById('successCard');
const formError = document.getElementById('formError');
const sendBtn = document.getElementById('sendBtn');
const message = document.getElementById('message');
const counter = document.getElementById('counter');

function showError(text) {
    formError.textContent = text;
    formError.classList.remove('d-none');
}

message.addEventListener('input', function () {
    counter.textContent = message.value.length + ' / 1000';
});

document.getElementById('againBtn').addEventListener('click', function () {
    form.reset();
    counter.textContent = '0 / 1000';
    fillFromAccount();
    successCard.classList.add('d-none');
    formCard.classList.remove('d-none');
});

form.addEventListener('submit', async function (e) {
    e.preventDefault();
    formError.classList.add('d-none');

    let valid = true;
    form.querySelectorAll('input, select, textarea').forEach(function (field) {
        field.value = field.value.trim();
        const ok = field.checkValidity() && (field.name !== 'message' || field.value.length >= 10);
        field.classList.toggle('is-invalid', !ok);
        if (!ok) valid = false;
    });
    if (!valid) return;

    sendBtn.disabled = true;
    try {
        await VaxApi.post('api/contact-messages', {
            name: form.elements.name.value,
            email: form.elements.email.value,
            subject: form.elements.subject.value,
            message: form.elements.message.value
        });
    } catch (err) {
        Object.keys(err.fields || {}).forEach(function (name) {
            if (form.elements[name]) form.elements[name].classList.add('is-invalid');
        });
        showError(err.status && err.status < 500 ? err.message : 'Sorry, your message could not be sent. Please try again.');
        sendBtn.disabled = false;
        return;
    }

    sendBtn.disabled = false;
    formCard.classList.add('d-none');
    successCard.classList.remove('d-none');
});

async function fillFromAccount() {
    const user = await VaxAuth.fetchUser();
    if (!user) return;
    if (!form.elements.name.value) form.elements.name.value = (user.first_name + ' ' + user.last_name).trim();
    if (!form.elements.email.value) form.elements.email.value = user.email;
}

fillFromAccount();
