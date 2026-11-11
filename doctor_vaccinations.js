// Loads the doctor's assigned vaccination appointments, pre-checks, and dose-record form.
// Shows a stored time such as 10:30:00 as 10:30.
function shortTime(value) {
    const match = String(value || '').match(/^(\d{1,2}):(\d{2})/);
    return match ? match[1].padStart(2, '0') + ':' + match[2] : String(value || '');
}

(() => {
    const scheduledList = document.getElementById('scheduledVaccinationList');
    const completedList = document.getElementById('completedVaccinationList');
    const details = document.getElementById('vaccinationPatientDetails');
    const precheck = document.getElementById('precheckDetails');
    const form = document.getElementById('vaccinationRecordForm');
    const history = document.getElementById('vaccinationHistory');
    const historyButton = document.getElementById('toggleVaccinationHistory');
    const patientModalElement = document.getElementById('vaccinationPatientModal');
    const vaccineSelect = document.getElementById('recordVaccine');
    const batchSelect = document.getElementById('recordBatch');
    const status = document.getElementById('vaccinationLoadStatus');
    let roster = [];
    let vaccines = [];
    let batches = [];
    let selected = null;

    const motionTargets = document.querySelectorAll('.page-header-banner, .form-card');
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches || !('IntersectionObserver' in window)) {
        motionTargets.forEach((node) => node.classList.add('doctor-animate-in'));
    } else {
        const observer = new IntersectionObserver((entries) => entries.forEach((entry) => {
            if (!entry.isIntersecting) return;
            entry.target.classList.add('doctor-animate-in');
            observer.unobserve(entry.target);
        }), { threshold: 0.1 });
        motionTargets.forEach((node, index) => {
            node.classList.add('doctor-animate');
            node.style.setProperty('--doctor-delay', `${Math.min(index, 5) * 70}ms`);
            observer.observe(node);
        });
    }

    // Displays a success or error message beside the vaccination workflow.
    function setStatus(message, isError = false) {
        status.textContent = message;
        status.hidden = !message;
        status.classList.toggle('is-success', Boolean(message) && !isError);
        status.classList.toggle('is-error', Boolean(message) && isError);
    }

    // Formats a database date for display in the vaccination page.
    function formatDate(value) {
        if (!value) return 'Not provided';
        const date = new Date(`${value}T12:00:00`);
        return Number.isNaN(date.getTime()) ? value : new Intl.DateTimeFormat(undefined, { dateStyle: 'medium' }).format(date);
    }

    // Converts stored screening values into readable answers.
    function yesNo(value) {
        if (value === null || value === undefined || value === '') return 'Not stated';
        return Number(value) === 1 ? 'Yes' : 'No';
    }

    // Finds the latest recorded dose for this patient, child, and vaccine.
    function doseProgress(patient) {
        const records = (patient.vaccination_history || [])
            .filter((record) => patient.vaccine_id && Number(record.vaccine_id) === Number(patient.vaccine_id))
            .sort((a, b) => String(b.date_given).localeCompare(String(a.date_given)) || Number(b.dose_number) - Number(a.dose_number));
        const latest = records[0] || null;
        const vaccine = vaccines.find((item) => Number(item.vaccine_id) === Number(patient.vaccine_id));
        const total = Number(patient.total_doses || latest?.total_doses || vaccine?.total_doses || 1);
        const completed = records.reduce((max, record) => Math.max(max, Number(record.dose_number) || 0), 0);
        return { latest, total, completed };
    }

    // Builds separate, scrollable lists for scheduled visits and completed visits.
    function renderRoster() {
        const scheduled = roster.filter((patient) => patient.status === 'Scheduled');
        const completed = roster.filter((patient) => patient.status === 'Completed');
        document.getElementById('scheduledPatientCount').textContent = String(scheduled.length);
        document.getElementById('completedPatientCount').textContent = String(completed.length);
        scheduledList.replaceChildren();
        completedList.replaceChildren();

        const renderEmpty = (container, message) => {
            const empty = document.createElement('p');
            empty.className = 'vaccination-roster-empty';
            empty.textContent = message;
            container.append(empty);
        };

        scheduled.forEach((patient) => {
            const card = document.createElement('article');
            card.className = `vaccination-patient-card${selected?.appointment_id === patient.appointment_id ? ' is-selected' : ''}`;
            const choose = document.createElement('button');
            choose.type = 'button';
            choose.className = 'vaccination-card-select';
            choose.setAttribute('aria-label', `Review ${patient.child_name || patient.full_name}`);
            const name = document.createElement('strong');
            name.textContent = patient.child_name ? `${patient.child_name} (${patient.full_name})` : patient.full_name;
            const vaccine = document.createElement('span');
            vaccine.textContent = patient.vaccine_name || 'Vaccine not assigned';
            const date = document.createElement('small');
            date.textContent = `${formatDate(patient.appointment_date)}${patient.appointment_time ? ` · ${shortTime(patient.appointment_time)}` : ''}`;
            const precheckStatus = document.createElement('small');
            precheckStatus.className = patient.form_id ? 'precheck-available' : 'precheck-missing';
            precheckStatus.textContent = patient.form_id ? 'Pre-check available' : 'No pre-check form';
            choose.append(name, vaccine, date, precheckStatus);
            choose.addEventListener('click', () => selectPatient(patient));
            card.append(choose);
            scheduledList.append(card);
        });

        completed.forEach((patient) => {
            const card = document.createElement('article');
            card.className = `vaccination-patient-card vaccination-completed-card${selected?.appointment_id === patient.appointment_id ? ' is-selected' : ''}`;
            const choose = document.createElement('button');
            choose.type = 'button';
            choose.className = 'vaccination-card-select';
            choose.setAttribute('aria-label', `Review completed visit for ${patient.child_name || patient.full_name}`);
            const name = document.createElement('strong');
            name.textContent = patient.child_name ? `${patient.child_name} (${patient.full_name})` : patient.full_name;
            const vaccine = document.createElement('span');
            vaccine.textContent = patient.vaccine_name || 'Vaccine not assigned';
            const date = document.createElement('small');
            date.textContent = `Visit completed · ${formatDate(patient.appointment_date)}`;
            choose.append(name, vaccine, date);
            choose.addEventListener('click', () => selectPatient(patient));
            card.append(choose);

            if (patient.vaccine_id) {
                const progress = doseProgress(patient);
                const doseLine = document.createElement('p');
                doseLine.className = 'vaccination-dose-progress';
                doseLine.textContent = progress.completed
                    ? `${progress.completed} of ${progress.total} doses recorded`
                    : `0 of ${progress.total} doses recorded`;
                const nextLine = document.createElement('div');
                nextLine.className = `vaccination-completed-next${progress.latest?.next_dose_date ? ' has-next-dose' : ''}`;
                if (progress.latest?.next_dose_date) {
                    const due = document.createElement('span');
                    due.textContent = `Next dose · ${formatDate(progress.latest.next_dose_date)}`;
                    const notify = document.createElement('a');
                    notify.className = 'btn secondary-btn btn-sm vaccination-notify-link';
                    notify.href = `doctor_communications.html?patient_id=${encodeURIComponent(patient.patient_id)}`;
                    notify.innerHTML = '<i class="bi bi-chat-dots" aria-hidden="true"></i> Notify patient';
                    nextLine.append(due, notify);
                } else if (progress.latest) {
                    const complete = document.createElement('span');
                    complete.className = 'vaccination-fully-completed';
                    complete.innerHTML = '<i class="bi bi-check-circle-fill" aria-hidden="true"></i> Fully completed';
                    nextLine.append(complete);
                } else {
                    const missing = document.createElement('span');
                    missing.textContent = 'No vaccination dose record found';
                    nextLine.append(missing);
                }
                card.append(doseLine, nextLine);
            }
            completedList.append(card);
        });

        if (!scheduled.length) renderEmpty(scheduledList, 'No scheduled patients are assigned to you.');
        if (!completed.length) renderEmpty(completedList, 'Completed appointments will appear here.');
    }

    // Displays the pre-check form linked to the selected appointment.
    function renderPrecheck(patient) {
        precheck.replaceChildren();
        if (!patient.form_id) {
            const empty = document.createElement('p');
            empty.className = 'precheck-empty';
            empty.textContent = 'No pre-check form has been submitted for this appointment. Confirm relevant screening information with the patient before vaccination.';
            precheck.append(empty);
            return;
        }
        const title = document.createElement('h3');
        title.textContent = 'Pre-check responses';
        const submitted = document.createElement('p');
        submitted.className = 'precheck-submitted';
        submitted.textContent = `Submitted ${formatDate(patient.submitted_at?.slice(0, 10))}`;
        const fields = [
            ['Fever', yesNo(patient.has_fever)],
            ['Previous severe reaction', yesNo(patient.severe_reaction)],
            ['Weak immune system', yesNo(patient.weak_immune_system)],
            ['Pregnant or breastfeeding', yesNo(patient.pregnant_or_breastfeeding)],
            ['Recent vaccine', yesNo(patient.recent_vaccine)],
            ['Bleeding disorder', yesNo(patient.bleeding_disorder)],
            ['Allergies reported', patient.precheck_allergies || 'None stated'],
            ['Medications', patient.medications || 'None stated'],
            ['Additional notes', patient.precheck_notes || 'None stated'],
        ];
        const table = document.createElement('dl');
        table.className = 'precheck-list';
        fields.forEach(([label, value]) => {
            const row = document.createElement('div');
            const term = document.createElement('dt');
            const description = document.createElement('dd');
            term.textContent = label;
            description.textContent = value;
            row.append(term, description);
            table.append(row);
        });
        precheck.append(title, submitted, table);
    }

    // Shows recorded doses, due dates, and whether a follow-up appointment exists.
    function renderHistory(patient) {
        history.replaceChildren();
        const records = patient.vaccination_history || [];
        if (!records.length) {
            const empty = document.createElement('p');
            empty.className = 'text-muted';
            empty.textContent = 'No vaccination doses have been recorded for this patient yet.';
            history.append(empty);
            return;
        }
        const items = document.createElement('div');
        items.className = 'vaccination-history-list';
        records.forEach((record) => {
            const item = document.createElement('article');
            item.className = 'vaccination-history-item';
            const heading = document.createElement('strong');
            heading.textContent = `${record.vaccine_name} · Dose ${record.dose_number}`;
            const given = document.createElement('p');
            given.textContent = `Given ${formatDate(record.date_given)}${record.doctor_name ? ` by Dr. ${record.doctor_name}` : ''}`;
            item.append(heading, given);
            const due = document.createElement('p');
            due.className = 'vaccination-next-dose';
            due.textContent = record.next_dose_date
                ? `Dose ${record.dose_number} of ${record.total_doses} recorded · Next dose due ${formatDate(record.next_dose_date)} · ${record.next_appointment_date ? `appointment ${formatDate(record.next_appointment_date)}${record.next_appointment_time ? ` at ${record.next_appointment_time}` : ''}` : 'no appointment booked yet'}`
                : 'No next-dose date recorded.';
            if (!record.next_dose_date) due.classList.add('is-unscheduled');
            item.append(due);
            if (record.notes) {
                const notes = document.createElement('p');
                notes.className = 'vaccination-history-notes';
                notes.textContent = record.notes;
                item.append(notes);
            }
            items.append(item);
        });
        history.append(items);
    }

    // Fills the vaccine selector and locks it when the appointment specifies a vaccine.
    function populateVaccines(patient) {
        vaccineSelect.replaceChildren();
        const prompt = document.createElement('option');
        prompt.value = '';
        prompt.textContent = 'Choose vaccine';
        vaccineSelect.append(prompt);
        vaccines.forEach((vaccine) => {
            const option = document.createElement('option');
            option.value = vaccine.vaccine_id;
            option.textContent = vaccine.name;
            vaccineSelect.append(option);
        });
        if (patient.vaccine_id) {
            vaccineSelect.value = String(patient.vaccine_id);
            vaccineSelect.disabled = true;
        } else {
            vaccineSelect.disabled = false;
        }
        vaccineSelect.onchange = () => populateBatches();
        populateBatches();
    }

    // Shows only available stock batches for the selected vaccine.
    function populateBatches() {
        const vaccineId = Number(vaccineSelect.value);
        batchSelect.replaceChildren();
        const noBatch = document.createElement('option');
        noBatch.value = '';
        noBatch.textContent = 'No batch selected';
        batchSelect.append(noBatch);
        batches.filter((batch) => Number(batch.vaccine_id) === vaccineId).forEach((batch) => {
            const option = document.createElement('option');
            option.value = batch.batch_id;
            option.textContent = `${batch.batch_number} · ${batch.quantity_in_stock} available${batch.expiry_date ? ` · expires ${formatDate(batch.expiry_date)}` : ''}`;
            batchSelect.append(option);
        });
    }

    // Loads the selected patient's details and prepares the vaccination record form.
    function selectPatient(patient, openModal = true) {
        selected = patient;
        renderRoster();
        details.replaceChildren();
        const heading = document.createElement('h3');
        heading.textContent = patient.child_name ? `${patient.child_name} (${patient.full_name})` : patient.full_name;
        const identity = document.createElement('p');
        identity.textContent = `Date of birth: ${formatDate(patient.child_dob || patient.dob)} · Phone: ${patient.phone || 'Not provided'}`;
        const appointment = document.createElement('p');
        appointment.textContent = `Appointment: ${formatDate(patient.appointment_date)}${patient.appointment_time ? ` at ${shortTime(patient.appointment_time)}` : ''} · ${patient.vaccine_name || 'Vaccine not assigned'}`;
        details.append(heading, identity, appointment);
        renderPrecheck(patient);
        historyButton.disabled = false;
        historyButton.setAttribute('aria-expanded', 'false');
        historyButton.textContent = 'View vaccination history';
        history.hidden = true;
        history.replaceChildren();
        document.getElementById('vaccinationDetailHint').textContent = patient.status === 'Completed'
            ? 'This appointment is completed. Review the patient details and recorded vaccination history.'
            : 'Review the screening responses and record the dose after administration.';
        form.hidden = patient.status === 'Completed';
        if (patient.status !== 'Completed') {
            document.getElementById('recordAppointmentId').value = patient.appointment_id;
            document.getElementById('recordDose').value = Math.max(1, Number(patient.previous_doses || 0) + 1);
            const now = new Date();
            const today = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
            const dateInput = document.getElementById('recordDate');
            dateInput.value = today;
            dateInput.max = today;
            const nextInput = document.getElementById('recordNextDose');
            nextInput.min = today;
            populateVaccines(patient);
        }
        if (openModal) window.bootstrap?.Modal.getOrCreateInstance(patientModalElement).show();
    }

    // Fetches the doctor's appointment roster, vaccine catalogue, and available batches.
    async function loadRoster() {
        setStatus('');
        scheduledList.innerHTML = '<p class="text-muted">Loading scheduled patients…</p>';
        completedList.innerHTML = '<p class="text-muted">Loading completed patients…</p>';
        try {
            const data = await VaxApi.get('doctor_vaccinations_backend.php');
            if (data.status !== 'success') throw new Error(data.message || 'Could not load vaccination patients.');
            roster = data.patients || [];
            vaccines = data.vaccines || [];
            batches = data.batches || [];
            selected = selected ? roster.find((item) => Number(item.appointment_id) === Number(selected.appointment_id)) || null : null;
            renderRoster();
            if (selected) selectPatient(selected, false);
        } catch (error) {
            setStatus(error.message || 'Could not load vaccination patients.', true);
            scheduledList.innerHTML = '<p class="text-muted">Patient list is unavailable.</p>';
            completedList.replaceChildren();
        }
    }

    document.getElementById('refreshVaccinationList').addEventListener('click', loadRoster);
    historyButton.addEventListener('click', () => {
        if (!selected) return;
        renderHistory(selected);
        history.hidden = !history.hidden;
        historyButton.setAttribute('aria-expanded', String(!history.hidden));
        historyButton.textContent = history.hidden ? 'View vaccination history' : 'Hide vaccination history';
    });
    form.addEventListener('submit', async (event) => {
        event.preventDefault();
        if (!selected) return;
        const button = document.getElementById('saveVaccinationRecord');
        button.disabled = true;
        setStatus('');
        try {
            const result = await VaxApi.post('doctor_vaccinations_backend.php', {
                appointment_id: Number(document.getElementById('recordAppointmentId').value),
                vaccine_id: Number(vaccineSelect.value),
                batch_id: batchSelect.value ? Number(batchSelect.value) : null,
                dose_number: Number(document.getElementById('recordDose').value),
                date_given: document.getElementById('recordDate').value,
                next_dose_date: document.getElementById('recordNextDose').value,
                notes: document.getElementById('recordNotes').value.trim(),
            });
            const successMessage = result.message || 'Vaccination record saved.';
            selected = null;
            form.reset();
            form.hidden = true;
            window.bootstrap?.Modal.getOrCreateInstance(patientModalElement).hide();
            await loadRoster();
            setStatus(successMessage);
        } catch (error) {
            setStatus(error.message || 'Vaccination record could not be saved.', true);
        } finally {
            button.disabled = false;
        }
    });

    document.addEventListener('DOMContentLoaded', loadRoster);
})();
