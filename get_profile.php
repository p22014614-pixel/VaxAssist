//This file is to get login data and use it in doctor_profile
<?php
session_start();
require_once 'db.php';

header('Content-Type: application/json');

// Check if user is logged in
if (!isset($_SESSION['user_id'])) {
    echo json_encode(["status" => "error", "message" => "Unauthorized access"]);
    exit;
}

$user_id = $_SESSION['user_id'];

// Query user credentials from site_users table
$stmt = $conn->prepare("SELECT first_name, last_name, email FROM site_users WHERE id = ?");
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

if ($row = $result->fetch_assoc()) {
    $fullName = "Dr. " . $row['first_name'] . " " . $row['last_name'];
    $email = $row['email'];

    echo json_encode([
        "status" => "success",
        "fullName" => $fullName,
        "email" => $email
    ]);
} else {
    echo json_encode(["status" => "error", "message" => "User not found"]);
}

$stmt->close();
?>