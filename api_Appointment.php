<?php
declare(strict_types=1);

session_start();
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

if (empty($_SESSION['user_id'])) {
    http_response_code(401);
    echo json_encode(['error' => 'Please sign in to view appointments.']);
    exit;
}

require __DIR__ . '/db.php';

try {
    $statement = $pdo->query(
        'SELECT appointment_id, doctor_id, patient_id, appointment_date,
                time_slot, status, symptoms_notes, created_at
         FROM appointments
         ORDER BY appointment_date, time_slot, appointment_id'
    );

    echo json_encode(['appointments' => $statement->fetchAll()], JSON_THROW_ON_ERROR);
} catch (Throwable $exception) {
    http_response_code(500);
    echo json_encode([
        'error' => 'Could not load appointments. Check the appointments table and database connection.'
    ]);
}