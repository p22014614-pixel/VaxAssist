<?php
declare(strict_types=1);

session_start();
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

function readPayload(): array
{
    $payload = json_decode((string) file_get_contents('php://input'), true);
    return is_array($payload) ? $payload : [];
}

function validateVaccine(array $input): array
{
    $name = trim((string) ($input['name'] ?? ''));
    $code = strtoupper(trim((string) ($input['code'] ?? '')));
    $category = trim((string) ($input['category'] ?? ''));
    $price = filter_var($input['price'] ?? null, FILTER_VALIDATE_FLOAT);
    $quantity = filter_var($input['quantity'] ?? null, FILTER_VALIDATE_INT);

    if ($name === '' || mb_strlen($name) > 150) {
        respond(422, ['error' => 'Enter a vaccine name of 150 characters or fewer.']);
    }

    if ($code === '' || mb_strlen($code) > 40) {
        respond(422, ['error' => 'Enter a vaccine code of 40 characters or fewer.']);
    }

    if ($category === '' || mb_strlen($category) > 80) {
        respond(422, ['error' => 'Enter a category of 80 characters or fewer.']);
    }

    if ($price === false || $price < 0 || !is_finite((float) $price)) {
        respond(422, ['error' => 'Enter a valid price of zero or more.']);
    }

    if ($quantity === false || $quantity < 0) {
        respond(422, ['error' => 'Enter a whole quantity of zero or more.']);
    }

    return [
        'name' => $name,
        'code' => $code,
        'price' => number_format((float) $price, 2, '.', ''),
        'category' => $category,
        'quantity' => $quantity,
    ];
}

require __DIR__ . '/db.php';

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

if ($method === 'GET') {
    if (empty($_SESSION['vaccine_csrf'])) {
        $_SESSION['vaccine_csrf'] = bin2hex(random_bytes(32));
    }

    $statement = $pdo->query(
        'SELECT id, name, code, price, category, quantity
         FROM vaccines
         ORDER BY name, id'
    );

    $vaccines = array_map(static function (array $row): array {
        return [
            'id' => (int) $row['id'],
            'name' => $row['name'],
            'code' => $row['code'],
            'price' => (float) $row['price'],
            'category' => $row['category'],
            'quantity' => (int) $row['quantity'],
        ];
    }, $statement->fetchAll());

    respond(200, [
        'vaccines' => $vaccines,
        'csrfToken' => $_SESSION['vaccine_csrf'],
    ]);
}

if (!in_array($method, ['POST', 'PUT', 'DELETE'], true)) {
    header('Allow: GET, POST, PUT, DELETE');
    respond(405, ['error' => 'Method not allowed.']);
}

$csrf = (string) ($_SERVER['HTTP_X_CSRF_TOKEN'] ?? '');

if (
    empty($_SESSION['vaccine_csrf']) ||
    !hash_equals($_SESSION['vaccine_csrf'], $csrf)
) {
    respond(403, [
        'error' => 'Your session has expired. Refresh the page and try again.',
    ]);
}

$input = readPayload();

try {
    if ($method === 'POST') {
        $vaccine = validateVaccine($input);

        $statement = $pdo->prepare(
            'INSERT INTO vaccines (name, code, price, category, quantity)
             VALUES (:name, :code, :price, :category, :quantity)'
        );

        $statement->execute($vaccine);

        respond(201, [
            'id' => (int) $pdo->lastInsertId(),
            'message' => 'Vaccine added.',
        ]);
    }

    $id = filter_var(
        $input['id'] ?? null,
        FILTER_VALIDATE_INT,
        ['options' => ['min_range' => 1]]
    );

    if (!$id) {
        respond(422, ['error' => 'A valid vaccine ID is required.']);
    }

    if ($method === 'PUT') {
        $vaccine = validateVaccine($input);

        $statement = $pdo->prepare(
            'UPDATE vaccines
             SET name = :name,
                 code = :code,
                 price = :price,
                 category = :category,
                 quantity = :quantity
             WHERE id = :id'
        );

        $statement->execute($vaccine + ['id' => $id]);

        if ($statement->rowCount() === 0) {
            $check = $pdo->prepare('SELECT id FROM vaccines WHERE id = ?');
            $check->execute([$id]);

            if (!$check->fetch()) {
                respond(404, ['error' => 'Vaccine not found.']);
            }
        }

        respond(200, ['message' => 'Vaccine updated.']);
    }

    $statement = $pdo->prepare('DELETE FROM vaccines WHERE id = ?');
    $statement->execute([$id]);

    if ($statement->rowCount() === 0) {
        respond(404, ['error' => 'Vaccine not found.']);
    }

    respond(200, ['message' => 'Vaccine deleted.']);
} catch (PDOException $exception) {
    if ($exception->getCode() === '23000') {
        respond(409, ['error' => 'A vaccine with that code already exists.']);
    }

    error_log('Vaccine API database error: ' . $exception->getMessage());

    respond(500, [
        'error' => 'The inventory change could not be saved. Check the database connection and vaccines table.',
    ]);
}