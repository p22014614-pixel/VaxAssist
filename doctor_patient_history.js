// Opens and renders authorized patient and vaccination history in the Patient Record modal.
(() => {
    const details = document.getElementById('patientHistoryDetails');
    const modalElement = document.getElementById('patientHistoryModal');
    const openButton = document.getElementById('viewPatientHistory');

    // Formats stored SQL dates as local display dates without shifting the calendar day.
    function formatDate(value) {
        if (!value) return 'Not provided';
        const date = new Date(`${value}T12:00:00`);
        return Number.isNaN(date.getTime()) ? value : new Intl.DateTimeFormat(undefined, { dateStyle: 'medium' }).format(date);
    }

    // Adds a label and plain-text value to a patient information grid.
    function addField(container, label, value) {
        const item = document.createElement('div');
        item.className = 'patient-history-field';
        const title = document.createElement('span');
        title.textContent = label;
        const text = document.createElement('strong');
        text.textContent = value === null || value === undefined || value === '' ? 'Not recorded' : String(value);
        item.append(title, text);
        container.append(item);
    }

    // Renders the full stored profile, dependents, appointment list, and dose history.
    function renderPatient(data) {
        const patient = data.patient;
        details.replaceChildren();
        const heading = document.createElement('div');
        heading.className = 'patient-history-heading';
        const name = document.createElement('h2');
        name.id = 'patientHistoryName';
        name.textContent = patient.full_name;
        const id = document.createElement('span');
        id.className = 'patient-history-id';
        id.textContent = `Patient ID ${patient.patient_id}`;
        heading.append(name, id);
        details.append(heading);

        const profile = document.createElement('section');
        profile.className = 'patient-history-section';
        const profileTitle = document.createElement('h3');
        profileTitle.textContent = 'Patient information';
        const fields = document.createElement('div');
        fields.className = 'patient-history-fields';
        addField(fields, 'IC / passport', patient.ic_passport);
        addField(fields, 'Email', patient.email);
        addField(fields, 'Phone', patient.phone);
        addField(fields, 'Date of birth', formatDate(patient.dob));
        addField(fields, 'Gender', patient.gender);
        addField(fields, 'Blood type', patient.blood_type);
        addField(fields, 'Allergies', Number(patient.no_known_allergies) === 1 ? 'No known allergies' : patient.allergies);
        addField(fields, 'Address', patient.address);
        addField(fields, 'Emergency contact', patient.emergency_contact_name);
        addField(fields, 'Emergency phone', patient.emergency_contact_phone);
        addField(fields, 'Height', patient.height_cm ? `${patient.height_cm} cm` : null);
        addField(fields, 'Weight', patient.weight_kg ? `${patient.weight_kg} kg` : null);
        profile.append(profileTitle, fields);
        details.append(profile);

        const dependents = document.createElement('section');
        dependents.className = 'patient-history-section';
        const dependentsTitle = document.createElement('h3');
        dependentsTitle.textContent = 'Children on this patient account';
        dependents.append(dependentsTitle);
        const children = data.children || [];
        if (!children.length) {
            const noChildren = document.createElement('p');
            noChildren.className = 'text-muted';
            noChildren.textContent = 'No children are linked to this patient account.';
            dependents.append(noChildren);
        } else {
            const childList = document.createElement('div');
            childList.className = 'patient-history-child-list';
            children.forEach((child) => {
                const item = document.createElement('div');
                item.className = 'patient-history-child';
                const childName = document.createElement('strong');
                childName.textContent = child.first_name;
                const childInfo = document.createElement('span');
                childInfo.textContent = `${child.gender} · DOB ${formatDate(child.dob)}`;
                item.append(childName, childInfo);
                childList.append(item);
            });
            dependents.append(childList);
        }
        details.append(dependents);

        const healthSection = document.createElement('section');
        healthSection.className = 'patient-history-section';
        const healthTitle = document.createElement('h3');
        healthTitle.textContent = 'Health items';
        healthSection.append(healthTitle);
        const healthItems = data.health_items || [];
        if (!healthItems.length) {
            const none = document.createElement('p');
            none.className = 'text-muted';
            none.textContent = 'No additional allergies, conditions, or medications are recorded.';
            healthSection.append(none);
        } else {
            const list = document.createElement('div');
            list.className = 'patient-history-child-list';
            healthItems.forEach((healthItem) => {
                const item = document.createElement('div');
                item.className = 'patient-history-child';
                const type = document.createElement('strong');
                type.textContent = healthItem.item_type;
                const value = document.createElement('span');
                value.textContent = healthItem.name;
                item.append(type, value);
                list.append(item);
            });
            healthSection.append(list);
        }
        details.append(healthSection);

        const upcomingSection = document.createElement('section');
        upcomingSection.className = 'patient-history-section';
        const upcomingTitle = document.createElement('h3');
        upcomingTitle.textContent = 'Upcoming appointments';
        upcomingSection.append(upcomingTitle);
        const upcoming = data.upcoming_appointments || [];
        if (!upcoming.length) {
            const none = document.createElement('p');
            none.className = 'text-muted';
            none.textContent = 'There are no upcoming scheduled appointments.';
            upcomingSection.append(none);
        } else {
            const upcomingList = document.createElement('div');
            upcomingList.className = 'patient-history-upcoming-list';
            upcoming.forEach((appointment) => {
                const item = document.createElement('div');
                item.className = 'patient-history-upcoming';
                const title = document.createElement('strong');
                title.textContent = `${appointment.vaccine_name || 'Clinic appointment'}${appointment.child_name ? ` · ${appointment.child_name}` : ''}`;
                const info = document.createElement('span');
                info.textContent = `${formatDate(appointment.appointment_date)}${appointment.appointment_time ? ` at ${String(appointment.appointment_time).slice(0, 5)}` : ` · ${appointment.time_slot}`}${appointment.doctor_name ? ` · Dr. ${appointment.doctor_name}` : ''}`;
                item.append(title, info);
                upcomingList.append(item);
            });
            upcomingSection.append(upcomingList);
        }
        details.append(upcomingSection);

        const historySection = document.createElement('section');
        historySection.className = 'patient-history-section';
        const historyTitle = document.createElement('h3');
        historyTitle.textContent = 'Vaccination history';
        historySection.append(historyTitle);
        const records = data.vaccination_history || [];
        if (!records.length) {
            const none = document.createElement('p');
            none.className = 'text-muted';
            none.textContent = 'No vaccination records have been entered for this patient or their children.';
            historySection.append(none);
        } else {
            const historyList = document.createElement('div');
            historyList.className = 'patient-history-dose-list';
            records.forEach((record) => {
                const item = document.createElement('article');
                item.className = 'patient-history-dose';
                const doseTitle = document.createElement('strong');
                doseTitle.textContent = `${record.vaccine_name} · Dose ${record.dose_number}${record.child_name ? ` · ${record.child_name}` : ''}`;
                const given = document.createElement('p');
                given.textContent = `Given ${formatDate(record.date_given)}${record.doctor_name ? ` by Dr. ${record.doctor_name}` : ''}${record.batch_number ? ` · Batch ${record.batch_number}` : ''}`;
                const due = document.createElement('p');
                due.className = 'patient-history-next-dose';
                due.textContent = record.next_dose_date
                    ? `Next dose due ${formatDate(record.next_dose_date)}${record.next_appointment_date ? ` · booked ${formatDate(record.next_appointment_date)}${record.next_appointment_time ? ` at ${record.next_appointment_time}` : ''}` : ' · no appointment booked'}`
                    : 'No next-dose date recorded.';
                item.append(doseTitle, given, due);
                if (record.notes) {
                    const notes = document.createElement('p');
                    notes.className = 'patient-history-notes';
                    notes.textContent = record.notes;
                    item.append(notes);
                }
                historyList.append(item);
            });
            historySection.append(historyList);
        }
        details.append(historySection);

        const consultationSection = document.createElement('section');
        consultationSection.className = 'patient-history-section';
        const consultationTitle = document.createElement('h3');
        consultationTitle.textContent = 'Consultation notes';
        consultationSection.append(consultationTitle);
        const consultations = data.consultation_history || [];
        if (!consultations.length) {
            const none = document.createElement('p');
            none.className = 'text-muted';
            none.textContent = 'No consultation notes have been recorded.';
            consultationSection.append(none);
        } else {
            const noteList = document.createElement('div');
            noteList.className = 'patient-history-dose-list';
            consultations.forEach((consultation) => {
                const note = document.createElement('article');
                note.className = 'patient-history-dose';
                const noteHeading = document.createElement('strong');
                noteHeading.textContent = `${formatDate(String(consultation.created_at).slice(0, 10))}${consultation.doctor_name ? ` · Dr. ${consultation.doctor_name}` : ''}`;
                note.append(noteHeading);
                [['Subjective', consultation.subjective_notes], ['Objective', consultation.objective_notes], ['Assessment', consultation.assessment], ['Plan', consultation.plan]].forEach(([label, value]) => {
                    if (!value) return;
                    const line = document.createElement('p');
                    line.textContent = `${label}: ${value}`;
                    note.append(line);
                });
                noteList.append(note);
            });
            consultationSection.append(noteList);
        }
        details.append(consultationSection);
    }

    // Loads the currently selected patient only after the doctor opens the history modal.
    async function loadSelectedPatient() {
        const patientId = document.getElementById('activePatientId')?.value;
        if (!patientId) return;
        details.innerHTML = '<p class="patient-history-placeholder">Loading patient history…</p>';
        try {
            const data = await VaxApi.get(`doctor_patient_history_backend.php?patient_id=${encodeURIComponent(patientId)}`);
            if (data.status !== 'success') throw new Error(data.message || 'Could not load this patient.');
            renderPatient(data);
        } catch (error) {
            details.replaceChildren();
            const message = document.createElement('p');
            message.className = 'patient-history-placeholder';
            message.textContent = error.message || 'Could not load this patient.';
            details.append(message);
        }
    }

    // Opens the Bootstrap dialog, then fetches the selected patient's database history.
    openButton.addEventListener('click', () => {
        if (!document.getElementById('activePatientId')?.value) return;
        bootstrap.Modal.getOrCreateInstance(modalElement).show();
        loadSelectedPatient();
    });
})();
