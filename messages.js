async function getCurrentUser() {
    return VaxAuth.fetchUser();
}

async function getConversations() {
    const loaded = await Promise.all([VaxApi.get('api/conversations'), VaxApi.get('api/doctors?all=1')]);
    return { conversations: loaded[0].conversations, doctors: loaded[1].doctors };
}

async function getThread(doctorId, afterId) {
    return VaxApi.get('api/conversations/' + encodeURIComponent(doctorId) + '/messages' + (afterId ? '?after=' + encodeURIComponent(afterId) : ''));
}

async function markThreadRead(doctorId) {
    return VaxApi.patch('api/conversations/' + encodeURIComponent(doctorId) + '/messages', { is_read: true });
}

async function sendMessage(doctorId, text) {
    return (await VaxApi.post('api/conversations/' + encodeURIComponent(doctorId) + '/messages', { text: text })).message;
}

const chatShell = document.getElementById('chatShell');
const convList = document.getElementById('convList');
const newBtn = document.getElementById('newBtn');
const newBox = document.getElementById('newBox');
const newDoctor = document.getElementById('newDoctor');
const chatEmpty = document.getElementById('chatEmpty');
const chatThread = document.getElementById('chatThread');
const threadBody = document.getElementById('threadBody');
const threadName = document.getElementById('threadName');
const threadSub = document.getElementById('threadSub');
const threadAvatar = document.getElementById('threadAvatar');
const composer = document.getElementById('composer');
const messageText = document.getElementById('messageText');
const sendBtn = document.getElementById('sendBtn');
const composerError = document.getElementById('composerError');

const LIST_REFRESH_MS = 15000;
const THREAD_REFRESH_MS = 4000;

let conversations = [];
let doctors = [];
let active = null;
let messages = [];
let threadTimer = null;
let listTimer = null;

function esc(text) {
    const div = document.createElement('div');
    div.textContent = text == null ? '' : text;
    return div.innerHTML;
}

function initials(name) {
    return name.replace('Dr. ', '').split(' ').map(function (p) { return p[0]; }).slice(0, 2).join('').toUpperCase();
}

function sameDay(a, b) {
    return a.toDateString() === b.toDateString();
}

function shortTime(iso) {
    const d = new Date(iso);
    const now = new Date();
    if (sameDay(d, now)) return d.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
    return d.toLocaleDateString('en-GB', { day: 'numeric', month: 'short' });
}

function dayLabel(iso) {
    const d = new Date(iso);
    const now = new Date();
    const yesterday = new Date(now.getFullYear(), now.getMonth(), now.getDate() - 1);
    if (sameDay(d, now)) return 'Today';
    if (sameDay(d, yesterday)) return 'Yesterday';
    return d.toLocaleDateString('en-GB', { weekday: 'long', day: 'numeric', month: 'long' });
}

function renderList() {
    if (!conversations.length) {
        convList.innerHTML = '<p class="list-empty">No messages yet. Choose "+ New" to write to a doctor.</p>';
        return;
    }
    convList.innerHTML = conversations.map(function (c) {
        const prefix = c.last_sender === 'patient' ? 'You: ' : '';
        return '<button type="button" class="conv' + (active && active.id === c.doctor_id ? ' active' : '') + '" data-doctor="' + esc(c.doctor_id) + '">' +
            '<div class="avatar">' + esc(initials(c.doctor_name)) + '</div>' +
            '<div class="conv-main"><div class="conv-name"><span>' + esc(c.doctor_name) + '</span><span class="conv-time">' + esc(shortTime(c.last_time)) + '</span></div>' +
            '<div class="conv-last">' + esc(prefix + c.last_text) + '</div></div>' +
            (c.unread ? '<span class="unread-dot" aria-label="' + esc(c.unread) + ' unread">' + esc(c.unread) + '</span>' : '') +
            '</button>';
    }).join('');
}

function renderMessages(stickToBottom) {
    if (!messages.length) {
        threadBody.innerHTML = '<p class="thread-hint">No messages yet. Say hello to ' + esc(active.name) + '.</p>';
        return;
    }
    let html = '';
    let lastDay = '';
    messages.forEach(function (m) {
        const label = dayLabel(m.created_at);
        if (label !== lastDay) {
            html += '<div class="day-sep">' + esc(label) + '</div>';
            lastDay = label;
        }
        const time = new Date(m.created_at).toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
        html += '<div class="bubble ' + (m.sender === 'patient' ? 'out' : 'in') + '">' + esc(m.text) + '<small>' + esc(time) + '</small></div>';
    });
    threadBody.innerHTML = html;
    if (stickToBottom) threadBody.scrollTop = threadBody.scrollHeight;
}

function totalUnread() {
    return conversations.reduce(function (sum, c) { return sum + c.unread; }, 0);
}

async function refreshList() {
    try {
        const data = await getConversations();
        conversations = data.conversations;
        doctors = data.doctors;
        if (active) {
            const c = conversations.find(function (x) { return x.doctor_id === active.id; });
            if (c) c.unread = 0;
        }
        renderList();
        VaxAuth.setUnread(totalUnread());
    } catch (err) {
        if (err.status === 401) window.location.href = 'login.html?next=messages.html';
    }
}

function fillNewList() {
    newDoctor.innerHTML = '<option value="">Choose a doctor</option>' + doctors.map(function (d) {
        return '<option value="' + esc(d.id) + '">' + esc(d.name) + ' - ' + esc(d.specialty) + '</option>';
    }).join('');
}

async function openThread(doctorId) {
    window.clearInterval(threadTimer);
    composerError.classList.add('d-none');

    const data = await getThread(doctorId);
    active = data.doctor;
    messages = data.messages;
    if (data.messages.some(function (m) { return m.sender === 'doctor'; })) markThreadRead(doctorId).catch(function () {});

    threadName.textContent = active.name;
    threadSub.textContent = active.specialty;
    threadAvatar.textContent = initials(active.name);
    chatEmpty.classList.add('d-none');
    chatThread.classList.remove('d-none');
    chatShell.classList.add('thread-open');
    newBox.classList.add('d-none');

    renderMessages(true);
    const c = conversations.find(function (x) { return x.doctor_id === active.id; });
    if (c) c.unread = 0;
    renderList();
    VaxAuth.setUnread(totalUnread());
    messageText.focus();

    threadTimer = window.setInterval(pollThread, THREAD_REFRESH_MS);
}

async function pollThread() {
    if (!active || document.hidden) return;
    const lastId = messages.length ? messages[messages.length - 1].id : 0;
    try {
        const data = await getThread(active.id, lastId);
        if (data.messages.length) {
            const nearBottom = threadBody.scrollHeight - threadBody.scrollTop - threadBody.clientHeight < 80;
            // A message we just sent may already be in the list; never show it twice.
            const fresh = data.messages.filter(function (m) { return !messages.some(function (x) { return x.id === m.id; }); });
            if (!fresh.length) return;
            messages = messages.concat(fresh);
            if (fresh.some(function (m) { return m.sender === 'doctor'; })) markThreadRead(active.id).catch(function () {});
            renderMessages(nearBottom);
            refreshList();
        }
    } catch (err) {
        /* try again on the next tick */
    }
}

function autoGrow() {
    messageText.style.height = 'auto';
    messageText.style.height = Math.min(messageText.scrollHeight, 120) + 'px';
}

convList.addEventListener('click', function (e) {
    const btn = e.target.closest('[data-doctor]');
    if (btn) openThread(Number(btn.dataset.doctor));
});

newBtn.addEventListener('click', function () {
    fillNewList();
    newBox.classList.toggle('d-none');
    if (!newBox.classList.contains('d-none')) newDoctor.focus();
});

newDoctor.addEventListener('change', function () {
    if (newDoctor.value) openThread(Number(newDoctor.value));
});

document.getElementById('backBtn').addEventListener('click', function () {
    chatShell.classList.remove('thread-open');
    window.clearInterval(threadTimer);
    active = null;
    renderList();
});

messageText.addEventListener('input', autoGrow);

messageText.addEventListener('keydown', function (e) {
    if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        composer.requestSubmit();
    }
});

composer.addEventListener('submit', async function (e) {
    e.preventDefault();
    const text = messageText.value.trim();
    if (!text || !active) return;

    composerError.classList.add('d-none');
    sendBtn.disabled = true;
    try {
        const sent = await sendMessage(active.id, text);
        messages.push(sent);
        messageText.value = '';
        autoGrow();
        renderMessages(true);
        await refreshList();
    } catch (err) {
        composerError.textContent = err.status && err.status < 500 ? err.message : 'Sorry, your message could not be sent. Please try again.';
        composerError.classList.remove('d-none');
    }
    sendBtn.disabled = false;
    messageText.focus();
});

(async function init() {
    const user = await getCurrentUser();
    if (!user) {
        window.location.href = 'login.html?next=' + encodeURIComponent('messages.html' + window.location.search);
        return;
    }
    await refreshList();
    listTimer = window.setInterval(refreshList, LIST_REFRESH_MS);

    const wanted = Number(new URLSearchParams(window.location.search).get('doctor_id'));
    if (wanted && doctors.some(function (d) { return d.id === wanted; })) openThread(wanted);
})();
