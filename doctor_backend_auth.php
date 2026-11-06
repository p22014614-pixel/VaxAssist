<?php
// Shared doctor-backend guard: starts the app session, verifies doctor login, and checks CSRF on writes.
// Reuse the authenticated session and development preview handling from the API.
require_once __DIR__ . '/api/lib.php';
// Connect doctor endpoints directly to the shared clinic database. db.php also
// opens optional legacy databases (doctors/patients), which may not exist.
$conn = new mysqli('localhost', 'root', '', 'vaxassist');
if ($conn->connect_error) {
    http_response_code(503);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['status' => 'error', 'message' => 'The clinic database is unavailable.']);
    exit;
}
$conn->set_charset('utf8mb4');

if (empty($_SESSION['doctor_id'])) {
    http_response_code(401);
    echo json_encode(['status' => 'error', 'message' => 'Please log in with a doctor account.']);
    exit;
}

$doctor_id = (int) $_SESSION['doctor_id'];
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    $token = $_SERVER['HTTP_X_CSRF_TOKEN'] ?? '';
    if (empty($_SESSION['csrf']) || !hash_equals($_SESSION['csrf'], $token)) {
        http_response_code(403);
        echo json_encode(['status' => 'error', 'message' => 'Your session expired. Please refresh and try again.']);
        exit;
    }
}
