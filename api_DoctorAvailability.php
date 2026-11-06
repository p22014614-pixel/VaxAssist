<?php
declare(strict_types=1);

require_once __DIR__ . '/admin_backend_auth.php';
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');

function respond(int $status, array $data): void
{
    http_response_code($status);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
    exit;
}



$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

if ($method === 'GET') {
    if (empty($_SESSION['doctor_availability_csrf'])) {
        $_SESSION['doctor_availability_csrf'] = bin2hex(random_bytes(32));
    }

    try {
        $rows = $pdo->query(
            'SELECT d.doctor_id, d.first_name, d.last_name, d.specialization,
                    da.weekday
             FROM doctors d
             LEFT JOIN doctor_availability da ON da.doctor_id = d.doctor_id
             ORDER BY d.first_name, d.last_name, d.doctor_id'
        )->fetchAll();
        $doctors = [];
        foreach ($rows as $row) {
            $id = (int) $row['doctor_id'];
            if (!isset($doctors[$id])) {
                $doctors[$id] = [
                    'id' => $id,
                    'name' => trim($row['first_name'] . ' ' . $row['last_name']),
                    'specialization' => $row['specialization'],
                    'weekdays' => [],
                ];
            }
            if ($row['weekday'] !== null) {
                $doctors[$id]['weekdays'][] = (int) $row['weekday'];
            }
        }
        respond(200, ['doctors' => array_values($doctors), 'csrfToken' => $_SESSION['doctor_availability_csrf']]);
    } catch (PDOException $exception) {
        respond(500, ['error' => 'Could not load doctor availability. Check that the doctor_availability table exists.']);
    }
}

if ($method !== 'PUT') {
    header('Allow: GET, PUT');
    respond(405, ['error' => 'Method not allowed.']);
}

$csrf = (string) ($_SERVER['HTTP_X_CSRF_TOKEN'] ?? '');
if (empty($_SESSION['doctor_availability_csrf']) || !hash_equals($_SESSION['doctor_availability_csrf'], $csrf)) {
    respond(403, ['error' => 'Your session has expired. Refresh the page and try again.']);
}
$payload = json_decode((string) file_get_contents('php://input'), true);
$doctorId = filter_var($payload['doctorId'] ?? null, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
$weekdays = $payload['weekdays'] ?? null;
if (!$doctorId || !is_array($weekdays) || count($weekdays) > 5) {
    respond(422, ['error' => 'Choose a doctor and valid working weekdays.']);
}
$weekdays = array_values(array_unique(array_map('intval', $weekdays)));
foreach ($weekdays as $weekday) {
    if ($weekday < 1 || $weekday > 5) {
        respond(422, ['error' => 'Working weekdays must be Monday through Friday.']);
    }
}

try {
    $exists = $pdo->prepare('SELECT 1 FROM doctors WHERE doctor_id = :id');
    $exists->execute(['id' => $doctorId]);
    if (!$exists->fetchColumn()) {
        respond(404, ['error' => 'Doctor not found.']);
    }
    $pdo->beginTransaction();
    $delete = $pdo->prepare('DELETE FROM doctor_availability WHERE doctor_id = :id');
    $delete->execute(['id' => $doctorId]);
    if ($weekdays) {
        $insert = $pdo->prepare('INSERT INTO doctor_availability (doctor_id, weekday) VALUES (:doctor_id, :weekday)');
        foreach ($weekdays as $weekday) {
            $insert->execute(['doctor_id' => $doctorId, 'weekday' => $weekday]);
        }
    }
    $pdo->commit();
    respond(200, ['message' => 'Doctor working days saved.']);
} catch (PDOException $exception) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    respond(500, ['error' => 'Could not save doctor working days. Check the doctor_availability table.']);
}