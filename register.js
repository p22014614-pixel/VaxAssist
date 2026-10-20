if (VaxAuth.getUser()) window.location.href = "index.html";

const form = document.getElementById("registerForm");
const password = document.getElementById("password");
const confirmPassword = document.getElementById("confirmPassword");
const dob = document.getElementById("dob");

dob.max = new Date().toISOString().split("T")[0];

document.getElementById("togglePw").addEventListener("click", function () {
    const hidden = password.type === "password";
    password.type = hidden ? "text" : "password";
    this.textContent = hidden ? "Hide" : "Show";
    this.setAttribute("aria-label", hidden ? "Hide password" : "Show password");
});

form.addEventListener("submit", function (e) {
    e.preventDefault();

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
