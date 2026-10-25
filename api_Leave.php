<?php
session_start();
header('Content-Type: application/json; charset=utf-8');

require __DIR__ . '/db.php';

try {
    $stmt = $pdo->query(
        "SELECT
            lr.leave_id,
            lr.doctor_id,
            lr.start_date,
            lr.end_date,
            lr.reason,
            lr.status,
            lr.created_at,
         FROM leave_requests AS lr
         JOIN doctors AS d ON d.doctor_id = lr.doctor_id
         ORDER BY lr.created_at DESC"
    );

    echo json_encode(['requests' => $stmt->fetchAll()]);
} catch (PDOException $exception) {
    http_response_code(500);
    echo json_encode(['error' => 'Could not load leave requests.']);
}