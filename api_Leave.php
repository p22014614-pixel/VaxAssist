<?php
declare(strict_types=1);

session_start();
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');

function respond(int $status, array $data): void
{
    http_response_code($status);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
    exit;
}

require __DIR__ . '/db.php';

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

if ($method === 'GET') {
    if (empty($_SESSION['leave_csrf'])) {
        $_SESSION['leave_csrf'] = bin2hex(random_bytes(32));
    }

    try {
        $stmt = $pdo->query(
            'SELECT lr.leave_id, lr.doctor_id, lr.start_date, lr.end_date,
                    lr.reason, lr.status, lr.created_at,
                    d.first_name, d.last_name, d.specialization
             FROM leave_requests AS lr
             JOIN doctors AS d ON d.doctor_id = lr.doctor_id
             ORDER BY lr.created_at DESC, lr.leave_id DESC'
        );

        respond(200, [
            'requests' => $stmt->fetchAll(),
            'csrfToken' => $_SESSION['leave_csrf'],
        ]);
    } catch (Throwable $exception) {
        error_log('Leave API error: ' . $exception->getMessage());
        respond(500, ['error' => 'Could not load leave requests.']);
    }
}

if ($method !== 'PUT') {
    header('Allow: GET, PUT');
    respond(405, ['error' => 'Method not allowed.']);
}

$token = (string) ($_SERVER['HTTP_X_CSRF_TOKEN'] ?? '');

if (
    empty($_SESSION['leave_csrf']) ||
    !hash_equals($_SESSION['leave_csrf'], $token)
) {
    respond(403, ['error' => 'Session expired. Refresh the page and try again.']);
}

$payload = json_decode((string) file_get_contents('php://input'), true);

if (!is_array($payload)) {
    respond(400, ['error' => 'Invalid request data.']);
}

$leaveId = filter_var(
    $payload['leave_id'] ?? null,
    FILTER_VALIDATE_INT,
    ['options' => ['min_range' => 1]]
);
$status = (string) ($payload['status'] ?? '');

if (!$leaveId || !in_array($status, ['Approved', 'Rejected'], true)) {
    respond(422, ['error' => 'Invalid leave request or decision.']);
}

try {
    $update = $pdo->prepare(
        "UPDATE leave_requests
         SET status = :status
         WHERE leave_id = :leave_id AND status = 'Pending'"
    );
    $update->execute([
        'status' => $status,
        'leave_id' => $leaveId,
    ]);

    if ($update->rowCount() === 0) {
        $check = $pdo->prepare(
            'SELECT status FROM leave_requests WHERE leave_id = ?'
        );
        $check->execute([$leaveId]);
        $currentStatus = $check->fetchColumn();

        if ($currentStatus === false) {
            respond(404, ['error' => 'Leave request not found.']);
        }

        if ($currentStatus !== $status) {
            respond(409, ['error' => 'This request has already been reviewed.']);
        }
    }

    respond(200, ['message' => 'Leave request updated.']);
} catch (Throwable $exception) {
    error_log('Leave API update error: ' . $exception->getMessage());
    respond(500, ['error' => 'Could not save the leave decision.']);
}