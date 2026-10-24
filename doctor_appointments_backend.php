<?php
require __DIR__ . '/doctor_backend_auth.php';
$action = $_GET['action'] ?? 'get_day';
if ($action === 'get_day') {
    $date = $_GET['date'] ?? date('Y-m-d');
    $d = DateTime::createFromFormat('Y-m-d', $date);
    if (!$d || $d->format('Y-m-d') !== $date) { http_response_code(422); echo json_encode(['status'=>'error','message'=>'Choose a valid date.']); exit; }
    $stmt = $conn->prepare("SELECT a.time_slot, a.appointment_time, a.symptoms_notes, p.full_name, p.patient_id FROM appointments a JOIN patients p ON p.patient_id=a.patient_id WHERE a.doctor_id=? AND a.appointment_date=? AND a.status='Scheduled' ORDER BY a.appointment_time, a.appointment_id");
    $stmt->bind_param('is', $doctor_id, $date); $stmt->execute(); $res = $stmt->get_result(); $items = [];
    while ($row = $res->fetch_assoc()) {
        $key = $row['time_slot'];
        $items[$key][] = ['name'=>$row['full_name'], 'reason'=>$row['symptoms_notes'], 'patient_id'=>(int)$row['patient_id']];
    }
    echo json_encode(['status'=>'success','data'=>$items]); exit;
}
if ($action === 'get_month') {
    $year = filter_var($_GET['year'] ?? date('Y'), FILTER_VALIDATE_INT);
    $month = filter_var($_GET['month'] ?? date('n'), FILTER_VALIDATE_INT);
    if (!$year || $year < 2000 || $year > 2100 || !$month || $month < 1 || $month > 12) { http_response_code(422); echo json_encode(['status'=>'error','message'=>'Choose a valid month.']); exit; }
    $stmt = $conn->prepare("SELECT DAY(appointment_date) day_num, COUNT(*) booking_count FROM appointments WHERE doctor_id=? AND YEAR(appointment_date)=? AND MONTH(appointment_date)=? AND status='Scheduled' GROUP BY appointment_date");
    $stmt->bind_param('iii', $doctor_id, $year, $month); $stmt->execute(); $res=$stmt->get_result(); $counts=[];
    while ($row=$res->fetch_assoc()) $counts[$row['day_num']] = (int)$row['booking_count'];
    echo json_encode(['status'=>'success','data'=>$counts]); exit;
}
http_response_code(400); echo json_encode(['status'=>'error','message'=>'Invalid action.']);
