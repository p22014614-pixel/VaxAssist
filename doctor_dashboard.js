(() => {
    const targets = document.querySelectorAll('.page-header-banner, .dashboard-report > h2, .dashboard-grid > h2, .stat-card, .analytics-card, .nav-card-link');
    const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    const metricNodes = {
        today: document.getElementById('stat-today'),
        upcoming: document.getElementById('stat-upcoming'),
        completed: document.getElementById('stat-completed'),
        patients: document.getElementById('stat-patients'),
        notifications: document.getElementById('stat-notifications')
    };
    let dashboardData = null;

    if (reducedMotion || !('IntersectionObserver' in window)) {
        targets.forEach((item) => item.classList.add('doctor-animate-in'));
    } else {
        const observer = new IntersectionObserver((entries) => entries.forEach((entry) => {
            if (!entry.isIntersecting) return;
            entry.target.classList.add('doctor-animate-in');
            observer.unobserve(entry.target);
        }), { threshold: 0.12 });
        targets.forEach((item, index) => {
            item.classList.add('doctor-animate');
            item.style.setProperty('--doctor-delay', `${Math.min(index % 6, 5) * 65}ms`);
            observer.observe(item);
        });
    }

    document.addEventListener('DOMContentLoaded', loadDashboard);
    document.querySelectorAll('[data-export]').forEach((button) => button.addEventListener('click', () => {
        if (!dashboardData) return showExportError();
        const type = button.dataset.export;
        if (type === 'excel') exportExcel();
        if (type === 'pdf') exportPdf();
        if (type === 'word') exportWord();
    }));

    async function loadDashboard() {
        try {
            const data = await window.VaxApi.get('doctor_dashboard_backend.php');
            if (data.status !== 'success' || !data.metrics) throw new Error(data.message || 'Dashboard analytics are unavailable.');
            dashboardData = data;
            metricNodes.today.textContent = data.metrics.today;
            metricNodes.upcoming.textContent = data.metrics.nextSevenDays;
            metricNodes.completed.textContent = data.metrics.completedMonth;
            metricNodes.patients.textContent = data.metrics.activePatients;
            metricNodes.notifications.textContent = data.metrics.patientUpdates;
            renderTrend(data.trend || []);
            renderPatientUpdates(data.patientUpdates || []);
            document.getElementById('dashboardError').hidden = true;
            if (data.showLoginUpdates && window.bootstrap?.Modal) {
                window.bootstrap.Modal.getOrCreateInstance(document.getElementById('patientUpdatesModal')).show();
            }
        } catch (error) {
            console.error('Doctor dashboard data request failed:', error);
            const alert = document.getElementById('dashboardError');
            alert.textContent = error.message || 'We couldn’t load your dashboard data. Please sign in again or try refreshing.';
            alert.hidden = false;
            document.getElementById('appointmentTrend').innerHTML = '<p class="trend-empty">Clinic trends are unavailable right now.</p>';
        }
    }

    function renderPatientUpdates(updates) {
        const container = document.getElementById('patientUpdatesList');
        container.replaceChildren();
        if (!updates.length) {
            const empty = document.createElement('p');
            empty.className = 'patient-updates-empty';
            empty.textContent = 'You’re all caught up. There are no new patient updates since your last login.';
            container.append(empty);
            return;
        }
        updates.forEach((update) => {
            const item = document.createElement('article');
            item.className = `patient-update-item patient-update-${update.kind || 'general'}`;
            const heading = document.createElement('div');
            heading.className = 'patient-update-heading';
            const title = document.createElement('strong');
            title.textContent = update.title || 'Patient update';
            const time = document.createElement('time');
            time.dateTime = update.created_at || '';
            const parsed = new Date(String(update.created_at || '').replace(' ', 'T'));
            time.textContent = Number.isNaN(parsed.getTime()) ? '' : new Intl.DateTimeFormat(undefined, { dateStyle: 'medium', timeStyle: 'short' }).format(parsed);
            heading.append(title, time);
            const patient = document.createElement('p');
            patient.className = 'patient-update-name';
            patient.textContent = update.patient || 'Patient';
            const detail = document.createElement('p');
            detail.className = 'patient-update-detail';
            detail.textContent = update.detail || '';
            item.append(heading, patient, detail);
            container.append(item);
        });
    }

    function renderTrend(months) {
        const chart = document.getElementById('appointmentTrend');
        chart.replaceChildren();
        const max = Math.max(1, ...months.map((month) => month.scheduled + month.completed));
        months.forEach((month) => {
            const total = month.scheduled + month.completed;
            const group = document.createElement('div');
            group.className = 'trend-month';
            const totalLabel = document.createElement('span');
            totalLabel.className = 'trend-total';
            totalLabel.textContent = String(total);
            const stack = document.createElement('div');
            stack.className = 'trend-stack';
            stack.setAttribute('aria-label', `${month.month}: ${month.scheduled} scheduled, ${month.completed} completed`);
            [['scheduled', 'legend-scheduled'], ['completed', 'legend-completed']].forEach(([key, color]) => {
                const count = month[key] || 0;
                if (!count) return;
                const segment = document.createElement('span');
                segment.className = `trend-segment ${color}`;
                segment.style.height = `${Math.max(4, (count / max) * 100)}%`;
                segment.title = `${key}: ${count}`;
                stack.append(segment);
            });
            const label = document.createElement('span');
            label.className = 'trend-month-label';
            const date = new Date(`${month.month}-01T12:00:00`);
            label.textContent = new Intl.DateTimeFormat(undefined, { month: 'short' }).format(date);
            group.append(totalLabel, stack, label);
            chart.append(group);
        });
        if (!months.length) chart.innerHTML = '<p class="trend-empty">No appointment history is available yet.</p>';
    }

    function metricRows() {
        const m = dashboardData.metrics;
        return [
            ['Today’s scheduled appointments', m.today],
            ['Upcoming scheduled appointments (next 7 days, excluding today)', m.nextSevenDays],
            ['Completed appointments this month', m.completedMonth],
            ['Patients in doctor panel', m.activePatients],
            ['Patient updates shown on login', m.patientUpdates]
        ];
    }

    function trendRows() {
        return [['Month', 'Scheduled', 'Completed'], ...dashboardData.trend.map((m) => [m.month, m.scheduled, m.completed])];
    }

    function exportExcel() {
        const rows = [['VaxAssist Doctor Dashboard Analytics'], [], ['Database Metric', 'Value'], ...metricRows(), [], ...trendRows()];
        if (window.XLSX && window.XLSX.utils) {
            const sheet = window.XLSX.utils.aoa_to_sheet(rows);
            sheet['!cols'] = [{ wch: 64 }, { wch: 24 }, { wch: 18 }, { wch: 18 }, { wch: 18 }];
            const book = window.XLSX.utils.book_new();
            window.XLSX.utils.book_append_sheet(book, sheet, 'Doctor Analytics');
            window.XLSX.writeFile(book, 'VaxAssist_Doctor_Analytics.xlsx');
            return;
        }
        downloadBlob(new Blob([rows.map((row) => row.map(csvCell).join(',')).join('\r\n')], { type: 'text/csv;charset=utf-8' }), 'VaxAssist_Doctor_Analytics.csv');
    }

    function csvCell(value) { return `"${String(value ?? '').replace(/"/g, '""')}"`; }

    function exportPdf() {
        const element = document.getElementById('printable-dashboard');
        if (typeof window.html2pdf === 'function') {
            window.html2pdf().set({ margin: 0.45, filename: 'VaxAssist_Doctor_Analytics.pdf', pagebreak: { mode: ['css', 'legacy'] } }).from(element).save();
            return;
        }
        window.print();
    }

    function escapeHtml(value) { return String(value ?? '').replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]); }

    function exportWord() {
        const table = (rows) => `<table><tbody>${rows.map((row, index) => `<tr>${row.map((cell) => index === 0 ? `<th>${escapeHtml(cell)}</th>` : `<td>${escapeHtml(cell)}</td>`).join('')}</tr>`).join('')}</tbody></table>`;
        const documentHtml = `<!doctype html><html><head><meta charset="utf-8"><title>VaxAssist Doctor Analytics</title><style>body{font:14px Arial;color:#183642}h1,h2{color:#126a78}table{border-collapse:collapse;width:100%;margin:12px 0 28px}th,td{border:1px solid #dbe5e8;padding:8px;text-align:left}th{background:#e8f5f6}</style></head><body><h1>VaxAssist Doctor Dashboard Analytics</h1><h2>Clinic metrics</h2>${table([['Database metric','Value'],...metricRows()])}<h2>Appointment activity from the database</h2>${table(trendRows())}</body></html>`;
        downloadBlob(new Blob(['\ufeff', documentHtml], { type: 'application/msword;charset=utf-8' }), 'VaxAssist_Doctor_Analytics.doc');
    }

    function downloadBlob(blob, filename) {
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = filename;
        document.body.append(link);
        link.click();
        link.remove();
        setTimeout(() => URL.revokeObjectURL(url), 1000);
    }

    function showExportError() {
        const alert = document.getElementById('dashboardError');
        alert.textContent = 'Load dashboard analytics before exporting.';
        alert.hidden = false;
    }
})();
