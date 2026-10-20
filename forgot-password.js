const form = document.getElementById("forgotForm");
const email = document.getElementById("email");
const sentBox = document.getElementById("sentBox");

async function requestPasswordReset(address) {
    return true;
}

form.addEventListener("submit", async function (e) {
    e.preventDefault();

    email.classList.toggle("is-invalid", !email.checkValidity());
    if (!email.checkValidity()) return;

    await requestPasswordReset(email.value.trim());
    sentBox.classList.remove("d-none");
    form.reset();
});
