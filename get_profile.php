<?php
session_start();
require_once 'db.php';

header('Content-Type: application/json');

if (!isset($_SESSION['doctor_id'])) {
    echo json_encode(["status" => "error", "message" => "Unauthorized access"]);
    exit;
}

$doctor_id = $_SESSION['doctor_id'];

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
    echo json_encode(["status" => "error", "message" => "Doctor account not found"]);
}
$stmt->close();
?>