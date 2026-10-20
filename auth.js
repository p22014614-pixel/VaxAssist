(function () {
    const KEY = 'vaxUser';

    function read() {
        try { return JSON.parse(localStorage.getItem(KEY)); } catch (e) { return null; }
    }

    function write(user) {
        try { localStorage.setItem(KEY, JSON.stringify(user)); } catch (e) {}
    }

    function clear() {
        try { localStorage.removeItem(KEY); } catch (e) {}
    }

    window.VaxAuth = {
        getUser: read,

        login: function (user) {
            write(user);
            document.documentElement.classList.add('logged-in');
        },

        logout: function () {
            clear();
            document.documentElement.classList.remove('logged-in');
            window.location.href = 'index.html';
        },

        safeNext: function (next, fallback) {
            return /^[a-z0-9_-]+\.html(\?[A-Za-z0-9%&=._-]*)?$/i.test(next || '') ? next : fallback;
        }
    };

    if (read()) document.documentElement.classList.add('logged-in');

    document.addEventListener('DOMContentLoaded', function () {
        const user = read();
        document.querySelectorAll('[data-user-name]').forEach(function (el) {
            el.textContent = user ? user.first_name : '';
        });
    });

    document.addEventListener('click', function (e) {
        if (e.target.closest('[data-logout]')) {
            e.preventDefault();
            window.VaxAuth.logout();
        }
    });
})();
