// Notifications page.

// Asks the server who is signed in.
async function getCurrentUser() {
    return VaxAuth.fetchUser();
}

// Loads the patient's notifications.
async function getNotifications() {
    return (await VaxApi.get('api/notifications')).notifications;
}

// Marks one notification as read.
async function markNotificationRead(id) {
    return VaxApi.patch('api/notifications/' + encodeURIComponent(id), { is_read: true });
}

// Marks all notifications as read.
async function markAllRead() {
    return VaxApi.patch('api/notifications', { is_read: true });
}

// Deletes one notification.
async function deleteNotification(id) {
    return VaxApi.delete('api/notifications/' + encodeURIComponent(id));
}

// Loads the notification settings.
async function getPreferences() {
    return (await VaxApi.get('api/notification-preferences')).preferences;
}

// Saves the notification settings.
async function savePreferences(prefs) {
    return VaxApi.put('api/notification-preferences', prefs);
}

const feed = document.getElementById('feed');
const filterChips = document.getElementById('filterChips');
const markAllBtn = document.getElementById('markAllBtn');
const bellCount = document.getElementById('bellCount');
const reduceMotion = !!(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches);

const TYPE_ICON = { reminder: '&#128197;', late: '&#9200;', booster: '&#128137;', appointment: '&#9989;', announcement: '&#128226;' };
const FILTERS = [
    { key: 'all',          label: 'All' },
    { key: 'unread',       label: 'Unread' },
    { key: 'reminder',     label: 'Reminders' },
    { key: 'booster',      label: 'Boosters' },
    { key: 'appointment',  label: 'Appointments' }
];

let notifications = [];
let filter = 'all';
let lastUnread = null;

// Escapes text so it is safe to put in HTML.
function esc(text) {
    const div = document.createElement('div');
    div.textContent = text == null ? '' : text;
    return div.innerHTML;
}

// Allows only links to local .html pages.
function safeUrl(u) {
    return /^[a-z]+\.html(\?[\w%&=.()\-]*)?$/i.test(String(u || '')) ? u : '';
}

// Shows how long ago something happened.
function timeAgo(iso) {
    const mins = Math.max(0, Math.round((Date.now() - new Date(iso).getTime()) / 60000));
    if (mins < 1) return 'Just now';
    if (mins < 60) return mins + (mins === 1 ? ' minute ago' : ' minutes ago');
    const hrs = Math.round(mins / 60);
    if (hrs < 24) return hrs + (hrs === 1 ? ' hour ago' : ' hours ago');
    const days = Math.round(hrs / 24);
    if (days < 30) return days + (days === 1 ? ' day ago' : ' days ago');
    return new Date(iso).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' });
}

// Groups a notification as Today, This week or Earlier.
function groupOf(iso) {
    const hrs = (Date.now() - new Date(iso).getTime()) / 3600000;
    if (hrs < 24) return 'Today';
    if (hrs < 24 * 7) return 'This week';
    return 'Earlier';
}

let toastTimer = null;
// Shows a short pop-up message.
function toast(message) {
    const t = document.getElementById('toast');
    t.textContent = message;
    t.classList.add('show');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(function () { t.classList.remove('show'); }, 3000);
}

// Counts unread notifications.
function unreadCount() {
    return notifications.filter(function (n) { return !n.is_read; }).length;
}

// Updates the unread count on the bell.
function updateBell() {
    const n = unreadCount();
    bellCount.textContent = n;
    bellCount.classList.toggle('zero', n === 0);
    if (lastUnread !== null && n !== lastUnread && !reduceMotion) {
        bellCount.classList.remove('bump');
        void bellCount.offsetWidth;
        bellCount.classList.add('bump');
    }
    lastUnread = n;
    markAllBtn.disabled = n === 0;
    document.title = (n ? '(' + n + ') ' : '') + 'VaxAssist | Notifications';
}

// Draws the filter buttons.
function renderChips() {
    filterChips.innerHTML = FILTERS.map(function (f) {
        const count = f.key === 'unread' ? ' (' + unreadCount() + ')' : '';
        return '<button type="button" class="chip' + (filter === f.key ? ' active' : '') + '" data-filter="' + f.key + '">' + f.label + count + '</button>';
    }).join('');
}

// Checks if a notification passes the current filter.
function matches(n) {
    if (filter === 'all') return true;
    if (filter === 'unread') return !n.is_read;
    return n.type === filter || (filter === 'reminder' && n.type === 'late');
}

// Builds the HTML for one notification.
function noteHtml(n, index) {
    const url = safeUrl(n.action_url);
    return '<article class="note' + (n.is_read ? '' : ' unread') + '" style="--i:' + index + '" data-id="' + esc(n.id) + '">' +
        '<div class="note-icon t-' + esc(n.type) + '" aria-hidden="true">' + (TYPE_ICON[n.type] || '&#128276;') + '</div>' +
        '<div>' +
            '<div class="note-title">' + esc(n.title) + '</div>' +
            '<div class="note-msg">' + esc(n.message) + '</div>' +
            '<div class="note-time">' + esc(timeAgo(n.created_at)) + '</div>' +
        '</div>' +
        '<div class="note-actions">' +
            (url && n.action_label ? '<a class="note-link" href="' + esc(url) + '" data-open="' + esc(n.id) + '">' + esc(n.action_label) + '</a>' : '') +
            '<div>' +
                (n.is_read ? '' : '<button type="button" class="icon-btn" data-read="' + esc(n.id) + '">Mark as read</button>') +
                '<button type="button" class="icon-btn del" data-delete="' + esc(n.id) + '" aria-label="Delete notification">Delete</button>' +
            '</div>' +
        '</div>' +
    '</article>';
}

// Draws the notification list.
function render() {
    updateBell();
    renderChips();

    const list = notifications
        .filter(matches)
        .sort(function (a, b) { return new Date(b.created_at) - new Date(a.created_at); });

    if (!list.length) {
        feed.innerHTML = '<div class="empty-state" style="margin-top: 20px"><div class="icon">' +
            (filter === 'unread' ? '&#127881;' : '&#128237;') + '</div>' +
            (filter === 'unread' ? "You're all caught up. No unread notifications." : 'No notifications here yet.') + '</div>';
        return;
    }

    let index = 0, current = '';
    feed.innerHTML = list.map(function (n) {
        const g = groupOf(n.created_at);
        let head = '';
        if (g !== current) { current = g; head = '<div class="group-heading">' + g + '</div>'; }
        return head + noteHtml(n, index++ % 8);
    }).join('');
}

// Marks one notification as read.
async function readOne(id, quiet) {
    const n = notifications.find(function (x) { return String(x.id) === String(id); });
    if (!n || n.is_read) return;
    try {
        await markNotificationRead(n.id);
        n.is_read = 1;
        if (!quiet) { render(); }
    } catch (err) {
        toast('Sorry, that did not work. Please try again.');
    }
}

// Changes the filter.
filterChips.addEventListener('click', function (e) {
    const btn = e.target.closest('button[data-filter]');
    if (!btn) return;
    filter = btn.dataset.filter;
    render();
});

// Handles mark read, delete and link clicks.
feed.addEventListener('click', async function (e) {
    const readBtn = e.target.closest('button[data-read]');
    if (readBtn) { await readOne(readBtn.dataset.read); return; }

    const delBtn = e.target.closest('button[data-delete]');
    if (delBtn) {
        const id = delBtn.dataset.delete;
        try {
            await deleteNotification(id);
        } catch (err) {
            toast('Sorry, we could not delete that. Please try again.');
            return;
        }
        const card = delBtn.closest('.note');
        if (card && !reduceMotion) card.classList.add('dismissing');
        setTimeout(function () {
            notifications = notifications.filter(function (n) { return String(n.id) !== String(id); });
            render();
            toast('Notification deleted');
        }, reduceMotion ? 0 : 400);
        return;
    }

    const link = e.target.closest('a[data-open]');
    if (link) { readOne(link.dataset.open, true); }
});

// Marks all notifications as read.
markAllBtn.addEventListener('click', async function () {
    markAllBtn.disabled = true;
    try {
        await markAllRead();
        notifications.forEach(function (n) { n.is_read = 1; });
        render();
        toast('All notifications marked as read');
    } catch (err) {
        markAllBtn.disabled = false;
        toast('Sorry, that did not work. Please try again.');
    }
});

const PREF_FIELDS = ['email_reminders', 'sms_reminders', 'booster_alerts', 'clinic_news'];

// Saves the notification settings.
document.getElementById('prefForm').addEventListener('submit', async function (e) {
    e.preventDefault();
    const prefs = {};
    PREF_FIELDS.forEach(function (f) { prefs[f] = document.getElementById(f).checked; });
    const btn = document.getElementById('prefBtn');
    const box = document.getElementById('prefError');
    box.classList.add('d-none');
    btn.disabled = true; btn.textContent = 'Saving...';
    try {
        await savePreferences(prefs);
        toast('Preferences saved');
    } catch (err) {
        box.textContent = 'Sorry, we could not save your preferences. Please try again.';
        box.classList.remove('d-none');
    }
    btn.disabled = false; btn.textContent = 'Save preferences';
});

// Reloads notifications when new ones arrive.
window.addEventListener('vax:refresh', async function (e) {
    if (!e.detail || !e.detail.notifications) return;
    try {
        notifications = await getNotifications();
        render();
    } catch (err) {  }
});

(async function init() {
    const user = await getCurrentUser();
    if (!user) {
        window.location.href = 'login.html?next=' + encodeURIComponent('notifications.html');
        return;
    }
    try {
        const loaded = await Promise.all([getNotifications(), getPreferences()]);
        notifications = loaded[0];
        const prefs = loaded[1];
        PREF_FIELDS.forEach(function (f) { document.getElementById(f).checked = !!prefs[f]; });
        render();
    } catch (err) {
        feed.innerHTML = '<div class="empty-state">Sorry, we could not load your notifications. Please try again later.</div>';
    }
})();
