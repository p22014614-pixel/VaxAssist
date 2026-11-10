<?php
session_start();
require "db.php";

$email = strtolower(trim($_POST["email"] ?? ""));
$password = $_POST["password"] ?? "";

require_once __DIR__ . '/db.php';

$result = $doctorDb->query('SELECT doctors FROM vaxassist_db'); // Doctor database
$result = $patientDb->query('SELECT patients FROM vaxassist_db'); // Patient database
$result = $adminDb->query('SELECT users FROM vaxassist_db'); // Admin database

$stmt = $pdo->prepare(
    "SELECT id, password_hash, role FROM users WHERE email = ?"
);
$stmt->execute([$email]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$user || !password_verify($password, $user["password_hash"])) {
    http_response_code(401);
    exit("Email or password is incorrect. <a href='login.html'>Try again</a>");
}

session_regenerate_id(true);
$_SESSION["user_id"] = $user["id"];

if ($_SESSION['role'] === 'Doctor') {
    header('Location: doctor_dashboard.html');
} elseif ($_SESSION['role'] === 'Patient') {
    header('Location: patient_dashboard.html');
} else {
    header('Location: admin_Dashboard.html');
}
exit;