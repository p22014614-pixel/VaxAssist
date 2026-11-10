async function getCurrentUser() {
    return VaxAuth.fetchUser();
}

let payments = [];

async function getPayments() {
    return (await VaxApi.get('api/payments')).payments;
}

async function payNow(id, method) {
    await VaxApi.patch('api/payments/' + encodeURIComponent(id), { status: 'paid', method: method });
    payments = await getPayments();
    return payments.find(function (p) { return p.id === id; });
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
            ? '<select class="form-select form-select-sm mt-2" data-method="' + p.id + '" aria-label="Payment method">' +
                '<option>Credit card</option><option>E-wallet</option><option>Online banking</option></select>' +
              '<button type="button" class="btn appointment-btn mt-2" data-pay="' + p.id + '">Pay now</button>'
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
        '<div class="receipt-line total"><span>' + (p.status === 'refunded' ? 'Amount refunded' : 'Amount paid') + '</span><span>' + money(total(p) - p.insurance_covered) + '</span></div>';
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
        const methodBox = payList.querySelector('[data-method="' + payBtn.dataset.pay + '"]');
        payBtn.disabled = true;
        payBtn.textContent = 'Processing...';
        try {
            const done = await payNow(Number(payBtn.dataset.pay), methodBox ? methodBox.value : 'Credit card');
            renderStats();
            render();
            showReceipt(done);
        } catch (err) {
            // Reload so the list matches the server (for example the visit was cancelled meanwhile).
            try { payments = await getPayments(); renderStats(); } catch (ignore) {}
            render();
            window.alert(err.status && err.status < 500 ? err.message : 'Sorry, the payment could not be completed. Please try again.');
        }
    }
});

statusFilter.addEventListener('change', render);
document.getElementById('printReceipt').addEventListener('click', function () { window.print(); });

// A visit changed while this page is open: reload the payments so the list stays correct.
window.addEventListener('vax:refresh', async function (e) {
    if (!e.detail || !e.detail.data) return;
    try {
        payments = await getPayments();
        renderStats();
        render();
    } catch (err) { /* the next refresh will try again */ }
});

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
