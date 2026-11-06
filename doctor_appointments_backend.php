<?php
// Handles the authenticated doctor's calendar queries and appointment completion requests.
require __DIR__ . '/doctor_backend_auth.php';
$action = $_GET['action'] ?? 'get_day';
if ($action === 'complete' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    // Completes only a scheduled appointment owned by this doctor that is due today or earlier.
    $data = json_decode(file_get_contents('php://input'), true) ?: [];
    $appointment_id = filter_var($data['appointment_id'] ?? null, FILTER_VALIDATE_INT);
    if (!$appointment_id) { http_response_code(422); echo json_encode(['status'=>'error','message'=>'Choose a valid appointment.']); exit; }
    $stmt = $conn->prepare("UPDATE appointments SET status='Completed' WHERE appointment_id=? AND doctor_id=? AND status='Scheduled' AND appointment_date<=CURRENT_DATE()");
    $stmt->bind_param('ii', $appointment_id, $doctor_id);
    if (!$stmt->execute()) { http_response_code(500); echo json_encode(['status'=>'error','message'=>'Could not complete the appointment.']); exit; }
    if ($stmt->affected_rows !== 1) { http_response_code(409); echo json_encode(['status'=>'error','message'=>'This appointment must belong to your account, still be scheduled, and be today or earlier before it can be completed.']); exit; }
    echo json_encode(['status'=>'success','message'=>'Appointment marked as completed.']); exit;
}

if ($action === 'get_day') {
    // Returns this doctor's scheduled appointments for one validated calendar date.
    $date = $_GET['date'] ?? date('Y-m-d');
    $d = DateTime::createFromFormat('Y-m-d', $date);
    if (!$d || $d->format('Y-m-d') !== $date) { http_response_code(422); echo json_encode(['status'=>'error','message'=>'Choose a valid date.']); exit; }
    $stmt = $conn->prepare("SELECT a.appointment_id, a.time_slot, a.appointment_time, a.symptoms_notes, p.full_name, p.patient_id, c.first_name AS child_name FROM appointments a JOIN patients p ON p.patient_id=a.patient_id LEFT JOIN children c ON c.child_id=a.child_id AND c.patient_id=a.patient_id WHERE a.doctor_id=? AND a.appointment_date=? AND a.status='Scheduled' ORDER BY a.appointment_time, a.appointment_id");
    $stmt->bind_param('is', $doctor_id, $date); $stmt->execute(); $res = $stmt->get_result(); $items = [];
    while ($row = $res->fetch_assoc()) {
        $time = $row['appointment_time'] ? substr((string) $row['appointment_time'], 0, 5) : '';
        if ($time !== '') {
            $key = substr($time, 0, 2) . ':00';
        } else {
            $slotStart = DateTime::createFromFormat('h:i A', substr((string) $row['time_slot'], 0, 8));
            $key = $slotStart ? $slotStart->format('H:00') : 'other';
            $time = $slotStart ? $slotStart->format('H:i') : '';
        }
        $items[$key][] = ['appointment_id'=>(int)$row['appointment_id'], 'name'=>$row['full_name'], 'child_name'=>$row['child_name'], 'reason'=>$row['symptoms_notes'], 'patient_id'=>(int)$row['patient_id'], 'appointment_time'=>$time];
    }
    echo json_encode(['status'=>'success','data'=>$items]); exit;
}

if ($action === 'get_month') {
    // Returns scheduled appointment counts by day for the selected month.
    $year = filter_var($_GET['year'] ?? date('Y'), FILTER_VALIDATE_INT);
    $month = filter_var($_GET['month'] ?? date('n'), FILTER_VALIDATE_INT);
    if (!$year || $year < 2000 || $year > 2100 || !$month || $month < 1 || $month > 12) { http_response_code(422); echo json_encode(['status'=>'error','message'=>'Choose a valid month.']); exit; }
    $stmt = $conn->prepare("SELECT DAY(appointment_date) day_num, COUNT(*) booking_count FROM appointments WHERE doctor_id=? AND YEAR(appointment_date)=? AND MONTH(appointment_date)=? AND status='Scheduled' GROUP BY appointment_date");
    $stmt->bind_param('iii', $doctor_id, $year, $month); $stmt->execute(); $res=$stmt->get_result(); $counts=[];
    while ($row=$res->fetch_assoc()) $counts[$row['day_num']] = (int)$row['booking_count'];
    echo json_encode(['status'=>'success','data'=>$counts]); exit;
}
http_response_code(400); echo json_encode(['status'=>'error','message'=>'Invalid action.']);
