<?php
declare(strict_types=1);

$dbHost = 'localhost';
$dbName = 'vaxassist';
$dbUser = 'root';
$dbPassword = '';

try {
    $pdo = new PDO(
        "mysql:host={$dbHost};dbname={$dbName};charset=utf8mb4",
        $dbUser,
        $dbPassword,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );
} catch (PDOException $exception) {
    http_response_code(500);

    $scriptName = basename(
        (string) ($_SERVER['SCRIPT_NAME'] ?? '')
    );

    $acceptHeader = strtolower((string) ($_SERVER['HTTP_ACCEPT'] ?? ''));
    $expectsJson = strpos($acceptHeader, 'application/json') !== false
        || strpos(strtolower($scriptName), 'api_') === 0
        || substr(strtolower($scriptName), -8) === '_api.php';

    if ($expectsJson) {
        header('Content-Type: application/json; charset=utf-8');

        echo json_encode([
            'error' => 'Could not connect to the database. Check that MySQL is running and db.php settings are correct.'
        ]);

        exit;
    }

    exit(
        'Could not connect to the database. Check that MySQL is running and db.php settings are correct.'
    );
}