// this file is to get dashboard data from database
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
$docResult = $docStmt->get_result();
$docRow = $docResult->fetch_assoc();
$doctor_id = $docRow ? $docRow['doctor_id'] : 1;
$docStmt->close();

// 1. Today's Appointments Count
$stmt1 = $conn->prepare("SELECT COUNT(*) as total FROM appointments WHERE doctor_id = ? AND appointment_date = CURRENT_DATE()");
$stmt1->bind_param("i", $doctor_id);
$stmt1->execute();
$todayCount = $stmt1->get_result()->fetch_assoc()['total'];
$stmt1->close();

// 2. Weekly Bookings Count
$stmt2 = $conn->prepare("SELECT COUNT(*) as total FROM appointments WHERE doctor_id = ? AND YEARWEEK(appointment_date, 1) = YEARWEEK(CURRENT_DATE(), 1)");
$stmt2->bind_param("i", $doctor_id);
$stmt2->execute();
$weeklyCount = $stmt2->get_result()->fetch_assoc()['total'];
$stmt2->close();

// 3. Total Active Patients
$stmt3 = $conn->query("SELECT COUNT(*) as total FROM patients");
$patientsCount = $stmt3->fetch_assoc()['total'];

// 4. Unread Messages Count
$stmt4 = $conn->prepare("SELECT COUNT(*) as total FROM messages WHERE receiver_id = ? AND is_read = 0");
$stmt4->bind_param("i", $user_id);
$stmt4->execute();
$messagesCount = $stmt4->get_result()->fetch_assoc()['total'];
$stmt4->close();

echo json_encode([
    "status" => "success",
    "today" => $todayCount,
    "weekly" => $weeklyCount,
    "patients" => $patientsCount,
    "messages" => $messagesCount
]);
?>