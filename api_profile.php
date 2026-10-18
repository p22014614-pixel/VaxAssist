//This file is to get doctor profile data form database
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

$data = json_decode(file_get_contents('php://input'), true);
$action = $data['action'] ?? '';

if ($action === 'update_profile') {
    $specialization = $data['specialization'] ?? '';
    $room = $data['room'] ?? '';
    
    $stmt = $conn->prepare("UPDATE doctors SET specialization = ?, consultation_room = ? WHERE doctor_id = ?");
    $stmt->bind_param("ssi", $specialization, $room, $doctor_id);
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Profile Updated!"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Failed to update profile"]);
    }
    $stmt->close();
} elseif ($action === 'submit_leave') {
    $start_date = $data['start_date'] ?? '';
    $end_date = $data['end_date'] ?? '';
    $reason = $data['reason'] ?? '';
    
    $stmt = $conn->prepare("INSERT INTO leave_requests (doctor_id, start_date, end_date, reason) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("isss", $doctor_id, $start_date, $end_date, $reason);
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Leave Request Submitted to Admin!"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Failed to submit leave request"]);
    }
    $stmt->close();
}
?>