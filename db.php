<?php
$host = 'localhost';
$user = 'root';
$password = ''; // Default XAMPP password

function connectMysqli(string $host, string $user, string $password, string $database): mysqli
{
    $connection = new mysqli($host, $user, $password, $database);

    if ($connection->connect_error) {
        die("MySQLi connection to '$database' failed: " . $connection->connect_error);
    }

    return $connection;
}

function connectPdo(string $host, string $user, string $password, string $database): PDO
{
    try {
        return new PDO(
            "mysql:host=$host;dbname=$database;charset=utf8mb4",
            $user,
            $password,
            [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            ]
        );
    } catch (PDOException $exception) {
        die("PDO connection to '$database' failed: " . $exception->getMessage());
    }
}

// Keep this for existing doctor portal files that expect $conn.
$database = 'vaxassist';
$conn = connectMysqli($host, $user, $password, $database);

// PDO connection for login.php, using the same database.
$pdo = connectPdo($host, $user, $password, $database);

// Add these only if those databases exist and the role pages need them.
$doctorDb = connectMysqli($host, $user, $password, 'doctors');
$patientDb = connectMysqli($host, $user, $password, 'patients');
$adminDb = connectMysqli($host, $user, $password, 'users');