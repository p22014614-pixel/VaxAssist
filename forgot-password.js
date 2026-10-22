const form = document.getElementById("forgotForm");
const email = document.getElementById("email");
const sentBox = document.getElementById("sentBox");

async function requestPasswordReset(address) {
    return VaxApi.post("api/password-resets", { email: address });
}

form.addEventListener("submit", async function (e) {
    e.preventDefault();

    email.classList.toggle("is-invalid", !email.checkValidity());
    if (!email.checkValidity()) return;

    try {
        await requestPasswordReset(email.value.trim());
    } catch (err) {
        email.classList.add("is-invalid");
        return;
    }
    sentBox.classList.remove("d-none");
    form.reset();
});
