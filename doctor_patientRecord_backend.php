<?php
// Searches patients connected to the doctor and stores that doctor's consultation notes.
require __DIR__ . '/doctor_backend_auth.php';
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Finds patients connected by an appointment, conversation, or doctor-created walk-in link.
    $q = trim($_GET['query'] ?? '');
    if ($q === '') { http_response_code(422); echo json_encode(['status'=>'error','message'=>'Enter a patient name or IC/passport number.']); exit; }
    $like = '%' . $q . '%';
    $stmt = $conn->prepare("SELECT p.patient_id,p.full_name,p.dob,p.gender,p.blood_type,p.allergies FROM patients p WHERE (p.full_name LIKE ? OR p.ic_passport LIKE ?) AND (EXISTS (SELECT 1 FROM appointments a WHERE a.patient_id=p.patient_id AND a.doctor_id=?) OR EXISTS (SELECT 1 FROM messages m WHERE m.patient_id=p.patient_id AND m.doctor_id=?) OR EXISTS (SELECT 1 FROM doctor_patient_links l WHERE l.patient_id=p.patient_id AND l.doctor_id=?)) AND (? = 0 OR p.patient_id = ?) ORDER BY p.full_name LIMIT 20");
    $exactId = (int) filter_var($_GET['patient_id'] ?? 0, FILTER_VALIDATE_INT); $stmt->bind_param('ssiiiii', $like, $like, $doctor_id, $doctor_id, $doctor_id, $exactId, $exactId); $stmt->execute(); $rows=$stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    if (!$rows) { echo json_encode(['status'=>'error','message'=>'No patient found in your care matching that search.']); exit; }
    $results=[];
    foreach ($rows as $row) {
        $age = null;
        if (!empty($row['dob'])) $age = (new DateTime())->diff(new DateTime($row['dob']))->y;
        $results[]=['patient_id'=>(int)$row['patient_id'],'name'=>$row['full_name'],'age'=>$age,'gender'=>$row['gender'],'blood_type'=>$row['blood_type'],'allergies'=>$row['allergies']];
    }
    echo json_encode(['status'=>'success','patient'=>$results[0],'patients'=>$results]); exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data=json_decode(file_get_contents('php://input'),true) ?: [];
    if (($_GET['action'] ?? '') === 'create_walkin') {
        // Validates and stores a first-time walk-in patient, linked to this doctor.
        $fullName = trim((string) ($data['full_name'] ?? ''));
        $icPassport = trim((string) ($data['ic_passport'] ?? ''));
        $phoneInput = trim((string) ($data['phone'] ?? ''));
        $dobInput = trim((string) ($data['dob'] ?? ''));
        $gender = (string) ($data['gender'] ?? '');
        $bloodTypeInput = trim((string) ($data['blood_type'] ?? ''));
        $allergiesInput = trim((string) ($data['allergies'] ?? ''));
        $date = $dobInput === '' ? null : DateTime::createFromFormat('Y-m-d', $dobInput);
        if ($fullName === '' || mb_strlen($fullName) > 100 || $icPassport === '' || mb_strlen($icPassport) > 50
            || ($phoneInput !== '' && mb_strlen($phoneInput) > 20)
            || ($dobInput !== '' && (!$date || $date->format('Y-m-d') !== $dobInput || $dobInput > date('Y-m-d')))
            || !in_array($gender, ['Male', 'Female', 'Other'], true)
            || ($bloodTypeInput !== '' && mb_strlen($bloodTypeInput) > 5) || mb_strlen($allergiesInput) > 5000) {
            http_response_code(422); echo json_encode(['status'=>'error','message'=>'Check the patient name, IC/passport, date of birth, gender, blood type, phone, and allergies.']); exit;
        }
        $phone = $phoneInput === '' ? null : $phoneInput;
        $dob = $dobInput === '' ? null : $dobInput;
        $bloodType = $bloodTypeInput === '' ? null : $bloodTypeInput;
        $allergies = $allergiesInput === '' ? null : $allergiesInput;
        $duplicate = $conn->prepare('SELECT patient_id FROM patients WHERE ic_passport = ? LIMIT 1');
        $duplicate->bind_param('s', $icPassport); $duplicate->execute();
        if ($duplicate->get_result()->fetch_row()) { http_response_code(409); echo json_encode(['status'=>'error','message'=>'A patient with this IC/passport number already exists. Search for the patient instead.']); exit; }
        try {
            $lockResult = $conn->query("SELECT GET_LOCK('vaxassist_walkin_patient_id', 5) AS acquired")->fetch_assoc();
            if ((int) ($lockResult['acquired'] ?? 0) !== 1) throw new RuntimeException('Patient intake is busy. Please try again.');
            $conn->begin_transaction();
            // Uses an explicit ID because the live shared patient table may not have AUTO_INCREMENT applied yet.
            $nextId = (int) $conn->query('SELECT COALESCE(MAX(patient_id), 0) + 1 AS next_id FROM patients')->fetch_assoc()['next_id'];
            $insert = $conn->prepare('INSERT INTO patients (patient_id, full_name, ic_passport, phone, dob, gender, blood_type, allergies) VALUES (?, ?, ?, ?, ?, ?, ?, ?)');
            $insert->bind_param('isssssss', $nextId, $fullName, $icPassport, $phone, $dob, $gender, $bloodType, $allergies);
            $insert->execute();
            $patientId = $nextId;
            $link = $conn->prepare('INSERT INTO doctor_patient_links (doctor_id, patient_id) VALUES (?, ?)');
            $link->bind_param('ii', $doctor_id, $patientId); $link->execute();
            $conn->commit();
            $conn->query("SELECT RELEASE_LOCK('vaxassist_walkin_patient_id')");
            echo json_encode(['status'=>'success','message'=>'Walk-in patient added to your patient records.','patient'=>['patient_id'=>$patientId,'name'=>$fullName]]); exit;
        } catch (Throwable $error) {
            $conn->rollback(); error_log('Walk-in patient creation failed: ' . $error->getMessage());
            $conn->query("SELECT RELEASE_LOCK('vaxassist_walkin_patient_id')");
            http_response_code(500); echo json_encode(['status'=>'error','message'=>'Could not save the walk-in patient. Check that the doctor_patient_links table migration is installed.']); exit;
        }
    }
    // Validates doctor access to the patient, then saves the consultation record.
    $patient_id=filter_var($data['patient_id']??null,FILTER_VALIDATE_INT);
    $notes=array_map(static fn($key)=>trim((string)($data[$key]??'')),['subjective','objective','assessment','plan']);
    if (!$patient_id || implode('', $notes)==='') { http_response_code(422); echo json_encode(['status'=>'error','message'=>'Select a patient and enter at least one clinical note.']); exit; }
    $check=$conn->prepare('SELECT 1 FROM patients p WHERE p.patient_id=? AND (EXISTS(SELECT 1 FROM appointments a WHERE a.patient_id=p.patient_id AND a.doctor_id=?) OR EXISTS(SELECT 1 FROM messages m WHERE m.patient_id=p.patient_id AND m.doctor_id=?) OR EXISTS(SELECT 1 FROM doctor_patient_links l WHERE l.patient_id=p.patient_id AND l.doctor_id=?))');
    $check->bind_param('iiii',$patient_id,$doctor_id,$doctor_id,$doctor_id); $check->execute();
    if (!$check->get_result()->fetch_row()) { http_response_code(404); echo json_encode(['status'=>'error','message'=>'Patient record not found in your care.']); exit; }
    $save=$conn->prepare('INSERT INTO consultation_records (patient_id,doctor_id,subjective_notes,objective_notes,assessment,plan) VALUES (?,?,?,?,?,?)');
    $save->bind_param('iissss',$patient_id,$doctor_id,$notes[0],$notes[1],$notes[2],$notes[3]);
    if (!$save->execute()) { http_response_code(500); echo json_encode(['status'=>'error','message'=>'Could not save the medical record.']); exit; }
    echo json_encode(['status'=>'success','message'=>'Medical record saved.']); exit;
}
http_response_code(405); echo json_encode(['status'=>'error','message'=>'Method not allowed.']);
