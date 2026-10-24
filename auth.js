(function () {
    const KEY = 'vaxUser';
    let csrf = null;

    // XAMPP serves both the pages and /api on the same origin. Only the VS Code
    // preview ports need to forward requests to the PHP development server.
    const previewPorts = ['3000', '5500'];
    const API_BASE = (location.protocol === 'http:' && previewPorts.includes(location.port))
        ? location.protocol + '//' + location.hostname + ':8000/'
        : '';

    function read() {
        try { return JSON.parse(localStorage.getItem(KEY)); } catch (e) { return null; }
    }

    function write(user) {
        try { localStorage.setItem(KEY, JSON.stringify(user)); } catch (e) {}
    }

    function clear() {
        try { localStorage.removeItem(KEY); } catch (e) {}
    }

    function showUser(user) {
        document.documentElement.classList.toggle('logged-in', !!user);
        document.querySelectorAll('[data-user-name]').forEach(function (el) {
            el.textContent = user ? user.first_name : '';
        });
    }

    function showUnread(count) {
        document.querySelectorAll('[data-unread-messages]').forEach(function (el) {
            el.textContent = count;
            el.hidden = !count;
        });
        document.querySelectorAll('[data-unread-dot]').forEach(function (el) {
            el.hidden = !count;
        });
    }

    function applyUser(user) {
        if (user) write(user); else clear();
        showUser(user);
    }

    // Dev-only: VS Code's embedded Live Preview (port 3000) refuses session cookies,
    // so there the session id travels in a header instead.
    const HEADER_SESSION = location.port === '3000';
    let devSession = null;
    try { devSession = sessionStorage.getItem('vaxDevSession') || localStorage.getItem('vaxDevSession'); } catch (e) {}

    function devHeaders(headers) {
        if (HEADER_SESSION && devSession) headers['X-Dev-Session'] = devSession;
        return headers;
    }

    async function parse(response) {
        if (response.status === 204 || response.status === 202) {
            return {};
        }
        const sid = response.headers.get('X-Dev-Session');
        if (HEADER_SESSION && sid) {
            devSession = sid;
            try { sessionStorage.setItem('vaxDevSession', sid); localStorage.setItem('vaxDevSession', sid); } catch (e) {}
        }
        let json;
        try { json = await response.json(); } catch (e) { json = { ok: false, error: 'Unexpected response from the server.' }; }
        if (!response.ok) {
            const err = new Error(json.error || 'Something went wrong. Please try again.');
            err.status = response.status;
            err.fields = json.fields || {};
            throw err;
        }
        return json;
    }

    let sessionPromise = null;

    function loadSession(force) {
        if (!force && sessionPromise) return sessionPromise;
        const request = Api.get('api/session').then(function (session) {
            csrf = session.csrf;
            return session;
        });
        let wrappedRequest;
        wrappedRequest = request.catch(function (err) {
            if (sessionPromise === wrappedRequest) sessionPromise = null;
            throw err;
        });
        sessionPromise = wrappedRequest;
        return sessionPromise;
    }

    async function send(method, url, data) {
        if (!csrf) {
            try {
                await (sessionPromise || loadSession());
            } catch (e) {
                await loadSession();
            }
        }

        function once() {
            return fetch(API_BASE + url, {
                method: method,
                credentials: 'include',
                headers: devHeaders({ 'Accept': 'application/json', 'Content-Type': 'application/json', 'X-CSRF-Token': csrf }),
                body: JSON.stringify(data || {})
            }).then(parse);
        }

        try {
            return await once();
        } catch (err) {
            // The security token went stale (for example the session was reset): get a new one and retry once.
            if (err.status !== 403) throw err;
            await loadSession(true);
            return await once();
        }
    }

    const Api = {
        get: async function (url) {
            return parse(await fetch(API_BASE + url, { credentials: 'include', headers: devHeaders({ 'Accept': 'application/json' }) }));
        },
        post: function (url, data) { return send('POST', url, data); },
        put: function (url, data) { return send('PUT', url, data); },
        patch: function (url, data) { return send('PATCH', url, data); },
        delete: function (url) { return send('DELETE', url); }
    };

    window.VaxApi = Api;

    window.VaxAuth = {
        getUser: read,

        getDashboardForRole: function (role) {
            return role === 'doctor' ? 'doctor_dashboard.html' : role === 'admin' ? 'admin_dashboard.html' : 'patient_dashboard.html';
        },

        fetchUser: async function () {
            try {
                const session = await loadSession();
                applyUser(session.user);
                showUnread(session.user ? session.unread_messages || 0 : 0);
                return session.user;
            } catch (e) {
                // Cached browser state is only a display hint; the server session is authoritative.
                applyUser(null);
                showUnread(0);
                return null;
            }
        },

        login: async function (email, password) {
            const result = await Api.post('api/session', { email: email, password: password });
            csrf = result.csrf;
            sessionPromise = Promise.resolve({ user: result.user, csrf: result.csrf, unread_messages: 0 });
            applyUser(result.user);
            return result.user;
        },

        logout: async function () {
            try { await Api.delete('api/session'); } catch (e) {}
            applyUser(null);
            window.location.href = 'login.html';
        },

        setUnread: showUnread,

        safeNext: function (next, fallback, role) {
            if (!/^[a-z0-9_-]+\.html(\?[A-Za-z0-9%&=._-]*)?$/i.test(next || '')) return fallback;
            const page = next.split('?')[0].toLowerCase();
            if (role === 'doctor' && !page.startsWith('doctor_')) return fallback;
            if (role === 'patient' && (page.startsWith('doctor_') || page.startsWith('admin_'))) return fallback;
            if (role === 'patient' && !['patient_dashboard.html', 'booking.html', 'appointments.html', 'vaccinations.html', 'precheck.html', 'receipts.html', 'reviews.html', 'messages.html', 'notifications.html', 'profile.html', 'planner.html'].includes(page)) return fallback;
            if (role === 'admin' && !page.startsWith('admin_')) return fallback;
            return next;
        }
    };

    if (read()) document.documentElement.classList.add('logged-in');

    document.addEventListener('DOMContentLoaded', function () {
        showUser(read());
        window.VaxAuth.fetchUser().then(function (user) {
            const requiredRole = document.body.dataset.requireRole;
            if (requiredRole && (!user || user.role !== requiredRole)) {
                if (user) {
                    location.replace(window.VaxAuth.getDashboardForRole(user.role));
                } else {
                    const next = encodeURIComponent(location.pathname.split('/').pop() + location.search);
                    location.replace('login.html?next=' + next);
                }
            }
        });
    });

    document.addEventListener('click', function (e) {
        if (e.target.closest('[data-logout]')) {
            e.preventDefault();
            window.VaxAuth.logout();
        }
    });
})();
