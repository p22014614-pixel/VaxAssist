// Login page.

(() => {
    'use strict';

    const form = document.getElementById('loginForm');
    const emailInput = document.getElementById('email');
    const passwordInput = document.getElementById('password');
    const submitButton = document.getElementById('submitButton');
    const statusBox = document.getElementById('loginStatus');
    const emailError = document.getElementById('emailError');
    const passwordError = document.getElementById('passwordError');
    const previewPorts = ['3000', '5500'];
    const apiBase = location.protocol === 'http:' && previewPorts.includes(location.port)
        ? `${location.protocol}//${location.hostname}:8000/`
        : '';
    const useHeaderSession = location.port === '3000';
    let devSession = null;
    let csrfToken = null;
    let sessionRequest = null;

    try {
        devSession = sessionStorage.getItem('vaxDevSession') || localStorage.getItem('vaxDevSession');
    } catch (error) {
    }

    // Shows a message above the form.
    function showStatus(message, type) {
        statusBox.textContent = message;
        statusBox.classList.toggle('info', type === 'info');
        statusBox.hidden = !message;
    }

    // Disables the form while logging in.
    function setBusy(busy) {
        submitButton.disabled = busy;
        submitButton.querySelector('.button-label').textContent = busy ? 'Signing in…' : 'Log in';
        emailInput.disabled = busy;
        passwordInput.disabled = busy;
    }

    // Chooses the dashboard page for a role.
    function destinationFor(user) {
        if (user.role === 'doctor') return 'doctor_dashboard.html';
        if (user.role === 'admin') return 'admin_Dashboard.html';
        if (user.role === 'patient') return 'patient_dashboard.html';
        throw new Error('Your account has no supported portal. Please contact the clinic.');
    }

    const PATIENT_PAGES = ['booking.html', 'appointments.html', 'vaccinations.html', 'precheck.html', 'receipts.html', 'reviews.html', 'messages.html', 'notifications.html', 'profile.html', 'planner.html'];
    // Uses the ?next page if it is allowed, otherwise the dashboard.
    function nextOrDefault(user) {
        const next = new URLSearchParams(location.search).get('next') || '';
        const page = next.split('?')[0].toLowerCase();
        const allowed = user.role === 'patient' && /^[a-z0-9_-]+\.html(\?[A-Za-z0-9%&=._-]*)?$/i.test(next) && PATIENT_PAGES.includes(page);
        return allowed ? next : destinationFor(user);
    }

    // Builds the request headers.
    function requestHeaders(extra) {
        const headers = Object.assign({ Accept: 'application/json' }, extra || {});
        if (useHeaderSession && devSession) headers['X-Dev-Session'] = devSession;
        return headers;
    }

    // Sends a request and turns failures into readable errors.
    async function request(path, options) {
        let response;
        try {
            response = await fetch(apiBase + path, Object.assign({
                credentials: 'include',
                cache: 'no-store'
            }, options || {}, { headers: requestHeaders(options && options.headers) }));
        } catch (error) {
            throw new Error('VaxAssist could not reach the login service. Check that the website and database server are running, then try again.');
        }

        const returnedSession = response.headers.get('X-Dev-Session');
        if (useHeaderSession && returnedSession) {
            devSession = returnedSession;
            try {
                sessionStorage.setItem('vaxDevSession', devSession);
                localStorage.setItem('vaxDevSession', devSession);
            } catch (error) {
            }
        }

        let payload = {};
        try { payload = await response.json(); } catch (error) {}
        if (!response.ok) {
            const failure = new Error(payload.error || 'We could not sign you in. Please try again.');
            failure.status = response.status;
            throw failure;
        }
        return payload;
    }

    // Asks the server for the current session and CSRF token.
    function loadSession(force) {
        if (!force && sessionRequest) return sessionRequest;
        sessionRequest = request('api/session').then((session) => {
            csrfToken = session.csrf || null;
            return session;
        }).catch((error) => {
            sessionRequest = null;
            throw error;
        });
        return sessionRequest;
    }

    // Clears the red error marks on the form.
    function clearValidation() {
        emailError.textContent = '';
        passwordError.textContent = '';
        emailInput.removeAttribute('aria-invalid');
        passwordInput.removeAttribute('aria-invalid');
    }

    // Checks the email and password fields.
    function validate() {
        clearValidation();
        let valid = true;
        if (!emailInput.value.trim() || !emailInput.validity.valid) {
            emailError.textContent = 'Enter a valid email address.';
            emailInput.setAttribute('aria-invalid', 'true');
            valid = false;
        }
        if (!passwordInput.value) {
            passwordError.textContent = 'Enter your password.';
            passwordInput.setAttribute('aria-invalid', 'true');
            valid = false;
        }
        return valid;
    }

    document.getElementById('togglePassword').addEventListener('click', function () {
        const reveal = passwordInput.type === 'password';
        passwordInput.type = reveal ? 'text' : 'password';
        this.textContent = reveal ? 'Hide' : 'Show';
        this.setAttribute('aria-label', reveal ? 'Hide password' : 'Show password');
        this.setAttribute('aria-pressed', String(reveal));
        passwordInput.focus();
    });

    form.addEventListener('submit', async (event) => {
        event.preventDefault();
        showStatus('', '');
        if (!validate()) return;

        setBusy(true);
        try {
            await loadSession();
            const submitLogin = () => request('api/session', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': csrfToken || '' },
                body: JSON.stringify({ email: emailInput.value.trim(), password: passwordInput.value })
            });

            let result;
            try {
                result = await submitLogin();
            } catch (error) {
                if (error.status !== 403) throw error;
                await loadSession(true);
                result = await submitLogin();
            }

            location.replace(nextOrDefault(result.user || {}));
        } catch (error) {
            showStatus(error.message || 'We could not sign you in. Check your details and try again.');
            setBusy(false);
        }
    });

    loadSession().then((session) => {
        if (session.user) {
            location.replace(nextOrDefault(session.user));
        }
    }).catch(() => {
    });
})();
