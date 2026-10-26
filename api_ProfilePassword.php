<?php
declare(strict_types=1);

session_start();
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

function respond(int $status, array $data): void
{
    http_response_code($status);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
    exit;
}

if (empty($_SESSION['user_id'])) {
    respond(401, ['error' => 'Please sign in to update your password.']);
}

if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'PUT') {
    header('Allow: PUT');
    respond(405, ['error' => 'Method not allowed.']);
}

$providedToken = (string) ($_SERVER['HTTP_X_CSRF_TOKEN'] ?? '');
if (empty($_SESSION['profile_csrf']) || !hash_equals($_SESSION['profile_csrf'], $providedToken)) {
    respond(403, ['error' => 'Your session expired. Refresh the page and try again.']);
}

$input = json_decode((string) file_get_contents('php://input'), true);
if (!is_array($input)) {
    respond(400, ['error' => 'Invalid password data.']);
}

$currentPassword = (string) ($input['currentPassword'] ?? '');
$newPassword = (string) ($input['newPassword'] ?? '');

if ($currentPassword === '' || strlen($newPassword) < 8) {
    respond(422, ['error' => 'Enter your current password and a new password of at least 8 characters.']);
}

require __DIR__ . '/db.php';

try {
    $statement = $pdo->prepare('SELECT password_hash FROM users WHERE id = ? LIMIT 1');
    $statement->execute([(int) $_SESSION['user_id']]);
    $user = $statement->fetch();

    if (!$user || !password_verify($currentPassword, $user['password_hash'])) {
        respond(403, ['error' => 'Your current password is incorrect.']);
    }

    $newHash = password_hash($newPassword, PASSWORD_DEFAULT);
    $update = $pdo->prepare('UPDATE users SET password_hash = ? WHERE id = ?');
    $update->execute([$newHash, (int) $_SESSION['user_id']]);

    respond(200, ['message' => 'Your password has been updated.']);
} catch (PDOException $exception) {
    error_log('Password API database error: ' . $exception->getMessage());
    respond(500, ['error' => 'Could not update your password. Please try again.']);
}