<?php
// Updates read status for alerts addressed to the signed-in doctor.
require __DIR__ . '/doctor_backend_auth.php';

function doctor_notification_response(array $data, int $status = 200): void
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'PATCH') {
    doctor_notification_response(['status' => 'error', 'message' => 'Method not allowed.'], 405);
}

$input = json_decode(file_get_contents('php://input'), true) ?: [];
if (!empty($input['mark_all_read'])) {
    $stmt = $conn->prepare("UPDATE notifications SET is_read = 1 WHERE doctor_id = ? AND recipient_type = 'doctor' AND is_read = 0");
    $stmt->bind_param('i', $doctor_id);
    $stmt->execute();
    doctor_notification_response(['status' => 'success']);
}

$notificationId = filter_var($input['notification_id'] ?? null, FILTER_VALIDATE_INT);
$isRead = filter_var($input['is_read'] ?? null, FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE);
if (!$notificationId || $isRead === null) {
    doctor_notification_response(['status' => 'error', 'message' => 'Choose a notification and read status.'], 422);
}

$readValue = $isRead ? 1 : 0;
$stmt = $conn->prepare("UPDATE notifications SET is_read = ? WHERE notification_id = ? AND doctor_id = ? AND recipient_type = 'doctor'");
$stmt->bind_param('iii', $readValue, $notificationId, $doctor_id);
$stmt->execute();
if ($stmt->affected_rows === 0) {
    $exists = $conn->prepare("SELECT 1 FROM notifications WHERE notification_id = ? AND doctor_id = ? AND recipient_type = 'doctor'");
    $exists->bind_param('ii', $notificationId, $doctor_id);
    $exists->execute();
    if (!$exists->get_result()->fetch_row()) {
        doctor_notification_response(['status' => 'error', 'message' => 'Notification not found.'], 404);
    }
}
doctor_notification_response(['status' => 'success']);
