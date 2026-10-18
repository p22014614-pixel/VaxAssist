<?php
session_start();
require_once 'db.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email    = trim($_POST['email']);
    $password = $_POST['password'];

    // Check directly in doctors table
    $stmt = $conn->prepare("SELECT doctor_id, first_name, password_hash FROM doctors WHERE email = ?");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $stmt->store_result();

    if ($stmt->num_rows > 0) {
        $stmt->bind_result($doctor_id, $firstName, $passwordHash);
        $stmt->fetch();

        if (password_verify($password, $passwordHash)) {
            $_SESSION['doctor_id'] = $doctor_id;
            $_SESSION['first_name'] = $firstName;
            
            header("Location: home.html");
            exit;
        } else {
            $error = "Invalid password. Please try again.";
            header("Location: login.html?error=" . urlencode($error));
            exit;
        }
    } else {
        $error = "No doctor account found with that email address.";
        header("Location: login.html?error=" . urlencode($error));
        exit;
    }
    $stmt->close();
}
?>