<?php
declare(strict_types=1);

require_once __DIR__ . '/admin_backend_auth.php';
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

function respond(int $status, array $data): void
{
    http_response_code($status);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
    exit;
}




$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

if (!in_array($method, ['GET', 'POST', 'PUT', 'DELETE'], true)) {
    header('Allow: GET, POST, PUT, DELETE');
    respond(405, ['error' => 'Method not allowed.']);
}

if ($method === 'GET') {
    if (empty($_SESSION['appointment_csrf'])) {
        $_SESSION['appointment_csrf'] = bin2hex(random_bytes(32));
    }

    try {
        $appointments = $pdo->query(
            'SELECT a.appointment_id, a.doctor_id, a.patient_id,
                    a.appointment_date, a.time_slot, a.status,
                    a.symptoms_notes, a.edit_reason, a.created_at,
                    TRIM(CONCAT(d.first_name, " ", d.last_name)) AS doctor_name
             FROM appointments AS a
             LEFT JOIN doctors AS d ON d.doctor_id = a.doctor_id
             ORDER BY a.appointment_date, a.time_slot, a.appointment_id'
        )->fetchAll();

        $doctors = $pdo->query(
            'SELECT doctor_id,
                    TRIM(CONCAT(first_name, " ", last_name)) AS doctor_name
             FROM doctors
             ORDER BY first_name, last_name, doctor_id'
        )->fetchAll();

        respond(200, [
            'appointments' => $appointments,
            'doctors' => $doctors,
            'csrfToken' => $_SESSION['appointment_csrf'],
        ]);
    } catch (Throwable $exception) {
        error_log('Appointment API error: ' . $exception->getMessage());
        respond(500, ['error' => 'Could not load appointments. Check the database connection and tables.']);
    }
}

$providedToken = (string) ($_SERVER['HTTP_X_CSRF_TOKEN'] ?? '');

if (
    empty($_SESSION['appointment_csrf']) ||
    !hash_equals($_SESSION['appointment_csrf'], $providedToken)
) {
    respond(403, ['error' => 'Your session expired. Refresh the page and try again.']);
}

$payload = json_decode((string) file_get_contents('php://input'), true);

if (!is_array($payload)) {
    respond(400, ['error' => 'Invalid request data.']);
}

$validTimeSlots = [
    '08:00 AM - 10:00 AM',
    '10:00 AM - 12:00 PM',
    '01:00 PM - 03:00 PM',
    '03:00 PM - 05:00 PM',
];

$validStatuses = ['Scheduled', 'Confirmed', 'Missed', 'Completed', 'Cancelled'];

function validDate(string $date): bool
{
    $value = DateTimeImmutable::createFromFormat('!Y-m-d', $date);
    $errors = DateTimeImmutable::getLastErrors();

    return $value !== false
        && ($errors === false ||
            ($errors['warning_count'] === 0 && $errors['error_count'] === 0))
        && $value->format('Y-m-d') === $date;
}

try {
    if ($method === 'DELETE') {
        $appointmentId = filter_var(
            $payload['appointment_id'] ?? null,
            FILTER_VALIDATE_INT,
            ['options' => ['min_range' => 1]]
        );

        if (!$appointmentId) {
            respond(422, ['error' => 'A valid appointment ID is required.']);
        }

        $delete = $pdo->prepare(
            'DELETE FROM appointments WHERE appointment_id = ?'
        );
        $delete->execute([$appointmentId]);

        if ($delete->rowCount() === 0) {
            respond(404, ['error' => 'Appointment not found.']);
        }

        respond(200, ['message' => 'Appointment deleted.']);
    }

    $patientId = filter_var(
        $payload['patient_id'] ?? null,
        FILTER_VALIDATE_INT,
        ['options' => ['min_range' => 1]]
    );
    $doctorId = filter_var(
        $payload['doctor_id'] ?? null,
        FILTER_VALIDATE_INT,
        ['options' => ['min_range' => 1]]
    );
    $date = (string) ($payload['appointment_date'] ?? '');
    $timeSlot = trim((string) ($payload['time_slot'] ?? ''));
    $notes = trim((string) ($payload['symptoms_notes'] ?? ''));
    $status = trim((string) ($payload['status'] ?? 'Scheduled'));

    if (
        !$patientId ||
        !$doctorId ||
        !validDate($date) ||
        !in_array($timeSlot, $validTimeSlots, true) ||
        strlen($notes) > 2000 ||
        !in_array($status, $validStatuses, true)
    ) {
        respond(422, ['error' => 'Enter a valid patient, doctor, date, time slot, notes, and status.']);
    }

    $patientCheck = $pdo->prepare(
        'SELECT patient_id FROM patients WHERE patient_id = ?'
    );
    $patientCheck->execute([$patientId]);

    if (!$patientCheck->fetchColumn()) {
        respond(422, ['error' => 'Select a patient registered in the database.']);
    }

    $doctorCheck = $pdo->prepare(
        'SELECT doctor_id FROM doctors WHERE doctor_id = ?'
    );
    $doctorCheck->execute([$doctorId]);

    if (!$doctorCheck->fetchColumn()) {
        respond(422, ['error' => 'Select a doctor registered in the database.']);
    }

    if ($method === 'POST') {
        $insert = $pdo->prepare(
            'INSERT INTO appointments
                (doctor_id, patient_id, appointment_date, time_slot, status, symptoms_notes)
             VALUES
                (:doctor_id, :patient_id, :appointment_date, :time_slot, :status, :symptoms_notes)'
        );
        $insert->execute([
            'doctor_id' => $doctorId,
            'patient_id' => $patientId,
            'appointment_date' => $date,
            'time_slot' => $timeSlot,
            'status' => $status,
            'symptoms_notes' => $notes,
        ]);

        respond(201, [
            'appointment_id' => (int) $pdo->lastInsertId(),
            'message' => 'Appointment added.',
        ]);
    }

    $appointmentId = filter_var(
        $payload['appointment_id'] ?? null,
        FILTER_VALIDATE_INT,
        ['options' => ['min_range' => 1]]
    );
    $editReason = trim((string) ($payload['edit_reason'] ?? ''));

    if (!$appointmentId || $editReason === '' || strlen($editReason) > 1000) {
        respond(422, ['error' => 'A valid appointment ID and reason for the edit are required.']);
    }

    $update = $pdo->prepare(
        'UPDATE appointments
         SET appointment_date = :appointment_date,
             time_slot = :time_slot,
             doctor_id = :doctor_id,
             symptoms_notes = :symptoms_notes,
             status = :status,
             edit_reason = :edit_reason
         WHERE appointment_id = :appointment_id'
    );
    $update->execute([
        'appointment_date' => $date,
        'time_slot' => $timeSlot,
        'doctor_id' => $doctorId,
        'symptoms_notes' => $notes,
        'status' => $status,
        'edit_reason' => $editReason,
        'appointment_id' => $appointmentId,
    ]);

    respond(200, ['message' => 'Appointment updated.']);
} catch (Throwable $exception) {
    error_log('Appointment API error: ' . $exception->getMessage());
    respond(500, ['error' => 'Could not save the appointment. Check the database connection and table.']);
}