<?php
session_start();
require "db.php";

$email = strtolower(trim($_POST["email"] ?? ""));
$password = $_POST["password"] ?? "";

$stmt = $pdo->prepare(
    "SELECT id, password_hash FROM users WHERE email = ?"
);
$stmt->execute([$email]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$user || !password_verify($password, $user["password_hash"])) {
    http_response_code(401);
    exit("Email or password is incorrect. <a href='adminLogin.html'>Try again</a>");
}

session_regenerate_id(true);
$_SESSION["user_id"] = $user["id"];

header("Location: adminDashboard.html");
exit;