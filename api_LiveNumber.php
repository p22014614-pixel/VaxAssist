<?php
declare(strict_types=1);

require_once __DIR__ . '/admin_backend_auth.php';
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');




try {
    $count = (int) $pdo->query("SELECT COUNT(*) FROM leave_requests WHERE status = 'Pending'")->fetchColumn();
    echo json_encode(['count' => $count], JSON_THROW_ON_ERROR);
} catch (Throwable $exception) {
    http_response_code(500);
    echo json_encode(['error' => 'Could not load pending leave requests. Check the leave_requests table and database connection.']);
}