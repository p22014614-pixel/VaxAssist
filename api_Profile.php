<?php
declare(strict_types=1);

require_once __DIR__ . '/admin_backend_auth.php';
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

function respond(int $status, array $data): void
{
    http_response_code($status);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
    exit;
}



$userId = (int) $_SESSION['admin_id'];
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

if ($method === 'GET') {
    if (empty($_SESSION['profile_csrf'])) {
        $_SESSION['profile_csrf'] = bin2hex(random_bytes(32));
    }

    $statement = $pdo->prepare(
        'SELECT u.first_name, u.last_name, u.email, u.phone, u.role, u.created_at,
                s.department AS staff_department, s.role AS staff_role
         FROM users AS u
         LEFT JOIN staff AS s ON LOWER(s.email) = LOWER(u.email)
         WHERE u.id = ? LIMIT 1'
    );
    $statement->execute([$userId]);
    $user = $statement->fetch();

    if (!$user) {
        session_destroy();
        respond(401, ['error' => 'Your account could not be found. Please sign in again.']);
    }

    $role = trim((string) ($user['staff_role'] ?: ($user['role'] ?: ($_SESSION['role'] ?? ''))));

    respond(200, [
        'profile' => [
            'firstName' => $user['first_name'],
            'lastName' => $user['last_name'],
            'fullName' => trim($user['first_name'] . ' ' . $user['last_name']),
            'email' => $user['email'],
            'phone' => $user['phone'] ?? '',
            'role' => $role !== '' ? $role : 'Administrator',
            'department' => $user['staff_department'] ?? '',
            'createdAt' => $user['created_at'],
        ],
        'csrfToken' => $_SESSION['profile_csrf'],
    ]);
}

if ($method !== 'PUT') {
    header('Allow: GET, PUT');
    respond(405, ['error' => 'Method not allowed.']);
}

$providedToken = (string) ($_SERVER['HTTP_X_CSRF_TOKEN'] ?? '');
if (empty($_SESSION['profile_csrf']) || !hash_equals($_SESSION['profile_csrf'], $providedToken)) {
    respond(403, ['error' => 'Your session expired. Refresh the page and try again.']);
}

$input = json_decode((string) file_get_contents('php://input'), true);
if (!is_array($input)) {
    respond(400, ['error' => 'Invalid profile data.']);
}

$firstName = trim((string) ($input['firstName'] ?? ''));
$lastName = trim((string) ($input['lastName'] ?? ''));
$email = strtolower(trim((string) ($input['email'] ?? '')));
$phone = trim((string) ($input['phone'] ?? ''));

if ($firstName === '' || strlen($firstName) > 100 || $lastName === '' || strlen($lastName) > 100) {
    respond(422, ['error' => 'Enter a first and last name (up to 100 characters each).']);
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($email) > 255) {
    respond(422, ['error' => 'Enter a valid email address.']);
}

if (strlen($phone) > 30) {
    respond(422, ['error' => 'Phone number must be 30 characters or fewer.']);
}

try {
    $statement = $pdo->prepare(
        'UPDATE users SET first_name = :first_name, last_name = :last_name,
         email = :email, phone = :phone WHERE id = :id'
    );
    $statement->execute([
        ':first_name' => $firstName,
        ':last_name' => $lastName,
        ':email' => $email,
        ':phone' => $phone !== '' ? $phone : null,
        ':id' => $userId,
    ]);

    respond(200, ['message' => 'Profile details saved to your account.']);
} catch (PDOException $exception) {
    if ($exception->getCode() === '23000') {
        respond(409, ['error' => 'That email address is already linked to another account.']);
    }

    error_log('Profile API database error: ' . $exception->getMessage());
    respond(500, ['error' => 'Could not save profile details. Please try again.']);
}