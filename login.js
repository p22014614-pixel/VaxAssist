if (VaxAuth.getUser()) window.location.href = "index.html";

const form = document.getElementById("loginForm");
const email = document.getElementById("email");
const password = document.getElementById("password");
const loginError = document.getElementById("loginError");

document.getElementById("togglePw").addEventListener("click", function () {
    const hidden = password.type === "password";
    password.type = hidden ? "text" : "password";
    this.textContent = hidden ? "Hide" : "Show";
    this.setAttribute("aria-label", hidden ? "Hide password" : "Show password");
});

form.addEventListener("submit", async function (e) {
    e.preventDefault();
    loginError.classList.add("d-none");

    email.classList.toggle("is-invalid", !email.checkValidity());
    password.classList.toggle("is-invalid", !password.checkValidity());

    if (!email.checkValidity() || !password.checkValidity()) return;

    const button = form.querySelector("button[type=submit]");
    button.disabled = true;

    try {
        await VaxAuth.login(email.value.trim(), password.value);
        const next = new URLSearchParams(window.location.search).get("next");
        window.location.href = VaxAuth.safeNext(next, "index.html");
    } catch (err) {
        loginError.textContent = err.message;
        loginError.classList.remove("d-none");
        button.disabled = false;
    }
});
