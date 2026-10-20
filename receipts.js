async function getCurrentUser() {
    return VaxAuth.getUser();
}

let payments = [
    { id: 1, receipt_no: 'VA-2026-0148', date: daysFromToday(-12), description: 'Typhoid vaccine', patient: 'Myself',
      doctor: 'Dr. Aisha Rahman', items: [{ label: 'Typhoid vaccine (1 dose)', amount: 95 }, { label: 'Consultation fee', amount: 40 }],
      method: 'Credit card', insurance_covered: 0, status: 'paid' },
    { id: 2, receipt_no: 'VA-2026-0131', date: daysFromToday(-41), description: 'Hepatitis A vaccine', patient: 'Myself',
      doctor: 'Dr. Jason Wong', items: [{ label: 'Hepatitis A vaccine (dose 1)', amount: 120 }, { label: 'Consultation fee', amount: 40 }],
      method: 'Insurance + e-wallet', insurance_covered: 100, status: 'paid' },
    { id: 3, receipt_no: 'VA-2026-0109', date: daysFromToday(-30), description: 'DTaP-IPV-Hib vaccine', patient: 'Aiden (child)',
      doctor: 'Dr. Siti Aminah', items: [{ label: 'DTaP-IPV-Hib (dose 3)', amount: 180 }, { label: 'Consultation fee', amount: 30 }],
      method: 'E-wallet', insurance_covered: 0, status: 'paid' },
    { id: 4, receipt_no: 'VA-2026-0162', date: daysFromToday(2), description: 'Influenza vaccine', patient: 'Myself',
      doctor: 'Dr. Priya Nair', items: [{ label: 'Influenza vaccine', amount: 70 }, { label: 'Consultation fee', amount: 40 }],
      method: '', insurance_covered: 0, status: 'pending' },
    { id: 5, receipt_no: 'VA-2026-0097', date: daysFromToday(-60), description: 'Cancelled appointment deposit', patient: 'Myself',
      doctor: 'Dr. Ahmad Farid', items: [{ label: 'Booking deposit (refunded)', amount: 20 }],
      method: 'Credit card', insurance_covered: 0, status: 'refunded' }
];

async function getPayments() {
    return payments;
}

async function payNow(id, method) {
    const p = payments.find(function (x) { return x.id === id; });
    if (p) { p.status = 'paid'; p.method = method; p.date = daysFromToday(0); }
    return p;
}

const payList = document.getElementById('payList');
const statusFilter = document.getElementById('statusFilter');
const resultCount = document.getElementById('resultCount');
const receiptBody = document.getElementById('receiptBody');
const receiptModal = new bootstrap.Modal(document.getElementById('receiptModal'));

function esc(text) {
    const div = document.createElement('div');
    div.textContent = text == null ? '' : text;
    return div.innerHTML;
}

function money(n) {
    return 'RM ' + Number(n).toFixed(2);
}

function total(p) {
    return p.items.reduce(function (sum, i) { return sum + i.amount; }, 0);
}

function niceDate(iso) {
    const p = iso.split('-');
    return new Date(Number(p[0]), Number(p[1]) - 1, Number(p[2]))
        .toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' });
}

const STATUS_TEXT = { paid: 'Paid', pending: 'Waiting for payment', refunded: 'Refunded' };

function renderStats() {
    const paid = payments.filter(function (p) { return p.status === 'paid'; });
    const pending = payments.filter(function (p) { return p.status === 'pending'; });
    document.getElementById('statPaid').textContent = money(paid.reduce(function (s, p) { return s + total(p) - p.insurance_covered; }, 0));
    document.getElementById('statPending').textContent = money(pending.reduce(function (s, p) { return s + total(p); }, 0));
    document.getElementById('statInsured').textContent = money(paid.reduce(function (s, p) { return s + p.insurance_covered; }, 0));
}

function render() {
    const want = statusFilter.value;
    const list = payments.filter(function (p) { return want === 'all' || p.status === want; });
    resultCount.textContent = list.length + (list.length === 1 ? ' payment' : ' payments');

    if (!list.length) {
        payList.innerHTML = '<div class="empty-box">No payments match this filter.</div>';
        return;
    }

    payList.innerHTML = list.map(function (p) {
        const action = p.status === 'pending'
            ? '<button type="button" class="btn appointment-btn mt-2" data-pay="' + p.id + '">Pay now</button>'
            : '<button type="button" class="btn-small-outline" data-receipt="' + p.id + '">View receipt</button>';
        return '<div class="pay-card">' +
            '<div class="pay-main"><h3 class="pay-title">' + esc(p.description) + '</h3>' +
            '<span class="badge-status ' + p.status + '">' + STATUS_TEXT[p.status] + '</span>' +
            '<div class="pay-meta">' + esc(p.patient) + ' &middot; ' + esc(p.doctor) + ' &middot; ' + esc(niceDate(p.date)) +
            ' &middot; ' + esc(p.receipt_no) + '</div></div>' +
            '<div class="pay-side"><div class="pay-amount">' + money(total(p)) + '</div>' + action + '</div></div>';
    }).join('');
}

function showReceipt(p) {
    const lines = p.items.map(function (i) {
        return '<div class="receipt-line"><span>' + esc(i.label) + '</span><span>' + money(i.amount) + '</span></div>';
    }).join('');
    const insured = p.insurance_covered
        ? '<div class="receipt-line"><span>Covered by insurance</span><span>- ' + money(p.insurance_covered) + '</span></div>' : '';
    receiptBody.innerHTML =
        '<p class="mb-1"><strong>VaxAssist Clinic</strong>, Kuala Lumpur</p>' +
        '<p class="text-secondary small">Receipt ' + esc(p.receipt_no) + ' &middot; ' + esc(niceDate(p.date)) + '</p>' +
        '<p class="small mb-3">Patient: ' + esc(p.patient) + '<br>Doctor: ' + esc(p.doctor) + '<br>Paid by: ' + esc(p.method || '-') + '</p>' +
        lines + insured +
        '<div class="receipt-line total"><span>Amount paid</span><span>' + money(total(p) - p.insurance_covered) + '</span></div>';
    receiptModal.show();
}

payList.addEventListener('click', async function (e) {
    const receiptBtn = e.target.closest('[data-receipt]');
    if (receiptBtn) {
        showReceipt(payments.find(function (p) { return p.id === Number(receiptBtn.dataset.receipt); }));
        return;
    }
    const payBtn = e.target.closest('[data-pay]');
    if (payBtn) {
        payBtn.disabled = true;
        payBtn.textContent = 'Processing...';
        const done = await payNow(Number(payBtn.dataset.pay), 'E-wallet');
        renderStats();
        render();
        showReceipt(done);
    }
});

statusFilter.addEventListener('change', render);
document.getElementById('printReceipt').addEventListener('click', function () { window.print(); });

(async function init() {
    const user = await getCurrentUser();
    if (!user) {
        window.location.href = 'login.html?next=' + encodeURIComponent('receipts.html');
        return;
    }
    payments = await getPayments();
    renderStats();
    render();
})();
