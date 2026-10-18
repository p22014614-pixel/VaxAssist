<?php
session_start();
require_once 'db.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email    = trim($_POST['email']);
    $password = $_POST['password'];

    // Look up user in database
    $stmt = $conn->prepare("SELECT id, first_name, password_hash FROM site_users WHERE email = ?");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $stmt->store_result();

    if ($stmt->num_rows > 0) {
        $stmt->bind_result($id, $firstName, $passwordHash);
        $stmt->fetch();

        // Verify hashed password
        if (password_verify($password, $passwordHash)) {
            $_SESSION['user_id'] = $id;
            $_SESSION['first_name'] = $firstName;
            
            // Successful login -> Redirect to home.html
            header("Location: home.html");
            exit;
        } else {
            $error = "Invalid password. Please try again.";
            header("Location: login.html?error=" . urlencode($error));
            exit;
        }
    } else {
        $error = "No user account found with that email address.";
        header("Location: login.html?error=" . urlencode($error));
        exit;
    }
    $stmt->close();
} else {
    // Direct GET access redirects back to login page
    $_SESSION['user_id'] = $id;
    $_SESSION['first_name'] = $firstName;
    header("Location: login.html");
    exit;
}
?>