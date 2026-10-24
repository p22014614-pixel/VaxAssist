<?php
require __DIR__ . '/doctor_backend_auth.php';
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $q = trim($_GET['query'] ?? '');
    if ($q === '') { http_response_code(422); echo json_encode(['status'=>'error','message'=>'Enter a patient name or IC/passport number.']); exit; }
    $like = '%' . $q . '%';
    $stmt = $conn->prepare("SELECT p.patient_id,p.full_name,p.dob,p.gender,p.blood_type,p.allergies FROM patients p WHERE (p.full_name LIKE ? OR p.ic_passport LIKE ?) AND (EXISTS (SELECT 1 FROM appointments a WHERE a.patient_id=p.patient_id AND a.doctor_id=?) OR EXISTS (SELECT 1 FROM messages m WHERE m.patient_id=p.patient_id AND m.doctor_id=?)) ORDER BY p.full_name LIMIT 20");
    $stmt->bind_param('ssii', $like, $like, $doctor_id, $doctor_id); $stmt->execute(); $rows=$stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    if (!$rows) { echo json_encode(['status'=>'error','message'=>'No patient found in your care matching that search.']); exit; }
    $results=[];
    foreach ($rows as $row) {
        $dob = new DateTime($row['dob']);
        $results[]=['patient_id'=>(int)$row['patient_id'],'name'=>$row['full_name'],'age'=>(new DateTime())->diff($dob)->y,'gender'=>$row['gender'],'blood_type'=>$row['blood_type'],'allergies'=>$row['allergies']];
    }
    echo json_encode(['status'=>'success','patient'=>$results[0],'patients'=>$results]); exit;
}
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data=json_decode(file_get_contents('php://input'),true) ?: [];
    $patient_id=filter_var($data['patient_id']??null,FILTER_VALIDATE_INT);
    $notes=array_map(static fn($key)=>trim((string)($data[$key]??'')),['subjective','objective','assessment','plan']);
    if (!$patient_id || implode('', $notes)==='') { http_response_code(422); echo json_encode(['status'=>'error','message'=>'Select a patient and enter at least one clinical note.']); exit; }
    $check=$conn->prepare('SELECT 1 FROM patients p WHERE p.patient_id=? AND (EXISTS(SELECT 1 FROM appointments a WHERE a.patient_id=p.patient_id AND a.doctor_id=?) OR EXISTS(SELECT 1 FROM messages m WHERE m.patient_id=p.patient_id AND m.doctor_id=?))');
    $check->bind_param('iii',$patient_id,$doctor_id,$doctor_id); $check->execute();
    if (!$check->get_result()->fetch_row()) { http_response_code(404); echo json_encode(['status'=>'error','message'=>'Patient record not found in your care.']); exit; }
    $save=$conn->prepare('INSERT INTO consultation_records (patient_id,doctor_id,subjective_notes,objective_notes,assessment,plan) VALUES (?,?,?,?,?,?)');
    $save->bind_param('iissss',$patient_id,$doctor_id,$notes[0],$notes[1],$notes[2],$notes[3]);
    if (!$save->execute()) { http_response_code(500); echo json_encode(['status'=>'error','message'=>'Could not save the medical record.']); exit; }
    echo json_encode(['status'=>'success','message'=>'Medical record saved.']); exit;
}
http_response_code(405); echo json_encode(['status'=>'error','message'=>'Method not allowed.']);
