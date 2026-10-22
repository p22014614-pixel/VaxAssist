const form = document.getElementById("resetForm");
const password = document.getElementById("password");
const confirmPassword = document.getElementById("confirmPassword");
const resetError = document.getElementById("resetError");
const doneBox = document.getElementById("doneBox");
const token = new URLSearchParams(window.location.search).get("token") || "";

form.addEventListener("submit", async function (e) {
    e.preventDefault();
    resetError.classList.add("d-none");

    confirmPassword.setCustomValidity(confirmPassword.value === password.value ? "" : "Passwords don't match.");
    password.classList.toggle("is-invalid", !password.checkValidity());
    confirmPassword.classList.toggle("is-invalid", !confirmPassword.checkValidity());
    if (!password.checkValidity() || !confirmPassword.checkValidity()) return;

    const button = form.querySelector("button[type=submit]");
    button.disabled = true;

    try {
        await VaxApi.put("api/password-resets/" + encodeURIComponent(token), { password: password.value });
    } catch (err) {
        resetError.textContent = err.status && err.status < 500 ? err.message : "Sorry, something went wrong. Please try again.";
        resetError.classList.remove("d-none");
        button.disabled = false;
        return;
    }

    doneBox.classList.remove("d-none");
    setTimeout(function () { window.location.href = "login.html"; }, 1500);
});
