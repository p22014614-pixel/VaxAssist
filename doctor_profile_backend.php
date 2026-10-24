<?php
require __DIR__ . '/doctor_backend_auth.php';
$input=json_decode(file_get_contents('php://input'),true) ?: [];
$action=$_GET['action'] ?? $input['action'] ?? 'get_profile';
if ($action === 'get_profile' && $_SERVER['REQUEST_METHOD']==='GET') {
    $stmt=$conn->prepare('SELECT first_name,last_name,email,specialization,consultation_room FROM doctors WHERE doctor_id=?');
    $stmt->bind_param('i',$doctor_id); $stmt->execute(); $row=$stmt->get_result()->fetch_assoc();
    if (!$row) { http_response_code(404); echo json_encode(['status'=>'error','message'=>'Doctor profile not found.']); exit; }
    echo json_encode(['status'=>'success','fullName'=>'Dr. '.$row['first_name'].' '.$row['last_name'],'email'=>$row['email'],'specialization'=>$row['specialization'],'consultationRoom'=>$row['consultation_room']]); exit;
}
if ($action === 'update_profile' && $_SERVER['REQUEST_METHOD']==='POST') {
    $specialization=trim($input['specialization']??''); $room=trim($input['room']??'');
    if ($specialization==='' || mb_strlen($specialization)>150 || $room==='' || mb_strlen($room)>20) { http_response_code(422); echo json_encode(['status'=>'error','message'=>'Enter a specialization (up to 150 characters) and room (up to 20 characters).']); exit; }
    $stmt=$conn->prepare('UPDATE doctors SET specialization=?, consultation_room=? WHERE doctor_id=?'); $stmt->bind_param('ssi',$specialization,$room,$doctor_id);
    echo json_encode($stmt->execute()?['status'=>'success','message'=>'Profile updated.']:['status'=>'error','message'=>'Could not update profile.']); exit;
}
if ($action === 'submit_leave' && $_SERVER['REQUEST_METHOD']==='POST') {
    $start=$input['start_date']??''; $end=$input['end_date']??''; $reason=trim($input['reason']??'');
    $startDate=DateTime::createFromFormat('Y-m-d',$start); $endDate=DateTime::createFromFormat('Y-m-d',$end);
    if (!$startDate || !$endDate || $startDate->format('Y-m-d')!==$start || $endDate->format('Y-m-d')!==$end || $start<date('Y-m-d') || $end<$start || $reason==='' || mb_strlen($reason)>1000) { http_response_code(422); echo json_encode(['status'=>'error','message'=>'Enter future or current leave dates and a reason (up to 1,000 characters).']); exit; }
    $stmt=$conn->prepare('INSERT INTO leave_requests (doctor_id,start_date,end_date,reason) VALUES (?,?,?,?)'); $stmt->bind_param('isss',$doctor_id,$start,$end,$reason);
    echo json_encode($stmt->execute()?['status'=>'success','message'=>'Leave request sent for approval.']:['status'=>'error','message'=>'Could not submit leave request.']); exit;
}
http_response_code(405); echo json_encode(['status'=>'error','message'=>'Unsupported action.']);
