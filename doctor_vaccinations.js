// Loads the doctor's assigned vaccination appointments, pre-checks, and dose-record form.
(() => {
    const list = document.getElementById('vaccinationPatientList');
    const details = document.getElementById('vaccinationPatientDetails');
    const precheck = document.getElementById('precheckDetails');
    const form = document.getElementById('vaccinationRecordForm');
    const vaccineSelect = document.getElementById('recordVaccine');
    const batchSelect = document.getElementById('recordBatch');
    const status = document.getElementById('vaccinationLoadStatus');
    const downloadButton = document.getElementById('downloadPrecheck');
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

    // Builds the list of scheduled patients assigned to this doctor.
    function renderRoster() {
        list.replaceChildren();
        if (!roster.length) {
            const empty = document.createElement('p');
            empty.className = 'text-muted';
            empty.textContent = 'There are no scheduled appointments assigned to you.';
            list.append(empty);
            return;
        }
        roster.forEach((patient) => {
            const button = document.createElement('button');
            button.type = 'button';
            button.className = `vaccination-patient-card${selected?.appointment_id === patient.appointment_id ? ' is-selected' : ''}`;
            button.dataset.appointmentId = patient.appointment_id;
            const name = document.createElement('strong');
            name.textContent = patient.child_name ? `${patient.child_name} (${patient.full_name})` : patient.full_name;
            const vaccine = document.createElement('span');
            vaccine.textContent = patient.vaccine_name || 'Vaccine not assigned';
            const date = document.createElement('small');
            date.textContent = `${formatDate(patient.appointment_date)}${patient.appointment_time ? ` · ${patient.appointment_time}` : ''}`;
            const form = document.createElement('small');
            form.className = patient.form_id ? 'precheck-available' : 'precheck-missing';
            form.textContent = patient.form_id ? 'Pre-check available' : 'No pre-check form';
            button.append(name, vaccine, date, form);
            button.addEventListener('click', () => selectPatient(patient));
            list.append(button);
        });
    }

    // Displays the pre-check form linked to the selected appointment.
    function renderPrecheck(patient) {
        precheck.replaceChildren();
        if (!patient.form_id) {
            const empty = document.createElement('p');
            empty.className = 'precheck-empty';
            empty.textContent = 'No pre-check form has been submitted for this appointment. Confirm relevant screening information with the patient before vaccination.';
            precheck.append(empty);
            downloadButton.disabled = true;
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
        downloadButton.disabled = false;
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
    function selectPatient(patient) {
        selected = patient;
        renderRoster();
        details.replaceChildren();
        const heading = document.createElement('h3');
        heading.textContent = patient.child_name ? `${patient.child_name} (${patient.full_name})` : patient.full_name;
        const identity = document.createElement('p');
        identity.textContent = `Date of birth: ${formatDate(patient.child_dob || patient.dob)} · Phone: ${patient.phone || 'Not provided'}`;
        const appointment = document.createElement('p');
        appointment.textContent = `Appointment: ${formatDate(patient.appointment_date)}${patient.appointment_time ? ` at ${patient.appointment_time}` : ''} · ${patient.vaccine_name || 'Vaccine not assigned'}`;
        details.append(heading, identity, appointment);
        renderPrecheck(patient);
        document.getElementById('vaccinationDetailHint').textContent = 'Review the screening responses and record the dose after administration.';
        form.hidden = false;
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

    // Fetches the doctor's appointment roster, vaccine catalogue, and available batches.
    async function loadRoster() {
        setStatus('');
        list.innerHTML = '<p class="text-muted">Loading scheduled patients…</p>';
        try {
            const data = await VaxApi.get('doctor_vaccinations_backend.php');
            if (data.status !== 'success') throw new Error(data.message || 'Could not load vaccination patients.');
            roster = data.patients || [];
            vaccines = data.vaccines || [];
            batches = data.batches || [];
            selected = selected ? roster.find((item) => Number(item.appointment_id) === Number(selected.appointment_id)) || null : null;
            renderRoster();
            if (selected) selectPatient(selected);
            else {
                details.innerHTML = '<p class="text-muted">Select a scheduled patient to review their details.</p>';
                precheck.innerHTML = '<p class="text-muted">Pre-check form details will appear here.</p>';
                form.hidden = true;
                downloadButton.disabled = true;
            }
        } catch (error) {
            setStatus(error.message || 'Could not load vaccination patients.', true);
            list.innerHTML = '<p class="text-muted">Patient list is unavailable.</p>';
        }
    }

    // Downloads the selected appointment's pre-check responses as a CSV file.
    function downloadPrecheckCsv() {
        if (!selected?.form_id) return;
        const rows = [
            ['Patient', selected.child_name ? `${selected.child_name} (${selected.full_name})` : selected.full_name],
            ['Appointment date', selected.appointment_date],
            ['Vaccine', selected.vaccine_name || 'Not assigned'],
            ['Submitted at', selected.submitted_at],
            ['Fever', yesNo(selected.has_fever)],
            ['Previous severe reaction', yesNo(selected.severe_reaction)],
            ['Weak immune system', yesNo(selected.weak_immune_system)],
            ['Pregnant or breastfeeding', yesNo(selected.pregnant_or_breastfeeding)],
            ['Recent vaccine', yesNo(selected.recent_vaccine)],
            ['Bleeding disorder', yesNo(selected.bleeding_disorder)],
            ['Allergies', selected.precheck_allergies || 'None stated'],
            ['Medications', selected.medications || 'None stated'],
            ['Notes', selected.precheck_notes || 'None stated'],
        ];
        const csv = rows.map((row) => row.map((cell) => {
            let value = String(cell ?? '');
            if (/^[=+\-@\t\r]/.test(value)) value = `'${value}`;
            return `"${value.replace(/"/g, '""')}"`;
        }).join(',')).join('\r\n');
        const url = URL.createObjectURL(new Blob(['\ufeff', csv], { type: 'text/csv;charset=utf-8' }));
        const link = document.createElement('a');
        link.href = url;
        link.download = `VaxAssist_Precheck_${selected.patient_id}_${selected.appointment_id}.csv`;
        link.click();
        URL.revokeObjectURL(url);
    }

    document.getElementById('refreshVaccinationList').addEventListener('click', loadRoster);
    downloadButton.addEventListener('click', downloadPrecheckCsv);
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
            details.innerHTML = '<p class="text-muted">Select another scheduled patient to continue.</p>';
            precheck.innerHTML = '<p class="text-muted">Pre-check form details will appear here.</p>';
            downloadButton.disabled = true;
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
