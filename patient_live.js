// Live updates: pop-ups and badges on every page.

(function () {
    if (!window.VaxApi || !window.VaxAuth) return;

    const POLL_MS = 15000;
    const KEY = 'vaxLive';
    const page = location.pathname.split('/').pop() || 'index.html';

    let userId = null;
    let timer = null;
    let polling = false;
    let rerunQuiet = false;

    // Reads the last known numbers from session storage.
    function readState() {
        try {
            const saved = JSON.parse(sessionStorage.getItem(KEY));
            return saved && saved.uid === userId ? saved : null;
        } catch (e) { return null; }
    }

    // Saves the latest numbers to session storage.
    function writeState(state) {
        try { sessionStorage.setItem(KEY, JSON.stringify(Object.assign({ uid: userId }, state))); } catch (e) {}
    }

    let box = null;

    // Creates the box that holds the pop-ups.
    function ensureBox() {
        if (box) return box;
        const style = document.createElement('style');
        style.textContent =
            '.vax-toasts{position:fixed;right:16px;bottom:16px;z-index:2000;display:flex;flex-direction:column;gap:10px;max-width:340px;width:calc(100vw - 32px)}' +
            '.vax-toast{background:#fff;color:#1e3a40;border-left:5px solid #167d8d;border-radius:10px;box-shadow:0 8px 24px rgba(0,0,0,.18);padding:12px 38px 12px 14px;position:relative;font-size:.92rem;animation:vaxIn .25s ease}' +
            '.vax-toast strong{display:block;margin-bottom:2px}' +
            '.vax-toast a{color:#126a78;font-weight:600;text-decoration:none;display:inline-block;margin-top:4px}' +
            '.vax-toast button{position:absolute;top:6px;right:8px;border:0;background:none;font-size:1.2rem;line-height:1;color:#6b7f84;cursor:pointer}' +
            '@keyframes vaxIn{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:none}}' +
            '@media (prefers-reduced-motion:reduce){.vax-toast{animation:none}}';
        document.head.appendChild(style);
        box = document.createElement('div');
        box.className = 'vax-toasts';
        box.setAttribute('role', 'status');
        box.setAttribute('aria-live', 'polite');
        document.body.appendChild(box);
        return box;
    }

    // Shows a pop-up message.
    function popup(title, text, url, label) {
        const toast = document.createElement('div');
        toast.className = 'vax-toast';
        const heading = document.createElement('strong');
        heading.textContent = title;
        toast.appendChild(heading);
        if (text) {
            const p = document.createElement('div');
            p.textContent = text.length > 110 ? text.slice(0, 107) + '...' : text;
            toast.appendChild(p);
        }
        if (url && /^[a-z0-9_-]+\.html(\?[A-Za-z0-9%&=._-]*)?$/i.test(url)) {
            const a = document.createElement('a');
            a.href = url;
            a.textContent = label || 'View';
            toast.appendChild(a);
        }
        const close = document.createElement('button');
        close.type = 'button';
        close.setAttribute('aria-label', 'Dismiss');
        close.innerHTML = '&times;';
        close.addEventListener('click', function () { toast.remove(); });
        toast.appendChild(close);

        const holder = ensureBox();
        while (holder.children.length >= 3) holder.firstChild.remove();
        holder.appendChild(toast);
        setTimeout(function () { toast.remove(); }, 9000);
    }

    // Updates the unread badges in the menu.
    function showBadges(messages, notes) {
        VaxAuth.setUnread(messages);
        document.querySelectorAll('[data-unread-notifications]').forEach(function (el) {
            el.textContent = notes;
            el.hidden = !notes;
        });
        document.querySelectorAll('[data-unread-dot]').forEach(function (el) {
            el.hidden = !(messages || notes);
        });
    }

    // Checks the server for new messages and changes.
    async function poll(quiet) {
        if (polling) { if (quiet) rerunQuiet = true; return; }
        polling = true;
        try {
            const s = await VaxApi.get('api/session');
            if (!s.user || s.user.role !== 'patient') { stop(); return; }
            userId = s.user.id;

            const messages = s.unread_messages || 0;
            const notes = s.unread_notifications || 0;
            const latest = s.latest_notification || null;
            showBadges(messages, notes);

            const before = readState();
            if (before && !quiet) {
                let shown = false;
                const newNote = notes > before.notes || (latest && latest.id > before.noteId);
                if (messages > before.messages && page !== 'messages.html') {
                    popup('New message', 'Your doctor sent you a message.', 'messages.html', 'Open messages');
                    shown = true;
                }
                if (newNote && latest && page !== 'notifications.html') {
                    popup(latest.title, latest.message, latest.url || 'notifications.html', 'View');
                    shown = true;
                }
                const dataChanged = s.stamp !== before.stamp;
                if (dataChanged && !shown && !newNote) {
                    popup('Your records were updated', 'Your appointments or vaccination records have changed.', 'appointments.html', 'View appointments');
                }
                if (dataChanged || newNote) {
                    window.dispatchEvent(new CustomEvent('vax:refresh', { detail: { data: dataChanged, notifications: !!newNote } }));
                }
            }
            writeState({ messages: messages, notes: notes, noteId: latest ? latest.id : 0, stamp: s.stamp });
        } catch (e) {
        } finally {
            polling = false;
            if (rerunQuiet) { rerunQuiet = false; poll(true); }
        }
    }

    // Stops the checking timer.
    function stop() {
        if (timer) window.clearInterval(timer);
        timer = null;
    }

    // Starts checking and ignores the patient's own actions.
    function start() {
        poll(false);
        timer = window.setInterval(function () { if (!document.hidden) poll(false); }, POLL_MS);
        document.addEventListener('visibilitychange', function () { if (!document.hidden) poll(false); });

        ['post', 'put', 'patch', 'delete'].forEach(function (verb) {
            const original = VaxApi[verb];
            VaxApi[verb] = async function () {
                const result = await original.apply(VaxApi, arguments);
                poll(true);
                return result;
            };
        });
    }

    document.addEventListener('DOMContentLoaded', function () {
        VaxAuth.fetchUser().then(function (user) {
            if (user && user.role === 'patient') start();
        });
    });
})();
