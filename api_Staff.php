<?php
declare(strict_types=1);

require_once __DIR__ . '/admin_backend_auth.php';
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');

function respond(int $status, array $data): void
{
    http_response_code($status);
    echo json_encode(
        $data,
        JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE
    );
    exit;
}

const STAFF_ROLES = [
    'Administrator',
    'Doctor',
    'Nurse',
    'Receptionist',
];

function readPayload(): array
{
    $payload = json_decode(
        (string) file_get_contents('php://input'),
        true
    );

    return is_array($payload) ? $payload : [];
}

function validateStaff(array $input): array
{
    $name = trim((string) ($input['name'] ?? ''));
    $email = strtolower(trim((string) ($input['email'] ?? '')));
    $role = trim((string) ($input['role'] ?? ''));
    $department = trim((string) ($input['department'] ?? ''));
    $phone = trim((string) ($input['phone'] ?? ''));

    $parts = preg_split('/\s+/', $name, 2) ?: [];

    if (
        $name === '' ||
        strlen($name) > 201 
    ) {
        respond(422, [
            'error' => 'Enter a staff member’s name.',
        ]);
    }

    if (!filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($email) > 255) {
        respond(422, ['error' => 'Enter a valid email address.']);
    }

    if (!in_array($role, STAFF_ROLES, true)) {
        respond(422, ['error' => 'Choose a valid staff role.']);
    }

    if (
        $department === '' ||
        strlen($department) > 100 ||
        strlen($phone) > 30
    ) {
        respond(422, [
            'error' => 'Enter a department and a phone number of 30 characters or fewer.',
        ]);
    }

    return [
        'first_name' => $parts[0] ??  $name,
        'last_name' => $parts[1] ?? '',
        'email' => $email,
        'role' => $role,
        'department' => $department,
        'phone' => $phone !== '' ? $phone : null,
    ];
}

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

if ($method === 'GET') {
    if (isset($_GET['count'])) {
        $count = (int) $pdo->query('SELECT COUNT(*) FROM staff')->fetchColumn();
        respond(200, ['count' => $count]);
    }
    
    if (empty($_SESSION['staff_csrf'])) {
        $_SESSION['staff_csrf'] = bin2hex(random_bytes(32));
    }

    $statement = $pdo->query(
        'SELECT id, first_name, last_name, email, phone, role, department
         FROM staff
         ORDER BY first_name, last_name, id'
    );

    $staff = array_map(static function (array $row): array {
        return [
            'id' => (int) $row['id'],
            'name' => trim($row['first_name'] . ' ' . $row['last_name']),
            'email' => $row['email'],
            'phone' => $row['phone'] ?? '',
            'role' => $row['role'],
            'department' => $row['department'],
        ];
    }, $statement->fetchAll());

    respond(200, [
        'staff' => $staff,
        'csrfToken' => $_SESSION['staff_csrf'],
    ]);
}

if (!in_array($method, ['POST', 'PUT', 'DELETE'], true)) {
    header('Allow: GET, POST, PUT, DELETE');
    respond(405, ['error' => 'Method not allowed.']);
}

$csrf = (string) ($_SERVER['HTTP_X_CSRF_TOKEN'] ?? '');

if (
    empty($_SESSION['staff_csrf']) ||
    !hash_equals($_SESSION['staff_csrf'], $csrf)
) {
    respond(403, [
        'error' => 'Your session has expired. Refresh the page and try again.',
    ]);
}

$input = readPayload();

try {
    if ($method === 'POST') {
        $member = validateStaff($input);

        $statement = $pdo->prepare(
            'INSERT INTO staff
                (first_name, last_name, email, phone, role, department)
             VALUES
                (:first_name, :last_name, :email, :phone, :role, :department)'
        );

        $statement->execute($member);

        respond(201, [
            'id' => (int) $pdo->lastInsertId(),
            'message' => 'Staff member added.',
        ]);
    }

    $id = filter_var(
        $input['id'] ?? null,
        FILTER_VALIDATE_INT,
        ['options' => ['min_range' => 1]]
    );

    if (!$id) {
        respond(422, ['error' => 'A valid staff member ID is required.']);
    }

    if ($method === 'PUT') {
        $member = validateStaff($input);

        $statement = $pdo->prepare(
            'UPDATE staff
             SET first_name = :first_name,
                 last_name = :last_name,
                 email = :email,
                 phone = :phone,
                 role = :role,
                 department = :department
             WHERE id = :id'
        );

        $statement->execute($member + ['id' => $id]);

        if ($statement->rowCount() === 0) {
            $check = $pdo->prepare('SELECT id FROM staff WHERE id = ?');
            $check->execute([$id]);

            if (!$check->fetch()) {
                respond(404, ['error' => 'Staff member not found.']);
            }
        }

        respond(200, ['message' => 'Staff member updated.']);
    }

    $statement = $pdo->prepare('DELETE FROM staff WHERE id = ?');
    $statement->execute([$id]);

    if ($statement->rowCount() === 0) {
        respond(404, ['error' => 'Staff member not found.']);
    }

    respond(200, ['message' => 'Staff member deleted.']);
} catch (PDOException $exception) {
    if ($exception->getCode() === '23000') {
        respond(409, [
            'error' => 'A staff member with that email address already exists.',
        ]);
    }

    error_log('Staff API database error: ' . $exception->getMessage());

    respond(500, [
        'error' => 'The staff change could not be saved. Check the database connection and table.',
    ]);
}