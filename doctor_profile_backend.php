<?php
session_start();
require_once 'db.php';

header('Content-Type: application/json');

// Check authentication
if (!isset($_SESSION['user_id']) && !isset($_SESSION['doctor_id'])) {
    echo json_encode(["status" => "error", "message" => "Unauthorized access"]);
    exit;
}

// Retrieve doctor_id directly from session or via user_id lookup
if (isset($_SESSION['doctor_id'])) {
    $doctor_id = $_SESSION['doctor_id'];
} else {
    $user_id = $_SESSION['user_id'];
    $docStmt = $conn->prepare("SELECT doctor_id FROM doctors WHERE user_id = ?");
    $docStmt->bind_param("i", $user_id);
    $docStmt->execute();
    $result = $docStmt->get_result()->fetch_assoc();
    $doctor_id = $result['doctor_id'] ?? null;
    $docStmt->close();

    if (!$doctor_id) {
        echo json_encode(["status" => "error", "message" => "Doctor account not found"]);
        exit;
    }
}

// Parse incoming request body
$input = json_decode(file_get_contents('php://input'), true);
$action = $_GET['action'] ?? $input['action'] ?? 'get_profile';

switch ($action) {
    case 'get_profile':
        $stmt = $conn->prepare("SELECT first_name, last_name, email, specialization, consultation_room FROM doctors WHERE doctor_id = ?");
        $stmt->bind_param("i", $doctor_id);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($row = $result->fetch_assoc()) {
            echo json_encode([
                "status" => "success",
                "fullName" => "Dr. " . $row['first_name'] . " " . $row['last_name'],
                "email" => $row['email'],
                "specialization" => $row['specialization'],
                "consultationRoom" => $row['consultation_room']
            ]);
        } else {
            echo json_encode(["status" => "error", "message" => "Doctor record not found"]);
        }
        $stmt->close();
        break;

    case 'update_profile':
        $specialization = $input['specialization'] ?? '';
        $room = $input['room'] ?? '';

        $stmt = $conn->prepare("UPDATE doctors SET specialization = ?, consultation_room = ? WHERE doctor_id = ?");
        $stmt->bind_param("ssi", $specialization, $room, $doctor_id);

        if ($stmt->execute()) {
            echo json_encode(["status" => "success", "message" => "Profile Updated!"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to update profile"]);
        }
        $stmt->close();
        break;

    case 'submit_leave':
        $start_date = $input['start_date'] ?? '';
        $end_date = $input['end_date'] ?? '';
        $reason = $input['reason'] ?? '';

        $stmt = $conn->prepare("INSERT INTO leave_requests (doctor_id, start_date, end_date, reason) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("isss", $doctor_id, $start_date, $end_date, $reason);

        if ($stmt->execute()) {
            echo json_encode(["status" => "success", "message" => "Leave Request Submitted to Admin!"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to submit leave request"]);
        }
        $stmt->close();
        break;

    default:
        echo json_encode(["status" => "error", "message" => "Invalid action specified"]);
        break;
}
?>