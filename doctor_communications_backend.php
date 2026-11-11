<?php
// Loads and sends messages for conversations associated with the signed-in doctor.
require __DIR__ . '/doctor_backend_auth.php';
if ($_SERVER['REQUEST_METHOD']==='GET') {
    // Works out which patient's conversation to open: the one asked for, otherwise the one that needs
    // attention (newest unread message), otherwise the most recent chat, otherwise the first patient.
    $requested=filter_var($_GET['patient_id']??null,FILTER_VALIDATE_INT);
    $selected=null;
    if ($requested) {
        $exists=$conn->prepare('SELECT patient_id FROM patients WHERE patient_id=?'); $exists->bind_param('i',$requested); $exists->execute();
        if ($exists->get_result()->fetch_row()) $selected=$requested;
    } elseif (!isset($_GET['patient_id'])) {
        $pick=$conn->prepare("SELECT m.patient_id FROM messages m JOIN patients p ON p.patient_id=m.patient_id WHERE m.doctor_id=?
            ORDER BY (m.sender_type='patient' AND m.is_read=0) DESC, m.created_at DESC, m.message_id DESC LIMIT 1");
        $pick->bind_param('i',$doctor_id); $pick->execute(); $row=$pick->get_result()->fetch_row();
        if ($row) $selected=(int)$row[0];
        else { $first=$conn->query('SELECT patient_id FROM patients ORDER BY full_name,patient_id LIMIT 1')->fetch_row(); if ($first) $selected=(int)$first[0]; }
    }

    $items=[];
    if ($selected) {
        // Opening a conversation counts as reading the patient's messages in it.
        $conn->begin_transaction();
        $read=$conn->prepare("UPDATE messages SET is_read=1 WHERE doctor_id=? AND patient_id=? AND sender_type='patient' AND is_read=0"); $read->bind_param('ii',$doctor_id,$selected); $read->execute();
        $messages=$conn->prepare('SELECT message_id,sender_type,message_text,created_at FROM messages WHERE doctor_id=? AND patient_id=? ORDER BY created_at,message_id');
        $messages->bind_param('ii',$doctor_id,$selected); $messages->execute(); $rows=$messages->get_result()->fetch_all(MYSQLI_ASSOC); $conn->commit();
        foreach($rows as $row) $items[]=['id'=>(int)$row['message_id'],'type'=>$row['sender_type']==='doctor'?'msg-out':'msg-in','text'=>$row['message_text'],'created_at'=>$row['created_at']];
    }

    // Lists every registered patient so the doctor can search or start any conversation, with unread counts.
    $list=$conn->prepare("SELECT p.patient_id,p.full_name,
            (SELECT COUNT(*) FROM messages m WHERE m.doctor_id=? AND m.patient_id=p.patient_id AND m.sender_type='patient' AND m.is_read=0) AS unread,
            (SELECT MAX(m.created_at) FROM messages m WHERE m.doctor_id=? AND m.patient_id=p.patient_id) AS last_message_at
        FROM patients p ORDER BY p.full_name,p.patient_id");
    $list->bind_param('ii',$doctor_id,$doctor_id); $list->execute();
    $patients=$list->get_result()->fetch_all(MYSQLI_ASSOC);
    foreach($patients as &$person) { $person['unread']=(int)$person['unread']; } unset($person);
    $totalUnread=array_sum(array_column($patients,'unread'));
    echo json_encode(['status'=>'success','patients'=>$patients,'patient'=>$selected,'data'=>$items,'unread_total'=>$totalUnread]); exit;
}

if ($_SERVER['REQUEST_METHOD']==='POST') {
    // Validates the conversation belongs to this doctor and stores the doctor's reply.
    $input=json_decode(file_get_contents('php://input'),true)?:[]; $patient=filter_var($input['patient_id']??null,FILTER_VALIDATE_INT); $message=trim($input['message_text']??'');
    if (!$patient || $message==='' || mb_strlen($message)>4000) { http_response_code(422); echo json_encode(['status'=>'error','message'=>'Choose a patient and enter a message of up to 4,000 characters.']); exit; }
    $check=$conn->prepare('SELECT 1 FROM patients WHERE patient_id=?');
    $check->bind_param('i',$patient); $check->execute();
    if (!$check->get_result()->fetch_row()) { http_response_code(404); echo json_encode(['status'=>'error','message'=>'Patient conversation not found.']); exit; }
    $stmt=$conn->prepare("INSERT INTO messages (doctor_id,patient_id,sender_type,message_text,is_read) VALUES (?,?,'doctor',?,0)"); $stmt->bind_param('iis',$doctor_id,$patient,$message);
    if (!$stmt->execute()) { http_response_code(500); echo json_encode(['status'=>'error','message'=>'Message could not be sent.']); exit; }
    echo json_encode(['status'=>'success']); exit;
}
http_response_code(405); echo json_encode(['status'=>'error','message'=>'Method not allowed.']);
