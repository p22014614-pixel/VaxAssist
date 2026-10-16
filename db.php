<?php
$host = "localhost";
$user = "root";
$password = ""; // Default XAMPP password is empty
$database = "vaxassist_db";

$conn = new mysqli($host, $user, $password, $database);

if ($conn->connect_error) {
    die("Database Connection Failed: " . $conn->connect_error);
}
?>