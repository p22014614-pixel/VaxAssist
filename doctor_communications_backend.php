<?php
// Loads and sends messages for conversations associated with the signed-in doctor.
require __DIR__ . '/doctor_backend_auth.php';
if ($_SERVER['REQUEST_METHOD']==='GET') {
    // Lists the doctor's patients, marks their incoming messages read, and returns the conversation.
    $stmt=$conn->prepare("SELECT p.patient_id,p.full_name FROM patients p WHERE EXISTS(SELECT 1 FROM messages m WHERE m.patient_id=p.patient_id AND m.doctor_id=?) OR EXISTS(SELECT 1 FROM appointments a WHERE a.patient_id=p.patient_id AND a.doctor_id=?) ORDER BY p.full_name");
    $stmt->bind_param('ii',$doctor_id,$doctor_id); $stmt->execute(); $patients=$stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    $selected=filter_var($_GET['patient_id']??($patients[0]['patient_id']??null),FILTER_VALIDATE_INT);
    $allowed=false; foreach($patients as $person) if((int)$person['patient_id']===$selected) $allowed=true;
    if (!$allowed) { echo json_encode(['status'=>'success','patients'=>$patients,'patient'=>null,'data'=>[]]); exit; }
    $conn->begin_transaction();
    $read=$conn->prepare("UPDATE messages SET is_read=1 WHERE doctor_id=? AND patient_id=? AND sender_type='patient' AND is_read=0"); $read->bind_param('ii',$doctor_id,$selected); $read->execute();
    $messages=$conn->prepare('SELECT message_id,sender_type,message_text,created_at FROM messages WHERE doctor_id=? AND patient_id=? ORDER BY created_at,message_id');
    $messages->bind_param('ii',$doctor_id,$selected); $messages->execute(); $rows=$messages->get_result()->fetch_all(MYSQLI_ASSOC); $conn->commit();
    $items=[]; foreach($rows as $row) $items[]=['id'=>(int)$row['message_id'],'type'=>$row['sender_type']==='doctor'?'msg-out':'msg-in','text'=>$row['message_text'],'created_at'=>$row['created_at']];
    echo json_encode(['status'=>'success','patients'=>$patients,'patient'=>$selected,'data'=>$items]); exit;
}

if ($_SERVER['REQUEST_METHOD']==='POST') {
    // Validates the conversation belongs to this doctor and stores the doctor's reply.
    $input=json_decode(file_get_contents('php://input'),true)?:[]; $patient=filter_var($input['patient_id']??null,FILTER_VALIDATE_INT); $message=trim($input['message_text']??'');
    if (!$patient || $message==='' || mb_strlen($message)>4000) { http_response_code(422); echo json_encode(['status'=>'error','message'=>'Choose a patient and enter a message of up to 4,000 characters.']); exit; }
    $check=$conn->prepare('SELECT 1 FROM patients p WHERE p.patient_id=? AND (EXISTS(SELECT 1 FROM messages m WHERE m.patient_id=p.patient_id AND m.doctor_id=?) OR EXISTS(SELECT 1 FROM appointments a WHERE a.patient_id=p.patient_id AND a.doctor_id=?))');
    $check->bind_param('iii',$patient,$doctor_id,$doctor_id); $check->execute();
    if (!$check->get_result()->fetch_row()) { http_response_code(404); echo json_encode(['status'=>'error','message'=>'Patient conversation not found.']); exit; }
    $stmt=$conn->prepare("INSERT INTO messages (doctor_id,patient_id,sender_type,message_text,is_read) VALUES (?,?,'doctor',?,0)"); $stmt->bind_param('iis',$doctor_id,$patient,$message);
    if (!$stmt->execute()) { http_response_code(500); echo json_encode(['status'=>'error','message'=>'Message could not be sent.']); exit; }
    echo json_encode(['status'=>'success']); exit;
}
http_response_code(405); echo json_encode(['status'=>'error','message'=>'Method not allowed.']);
