VaxAuth.fetchUser().then(function (user) {
    if (user) window.location.replace(VaxAuth.getDashboardForRole(user.role));
});

const form = document.getElementById("registerForm");
const password = document.getElementById("password");
const confirmPassword = document.getElementById("confirmPassword");
const dob = document.getElementById("dob");
const registerError = document.getElementById("registerError");

dob.max = new Date(Date.now() - new Date().getTimezoneOffset() * 60000).toISOString().split("T")[0]; // local date, not UTC

document.getElementById("togglePw").addEventListener("click", function () {
    const hidden = password.type === "password";
    password.type = hidden ? "text" : "password";
    this.textContent = hidden ? "Hide" : "Show";
    this.setAttribute("aria-label", hidden ? "Hide password" : "Show password");
});

form.addEventListener("submit", async function (e) {
    e.preventDefault();
    registerError.classList.add("d-none");

    confirmPassword.setCustomValidity(
        confirmPassword.value === password.value ? "" : "Passwords don't match."
    );

    let valid = true;
    form.querySelectorAll("input").forEach(function (input) {
        const ok = input.checkValidity();
        input.classList.toggle("is-invalid", !ok);
        if (!ok) valid = false;
    });

    if (!valid) return;

    const button = form.querySelector("button[type=submit]");
    button.disabled = true;

    try {
        await VaxApi.post("api/patients", {
            first_name: form.elements.first_name.value.trim(),
            last_name: form.elements.last_name.value.trim(),
            email: form.elements.email.value.trim(),
            phone: form.elements.phone.value.trim(),
            dob: form.elements.dob.value,
            password: password.value
        });
    } catch (err) {
        Object.keys(err.fields || {}).forEach(function (name) {
            if (form.elements[name]) form.elements[name].classList.add("is-invalid");
        });
        registerError.textContent = err.message;
        registerError.classList.remove("d-none");
        button.disabled = false;
        return;
    }

    document.getElementById("successBox").style.display = "block";
    setTimeout(function () {
        window.location.href = "login.html" + window.location.search;
    }, 1500);
});

form.querySelectorAll("input").forEach(function (input) {
    input.addEventListener("input", function () {
        if (input === password) {
            confirmPassword.setCustomValidity(
                confirmPassword.value === password.value ? "" : "Passwords don't match."
            );
        }
        if (input === confirmPassword) {
            input.setCustomValidity(
                input.value === password.value ? "" : "Passwords don't match."
            );
        }
        if (input.classList.contains("is-invalid") && input.checkValidity()) {
            input.classList.remove("is-invalid");
        }
    });
});
