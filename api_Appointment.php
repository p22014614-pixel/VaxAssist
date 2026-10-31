<?php
declare(strict_types=1);

session_start();
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

function respond(int $status, array $data): void
{
    http_response_code($status);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
    exit;
}

if (empty($_SESSION['user_id'])) {
    respond(401, ['error' => 'Please sign in to manage appointments.']);
}

require __DIR__ . '/db.php';

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

if (!in_array($method, ['GET', 'PUT', 'DELETE'], true)) {
    header('Allow: GET, PUT, DELETE');
    respond(405, ['error' => 'Method not allowed.']);
}

if ($method === 'GET') {
    if (empty($_SESSION['appointment_csrf'])) {
        $_SESSION['appointment_csrf'] = bin2hex(random_bytes(32));
    }

    try {
        $appointments = $pdo->query(
            'SELECT a.appointment_id, a.doctor_id, a.patient_id, a.appointment_date,
                    a.time_slot, a.status, a.symptoms_notes, a.edit_reason, a.created_at,
                    TRIM(CONCAT(d.first_name, " ", d.last_name)) AS doctor_name
             FROM appointments AS a
             INNER JOIN doctors AS d ON d.doctor_id = a.doctor_id
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
        respond(500, [
            'error' => 'Could not load appointments. Check the database connection and tables.',
        ]);
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

$appointmentId = filter_var(
    $payload['appointment_id'] ?? null,
    FILTER_VALIDATE_INT,
    ['options' => ['min_range' => 1]]
);

if (!$appointmentId) {
    respond(422, ['error' => 'A valid appointment ID is required.']);
}

try {
    if ($method === 'DELETE') {
        $delete = $pdo->prepare(
            'DELETE FROM appointments WHERE appointment_id = ?'
        );
        $delete->execute([$appointmentId]);

        if ($delete->rowCount() === 0) {
            respond(404, ['error' => 'Appointment not found.']);
        }

        respond(200, ['message' => 'Appointment deleted.']);
    }

    $date = (string) ($payload['appointment_date'] ?? '');
    $dateValue = DateTimeImmutable::createFromFormat('!Y-m-d', $date);
    $dateErrors = DateTimeImmutable::getLastErrors();

    if (
        !$dateValue ||
        ($dateErrors !== false &&
            ($dateErrors['warning_count'] > 0 || $dateErrors['error_count'] > 0)) ||
        $dateValue->format('Y-m-d') !== $date
    ) {
        respond(422, ['error' => 'Enter a valid appointment date.']);
    }

    $timeSlot = trim((string) ($payload['time_slot'] ?? ''));
    $notes = trim((string) ($payload['symptoms_notes'] ?? ''));
    $editReason = trim((string) ($payload['edit_reason'] ?? ''));
    $status = trim((string) ($payload['status'] ?? ''));
    $doctorId = filter_var(
        $payload['doctor_id'] ?? null,
        FILTER_VALIDATE_INT,
        ['options' => ['min_range' => 1]]
    );

    $validTimeSlots = ['08:00 AM - 10:00 AM', '10:00 AM - 12:00 PM', '01:00 PM - 03:00 PM', '03:00 PM - 05:00 PM'];

    if (!in_array($timeSlot, $validTimeSlots, true) || strlen($notes) > 2000 || strlen($editReason) > 1000 || !$editReason || !$doctorId) {
            http_response_code(422);
            echo json_encode(['error' => 'Enter a valid time, notes, reason for edit, and registered doctor.']);
            exit;
    }

    if (!in_array($status, ['Scheduled', 'Pending', 'Completed', 'Cancelled'], true)) {
        respond(422, ['error' => 'Choose a valid appointment status.']);
    }

    $doctorCheck = $pdo->prepare(
        'SELECT doctor_id FROM doctors WHERE doctor_id = ?'
    );
    $doctorCheck->execute([$doctorId]);

    if (!$doctorCheck->fetchColumn()) {
        respond(422, ['error' => 'Select a doctor registered in the database.']);
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
    respond(500, [
        'error' => 'Could not save the appointment. Check the database connection and table.',
    ]);
}