// Loads database-backed doctor analytics and doctor-specific patient updates.
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
    let recentUpdates = [];
    let dashboardRequestRunning = false;

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

    document.addEventListener('DOMContentLoaded', () => {
        loadDashboard();
        // Keep doctor updates current while the dashboard remains open.
        window.setInterval(loadDashboard, 30000);
    });
    // Fetches dashboard metrics and updates, then refreshes the cards, chart, and login pop-up.
    async function loadDashboard() {
        if (dashboardRequestRunning) return;
        dashboardRequestRunning = true;
        try {
            const data = await window.VaxApi.get('doctor_dashboard_backend.php');
            if (data.status !== 'success' || !data.metrics) throw new Error(data.message || 'Dashboard analytics are unavailable.');
            metricNodes.today.textContent = data.metrics.today;
            metricNodes.upcoming.textContent = data.metrics.nextSevenDays;
            metricNodes.completed.textContent = data.metrics.completedMonth;
            metricNodes.patients.textContent = data.metrics.activePatients;
            renderTrend(data.trend || []);
            const known = new Set(recentUpdates.map((update) => `${update.kind}|${update.title}|${update.patient}|${update.created_at}|${update.detail}`));
            (data.patientUpdates || []).forEach((update) => {
                const key = `${update.kind}|${update.title}|${update.patient}|${update.created_at}|${update.detail}`;
                if (!known.has(key)) {
                    recentUpdates.push(update);
                    known.add(key);
                }
            });
            recentUpdates = recentUpdates.slice(-100);
            metricNodes.notifications.textContent = String(recentUpdates.length);
            renderPatientUpdates(recentUpdates);
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
        } finally {
            dashboardRequestRunning = false;
        }
    }

    // Builds the patient update list safely from the backend response.
    function renderPatientUpdates(updates) {
        const container = document.getElementById('patientUpdatesList');
        container.replaceChildren();
        if (!updates.length) {
            const empty = document.createElement('p');
            empty.className = 'patient-updates-empty';
            empty.textContent = 'You’re all caught up. New patient updates will appear here.';
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

    // Draws the monthly scheduled-versus-completed appointments chart.
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

})();
