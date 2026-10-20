if (VaxAuth.getUser()) window.location.href = "index.html";

const form = document.getElementById("loginForm");
const email = document.getElementById("email");
const password = document.getElementById("password");

document.getElementById("togglePw").addEventListener("click", function () {
    const hidden = password.type === "password";
    password.type = hidden ? "text" : "password";
    this.textContent = hidden ? "Hide" : "Show";
    this.setAttribute("aria-label", hidden ? "Hide password" : "Show password");
});

form.addEventListener("submit", function (e) {
    e.preventDefault();

    email.classList.toggle("is-invalid", !email.checkValidity());
    password.classList.toggle("is-invalid", !password.checkValidity());

    if (!email.checkValidity() || !password.checkValidity()) return;

    VaxAuth.login({ id: 1, first_name: "Demo", last_name: "Patient", email: email.value.trim() });
    const next = new URLSearchParams(window.location.search).get("next");
    window.location.href = VaxAuth.safeNext(next, "index.html");
});
