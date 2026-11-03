<?php
// Returns the signed-in doctor's month view from configured availability, leave, and bookings.
require __DIR__ . '/doctor_backend_auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Method not allowed.']);
    exit;
}

$year = filter_var($_GET['year'] ?? date('Y'), FILTER_VALIDATE_INT);
$month = filter_var($_GET['month'] ?? date('n'), FILTER_VALIDATE_INT);
if (!$year || $year < 2000 || $year > 2100 || !$month || $month < 1 || $month > 12) {
    http_response_code(422);
    echo json_encode(['status' => 'error', 'message' => 'Choose a valid month.']);
    exit;
}

$firstDay = sprintf('%04d-%02d-01', $year, $month);
$nextMonth = (new DateTimeImmutable($firstDay))->modify('first day of next month')->format('Y-m-d');

$availabilityQuery = $conn->prepare('SELECT weekday FROM doctor_availability WHERE doctor_id = ? ORDER BY weekday');
$availabilityQuery->bind_param('i', $doctor_id);
$availabilityQuery->execute();
$availability = array_map('intval', array_column($availabilityQuery->get_result()->fetch_all(MYSQLI_ASSOC), 'weekday'));

$appointmentQuery = $conn->prepare("SELECT a.appointment_id, a.appointment_date, a.appointment_time, a.time_slot, a.status,
        p.full_name, v.name AS vaccine_name
    FROM appointments a
    JOIN patients p ON p.patient_id = a.patient_id
    LEFT JOIN vaccines v ON v.vaccine_id = a.vaccine_id
    WHERE a.doctor_id = ? AND a.appointment_date >= ? AND a.appointment_date < ?
      AND a.status IN ('Scheduled', 'Completed', 'Cancelled')
    ORDER BY a.appointment_date, a.appointment_time, a.time_slot, a.appointment_id");
$appointmentQuery->bind_param('iss', $doctor_id, $firstDay, $nextMonth);
$appointmentQuery->execute();
$appointments = $appointmentQuery->get_result()->fetch_all(MYSQLI_ASSOC);

$leaveQuery = $conn->prepare("SELECT leave_id, start_date, end_date, reason FROM leave_requests
    WHERE doctor_id = ? AND status = 'Approved' AND start_date < ? AND end_date >= ?
    ORDER BY start_date");
$leaveQuery->bind_param('iss', $doctor_id, $nextMonth, $firstDay);
$leaveQuery->execute();
$leaves = $leaveQuery->get_result()->fetch_all(MYSQLI_ASSOC);

echo json_encode([
    'status' => 'success',
    'year' => (int) $year,
    'month' => (int) $month,
    'availability_weekdays' => $availability,
    'appointments' => $appointments,
    'approved_leave' => $leaves,
], JSON_UNESCAPED_UNICODE);
