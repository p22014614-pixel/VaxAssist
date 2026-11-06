<?php
// Serves only the signed-in doctor's appointments and records completed vaccination doses.
require __DIR__ . '/doctor_backend_auth.php';

// Sends a JSON response and stops further request processing.
function vaccine_json(array $payload, int $status = 200): void
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($payload, JSON_UNESCAPED_UNICODE);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Loads the doctor's scheduled patients, their appointment-linked pre-checks, and vaccine stock.
    $stmt = $conn->prepare("SELECT a.appointment_id, a.patient_id, a.child_id, a.vaccine_id, a.appointment_date, a.appointment_time, a.time_slot, a.status, a.symptoms_notes,
            p.full_name, p.dob, p.phone, c.first_name AS child_name, c.dob AS child_dob, v.name AS vaccine_name, v.total_doses,
            pf.form_id, pf.has_fever, pf.severe_reaction, pf.weak_immune_system, pf.pregnant_or_breastfeeding, pf.recent_vaccine,
            pf.bleeding_disorder, pf.allergies AS precheck_allergies, pf.medications, pf.notes AS precheck_notes, pf.submitted_at
            , COALESCE((SELECT MAX(vr.dose_number) FROM vaccination_records vr WHERE vr.patient_id = a.patient_id AND vr.vaccine_id = a.vaccine_id AND (vr.child_id <=> a.child_id)), 0) AS previous_doses
        FROM appointments a
        JOIN patients p ON p.patient_id = a.patient_id
        LEFT JOIN children c ON c.child_id = a.child_id AND c.patient_id = a.patient_id
        LEFT JOIN vaccines v ON v.vaccine_id = a.vaccine_id
        LEFT JOIN precheck_forms pf ON pf.form_id = (
            SELECT pf2.form_id FROM precheck_forms pf2
            WHERE pf2.appointment_id = a.appointment_id
              AND pf2.patient_id = a.patient_id
            ORDER BY pf2.submitted_at DESC, pf2.form_id DESC
            LIMIT 1
        )
        WHERE a.doctor_id = ? AND a.status IN ('Scheduled', 'Completed')
        ORDER BY CASE WHEN a.status = 'Scheduled' THEN 0 ELSE 1 END,
            CASE WHEN a.status = 'Scheduled' THEN a.appointment_date END ASC,
            CASE WHEN a.status = 'Completed' THEN a.appointment_date END DESC,
            a.appointment_time, a.appointment_id");
    $stmt->bind_param('i', $doctor_id);
    $stmt->execute();
    $patients = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);

    // Adds each patient's dose history and whether the next due date is already booked.
    $historyQuery = $conn->prepare("SELECT vr.record_id, vr.dose_number, vr.date_given, vr.next_dose_date, vr.notes,
            v.name AS vaccine_name, CONCAT_WS(' ', d.first_name, d.last_name) AS doctor_name,
            (SELECT a2.appointment_date FROM appointments a2
                WHERE a2.patient_id = vr.patient_id AND a2.child_id <=> vr.child_id
                  AND a2.vaccine_id = vr.vaccine_id AND a2.status = 'Scheduled'
                  AND vr.next_dose_date IS NOT NULL AND a2.appointment_date >= CURRENT_DATE()
                ORDER BY a2.appointment_date, a2.appointment_time LIMIT 1) AS next_appointment_date,
            (SELECT COALESCE(TIME_FORMAT(a2.appointment_time, '%H:%i'), a2.time_slot) FROM appointments a2
                WHERE a2.patient_id = vr.patient_id AND a2.child_id <=> vr.child_id
                  AND a2.vaccine_id = vr.vaccine_id AND a2.status = 'Scheduled'
                  AND vr.next_dose_date IS NOT NULL AND a2.appointment_date >= CURRENT_DATE()
                ORDER BY a2.appointment_date, a2.appointment_time LIMIT 1) AS next_appointment_time
        FROM vaccination_records vr
        JOIN vaccines v ON v.vaccine_id = vr.vaccine_id
        LEFT JOIN doctors d ON d.doctor_id = vr.doctor_id
        WHERE vr.patient_id = ? AND vr.child_id <=> ?
        ORDER BY vr.date_given DESC, vr.record_id DESC");
    foreach ($patients as &$patient) {
        $childId = $patient['child_id'] === null ? null : (int) $patient['child_id'];
        $patientId = (int) $patient['patient_id'];
        $historyQuery->bind_param('ii', $patientId, $childId);
        $historyQuery->execute();
        $patient['vaccination_history'] = $historyQuery->get_result()->fetch_all(MYSQLI_ASSOC);
    }
    unset($patient);

    $vaccines = $conn->query('SELECT vaccine_id, name, total_doses FROM vaccines ORDER BY name')->fetch_all(MYSQLI_ASSOC);
    $batches = $conn->query("SELECT batch_id, vaccine_id, batch_number, expiry_date, quantity_in_stock
        FROM vaccine_batches WHERE quantity_in_stock > 0 AND (expiry_date IS NULL OR expiry_date >= CURRENT_DATE()) ORDER BY expiry_date, batch_number")->fetch_all(MYSQLI_ASSOC);
    vaccine_json(['status' => 'success', 'patients' => $patients, 'vaccines' => $vaccines, 'batches' => $batches]);
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') vaccine_json(['status' => 'error', 'message' => 'Method not allowed.'], 405);

// Validates and saves the dose, completes its appointment, adjusts stock, and notifies the patient.
$input = json_decode(file_get_contents('php://input'), true) ?: [];
$appointmentId = filter_var($input['appointment_id'] ?? null, FILTER_VALIDATE_INT);
$vaccineId = filter_var($input['vaccine_id'] ?? null, FILTER_VALIDATE_INT);
$batchId = empty($input['batch_id']) ? null : filter_var($input['batch_id'], FILTER_VALIDATE_INT);
$doseNumber = filter_var($input['dose_number'] ?? null, FILTER_VALIDATE_INT);
$dateGiven = (string) ($input['date_given'] ?? '');
$nextDoseDate = trim((string) ($input['next_dose_date'] ?? ''));
$notes = trim((string) ($input['notes'] ?? ''));
$validDate = DateTime::createFromFormat('Y-m-d', $dateGiven);
$validNextDate = $nextDoseDate === '' ? null : DateTime::createFromFormat('Y-m-d', $nextDoseDate);
if (!$appointmentId || !$vaccineId || !$doseNumber || $doseNumber > 20 || !$validDate || $validDate->format('Y-m-d') !== $dateGiven || $dateGiven > date('Y-m-d') || ($nextDoseDate !== '' && (!$validNextDate || $validNextDate->format('Y-m-d') !== $nextDoseDate || $nextDoseDate < $dateGiven)) || mb_strlen($notes) > 2000 || ($batchId !== null && !$batchId)) {
    vaccine_json(['status' => 'error', 'message' => 'Check the appointment, vaccine, dose number, dates, and notes.'], 422);
}

try {
    $conn->begin_transaction();
    $appointment = $conn->prepare("SELECT appointment_id, patient_id, child_id, vaccine_id, appointment_date FROM appointments WHERE appointment_id = ? AND doctor_id = ? AND status = 'Scheduled' FOR UPDATE");
    $appointment->bind_param('ii', $appointmentId, $doctor_id);
    $appointment->execute();
    $visit = $appointment->get_result()->fetch_assoc();
    if (!$visit) throw new RuntimeException('This appointment is no longer scheduled or is not assigned to your account.');
    if ($visit['appointment_date'] > $dateGiven) throw new RuntimeException('The vaccination date cannot be before the appointment date.');
    if ($visit['vaccine_id'] !== null && (int) $visit['vaccine_id'] !== $vaccineId) throw new RuntimeException('Choose the vaccine assigned to this appointment.');

    $duplicate = $conn->prepare('SELECT record_id FROM vaccination_records WHERE appointment_id = ? LIMIT 1 FOR UPDATE');
    $duplicate->bind_param('i', $appointmentId);
    $duplicate->execute();
    if ($duplicate->get_result()->fetch_row()) throw new RuntimeException('A vaccination record already exists for this appointment.');

    $vaccine = $conn->prepare('SELECT name FROM vaccines WHERE vaccine_id = ?');
    $vaccine->bind_param('i', $vaccineId);
    $vaccine->execute();
    $vaccineRow = $vaccine->get_result()->fetch_row();
    $vaccineName = $vaccineRow[0] ?? null;
    if (!$vaccineName) throw new RuntimeException('The selected vaccine could not be found.');

    if ($batchId !== null) {
        $batch = $conn->prepare('SELECT vaccine_id, quantity_in_stock, expiry_date FROM vaccine_batches WHERE batch_id = ? FOR UPDATE');
        $batch->bind_param('i', $batchId);
        $batch->execute();
        $batchRow = $batch->get_result()->fetch_assoc();
        if (!$batchRow || (int) $batchRow['vaccine_id'] !== $vaccineId || (int) $batchRow['quantity_in_stock'] < 1 || ($batchRow['expiry_date'] !== null && $batchRow['expiry_date'] < $dateGiven)) throw new RuntimeException('That vaccine batch is unavailable, expired, or belongs to another vaccine.');
        $decrement = $conn->prepare('UPDATE vaccine_batches SET quantity_in_stock = quantity_in_stock - 1 WHERE batch_id = ? AND quantity_in_stock > 0');
        $decrement->bind_param('i', $batchId);
        $decrement->execute();
        if ($decrement->affected_rows !== 1) throw new RuntimeException('The selected batch is out of stock.');
    }

    $patientId = (int) $visit['patient_id'];
    $childId = $visit['child_id'] === null ? null : (int) $visit['child_id'];
    $record = $conn->prepare('INSERT INTO vaccination_records (patient_id, child_id, vaccine_id, batch_id, doctor_id, appointment_id, dose_number, date_given, next_dose_date, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');
    $nextDoseValue = $nextDoseDate === '' ? null : $nextDoseDate;
    $record->bind_param('iiiiiiisss', $patientId, $childId, $vaccineId, $batchId, $doctor_id, $appointmentId, $doseNumber, $dateGiven, $nextDoseValue, $notes);
    $record->execute();

    $finish = $conn->prepare("UPDATE appointments SET status = 'Completed' WHERE appointment_id = ? AND doctor_id = ? AND status = 'Scheduled'");
    $finish->bind_param('ii', $appointmentId, $doctor_id);
    $finish->execute();
    if ($finish->affected_rows !== 1) throw new RuntimeException('Could not complete the appointment.');

    $patient = $conn->prepare('SELECT full_name FROM patients WHERE patient_id = ?');
    $patient->bind_param('i', $visit['patient_id']);
    $patient->execute();
    $patientRow = $patient->get_result()->fetch_row();
    $patientName = $patientRow[0] ?? 'Your patient';
    $notificationType = $nextDoseDate !== '' ? 'Booster' : 'Appointment';
    $title = $nextDoseDate !== '' ? 'Next vaccine dose recorded' : 'Vaccination recorded';
    $body = $nextDoseDate !== ''
        ? $vaccineName . ' dose ' . $doseNumber . ' was recorded for ' . $patientName . '. Next dose due ' . $nextDoseDate . '.'
        : $vaccineName . ' dose ' . $doseNumber . ' was recorded for ' . $patientName . '.';
    $notify = $conn->prepare('INSERT INTO notifications (patient_id, doctor_id, appointment_id, type, title, body, action_url, action_label) VALUES (?, ?, ?, ?, ?, ?, ?, ?)');
    $url = 'appointments.html';
    $label = 'View appointment';
    $notify->bind_param('iiisssss', $patientId, $doctor_id, $appointmentId, $notificationType, $title, $body, $url, $label);
    $notify->execute();

    $conn->commit();
    vaccine_json(['status' => 'success', 'message' => 'Vaccination recorded, appointment completed, and patient notification created.']);
} catch (Throwable $error) {
    $conn->rollback();
    $code = $error instanceof RuntimeException ? 409 : 500;
    error_log('Doctor vaccination record failed: ' . $error->getMessage());
    vaccine_json(['status' => 'error', 'message' => $error->getMessage()], $code);
}
