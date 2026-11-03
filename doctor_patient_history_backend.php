<?php
// Returns full history only for a patient connected to the signed-in doctor.
require __DIR__ . '/doctor_backend_auth.php';

function doctor_patient_history_authorized(mysqli $conn, int $patientId, int $doctorId): bool
{
    $stmt = $conn->prepare("SELECT 1 FROM patients p
        WHERE p.patient_id = ? AND (
            EXISTS (SELECT 1 FROM appointments a WHERE a.patient_id = p.patient_id AND a.doctor_id = ?)
            OR EXISTS (SELECT 1 FROM messages m WHERE m.patient_id = p.patient_id AND m.doctor_id = ?)
            OR EXISTS (SELECT 1 FROM doctor_patient_links l WHERE l.patient_id = p.patient_id AND l.doctor_id = ?)
        ) LIMIT 1");
    $stmt->bind_param('iiii', $patientId, $doctorId, $doctorId, $doctorId);
    $stmt->execute();
    return (bool) $stmt->get_result()->fetch_row();
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Method not allowed.']);
    exit;
}

if (isset($_GET['patient_id'])) {
    $patientId = filter_var($_GET['patient_id'], FILTER_VALIDATE_INT);
    if (!$patientId || !doctor_patient_history_authorized($conn, (int) $patientId, $doctor_id)) {
        http_response_code(404);
        echo json_encode(['status' => 'error', 'message' => 'Patient not found in your care.']);
        exit;
    }

    $patientQuery = $conn->prepare('SELECT patient_id, full_name, ic_passport, email, phone, dob, gender, blood_type, allergies,
            address, emergency_contact_name, emergency_contact_phone, height_cm, weight_kg, no_known_allergies, created_at
        FROM patients WHERE patient_id = ? LIMIT 1');
    $patientQuery->bind_param('i', $patientId);
    $patientQuery->execute();
    $patient = $patientQuery->get_result()->fetch_assoc();

    $childrenQuery = $conn->prepare('SELECT child_id, first_name, dob, gender, created_at FROM children WHERE patient_id = ? ORDER BY dob, first_name');
    $childrenQuery->bind_param('i', $patientId);
    $childrenQuery->execute();
    $children = $childrenQuery->get_result()->fetch_all(MYSQLI_ASSOC);

    $healthQuery = $conn->prepare('SELECT item_type, name FROM patient_health_items WHERE patient_id = ? ORDER BY item_type, name');
    $healthQuery->bind_param('i', $patientId);
    $healthQuery->execute();
    $healthItems = $healthQuery->get_result()->fetch_all(MYSQLI_ASSOC);

    $consultationQuery = $conn->prepare("SELECT cr.subjective_notes, cr.objective_notes, cr.assessment, cr.plan, cr.created_at,
            CONCAT_WS(' ', d.first_name, d.last_name) AS doctor_name
        FROM consultation_records cr
        LEFT JOIN doctors d ON d.doctor_id = cr.doctor_id
        WHERE cr.patient_id = ?
        ORDER BY cr.created_at DESC, cr.record_id DESC");
    $consultationQuery->bind_param('i', $patientId);
    $consultationQuery->execute();
    $consultations = $consultationQuery->get_result()->fetch_all(MYSQLI_ASSOC);

    $historyQuery = $conn->prepare("SELECT vr.record_id, vr.child_id, c.first_name AS child_name, vr.vaccine_id,
            v.name AS vaccine_name, vr.batch_id, vb.batch_number, vr.dose_number, vr.date_given, vr.next_dose_date,
            vr.notes, CONCAT_WS(' ', d.first_name, d.last_name) AS doctor_name,
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
        LEFT JOIN children c ON c.child_id = vr.child_id AND c.patient_id = vr.patient_id
        LEFT JOIN vaccine_batches vb ON vb.batch_id = vr.batch_id
        LEFT JOIN doctors d ON d.doctor_id = vr.doctor_id
        WHERE vr.patient_id = ?
        ORDER BY vr.date_given DESC, vr.record_id DESC");
    $historyQuery->bind_param('i', $patientId);
    $historyQuery->execute();
    $history = $historyQuery->get_result()->fetch_all(MYSQLI_ASSOC);

    $upcomingQuery = $conn->prepare("SELECT a.appointment_id, a.appointment_date, a.appointment_time, a.time_slot,
            a.status, a.child_id, c.first_name AS child_name, v.name AS vaccine_name,
            CONCAT_WS(' ', d.first_name, d.last_name) AS doctor_name
        FROM appointments a
        LEFT JOIN children c ON c.child_id = a.child_id AND c.patient_id = a.patient_id
        LEFT JOIN vaccines v ON v.vaccine_id = a.vaccine_id
        JOIN doctors d ON d.doctor_id = a.doctor_id
        WHERE a.patient_id = ? AND a.status = 'Scheduled' AND a.appointment_date >= CURRENT_DATE()
        ORDER BY a.appointment_date, a.appointment_time, a.appointment_id");
    $upcomingQuery->bind_param('i', $patientId);
    $upcomingQuery->execute();
    $upcoming = $upcomingQuery->get_result()->fetch_all(MYSQLI_ASSOC);

    echo json_encode(['status' => 'success', 'patient' => $patient, 'children' => $children,
        'health_items' => $healthItems, 'consultation_history' => $consultations,
        'vaccination_history' => $history, 'upcoming_appointments' => $upcoming], JSON_UNESCAPED_UNICODE);
    exit;
}

http_response_code(422);
echo json_encode(['status' => 'error', 'message' => 'Select a patient from Patient Record.']);
