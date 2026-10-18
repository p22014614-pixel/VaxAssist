//This file is to get Patient Record data form database
<?php
session_start();
require_once 'db.php';
header('Content-Type: application/json');

if (!isset($_SESSION['user_id'])) {
    echo json_encode(["status" => "error", "message" => "Unauthorized"]);
    exit;
}

$user_id = $_SESSION['user_id'];

// Get doctor_id
$docStmt = $conn->prepare("SELECT doctor_id FROM doctors WHERE user_id = ?");
$docStmt->bind_param("i", $user_id);
$docStmt->execute();
$doctor_id = $docStmt->get_result()->fetch_assoc()['doctor_id'] ?? 1;
$docStmt->close();

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $query = "%" . ($_GET['query'] ?? '') . "%";
    
    $sql = "SELECT p.patient_id, u.first_name, u.last_name, u.dob, p.gender, p.blood_type, p.allergies 
            FROM patients p 
            JOIN site_users u ON p.user_id = u.id 
            WHERE u.first_name LIKE ? OR u.last_name LIKE ? OR p.ic_passport LIKE ? LIMIT 1";
            
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sss", $query, $query, $query);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($patient = $result->fetch_assoc()) {
        $dob = new DateTime($patient['dob']);
        $now = new DateTime();
        $age = $now->diff($dob)->y;
        
        echo json_encode([
            "status" => "success",
            "patient" => [
                "patient_id" => $patient['patient_id'],
                "name" => $patient['first_name'] . " " . $patient['last_name'],
                "age" => $age,
                "gender" => $patient['gender'],
                "blood_type" => $patient['blood_type'],
                "allergies" => $patient['allergies']
            ]
        ]);
    } else {
        echo json_encode(["status" => "error", "message" => "No patient found"]);
    }
    $stmt->close();
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $patient_id = intval($data['patient_id'] ?? 1);
    $subjective = $data['subjective'] ?? '';
    $objective = $data['objective'] ?? '';
    $assessment = $data['assessment'] ?? '';
    $plan = $data['plan'] ?? '';
    
    $stmt = $conn->prepare("INSERT INTO consultation_records (patient_id, doctor_id, subjective_notes, objective_notes, assessment, plan) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("iissss", $patient_id, $doctor_id, $subjective, $objective, $assessment, $plan);
    
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Record Saved Successfully!"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Failed to save record"]);
    }
    $stmt->close();
}
?>