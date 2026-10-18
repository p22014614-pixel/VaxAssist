<?php
require_once 'db.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $firstName = trim($_POST['firstName']);
    $lastName  = trim($_POST['lastName']);
    $email     = trim($_POST['email']);
    $phone     = trim($_POST['phone']);
    $dob       = $_POST['dob'];
    $password  = $_POST['password'];

    // Check if email already exists
    $checkStmt = $conn->prepare("SELECT id FROM site_users WHERE email = ?");
    $checkStmt->bind_param("s", $email);
    $checkStmt->execute();
    $checkStmt->store_result();

    if ($checkStmt->num_rows > 0) {
        $error = "An account with this email address already exists.";
        header("Location: register.html?error=" . urlencode($error));
        exit;
    } else {
        // Securely hash the password
        $hashedPassword = password_hash($password, PASSWORD_DEFAULT);

        // Insert new user into database
        $stmt = $conn->prepare("INSERT INTO site_users (first_name, last_name, email, phone, dob, password_hash) VALUES (?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("ssssss", $firstName, $lastName, $email, $phone, $dob, $hashedPassword);

        if ($stmt->execute()) {
            $message = "Account created successfully! Redirecting to login...";
            header("Location: register.html?message=" . urlencode($message));
            exit;
        } else {
            $error = "Registration failed. Please try again later.";
            header("Location: register.html?error=" . urlencode($error));
            exit;
        }
        $stmt->close();
    }
    $checkStmt->close();
} else {
    // Direct GET access redirects back to register page
    header("Location: register.html");
    exit;
}
?>