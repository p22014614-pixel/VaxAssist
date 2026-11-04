<?php
// Opens the MySQLi database connection used by the doctor portal backends.
// Shared MySQL connection for the legacy doctor endpoints.
$host = "localhost";
$user = "root";
$password = ""; // Default XAMPP password is empty
$database = "vaxassist_db";

$conn = new mysqli($host, $user, $password, $database);

if ($conn->connect_error) {
    die("Database Connection Failed: " . $conn->connect_error);
}
?>
