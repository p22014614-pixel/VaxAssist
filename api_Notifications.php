<?php
declare(strict_types=1);

session_start();
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

function api_reply(array $payload = [], int $status = 200): void
{
    http_response_code($status);
    if ($status !== 204) {
        echo json_encode($payload, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
    }
    exit;
}

function api_fail(int $status, string $message): void
{
    api_reply(['error' => $message], $status);
}

function request_body(): array
{
    $body = json_decode((string) file_get_contents('php://input'), true);
    if (!is_array($body)) {
        api_fail(400, 'Request body must be a JSON object.');
    }
    return $body;
}

function limited_text(mixed $value, int $length): ?string
{
    $text = trim((string) $value);
    if ($text === '') {
        return null;
    }

    return function_exists('mb_substr')
        ? mb_substr($text, 0, $length)
        : substr($text, 0, $length);
}

if (empty($_SESSION['user_id'])) {
    api_fail(401, 'Please sign in to continue.');
}

require __DIR__ . '/db.php';

$patientId = (int) $_SESSION['user_id'];
$action = (string) ($_GET['action'] ?? 'notifications');
$method = strtoupper((string) ($_SERVER['REQUEST_METHOD'] ?? 'GET'));

try {
    if ($action === 'notifications') {
        if ($method === 'GET') {
            $stmt = $pdo->prepare(
                'SELECT notification_id, type, title, body, action_url,
                        action_label, is_read, created_at
                 FROM notifications
                 WHERE patient_id = ?
                 ORDER BY created_at DESC, notification_id DESC'
            );
            $stmt->execute([$patientId]);

            $notifications = array_map(
                static fn(array $n): array => [
                    'id' => (int) $n['notification_id'],
                    'type' => strtolower((string) $n['type']),
                    'title' => (string) $n['title'],
                    'message' => (string) $n['body'],
                    'action_url' => (string) ($n['action_url'] ?? ''),
                    'action_label' => (string) ($n['action_label'] ?? ''),
                    'is_read' => (bool) $n['is_read'],
                    'created_at' => date(
                        DATE_ATOM,
                        strtotime((string) $n['created_at'])
                    ),
                ],
                $stmt->fetchAll()
            );

            api_reply(['notifications' => $notifications]);
        }

        if ($method === 'PATCH') {
            $body = request_body();

            if (empty($body['is_read'])) {
                api_fail(
                    422,
                    'The only supported change is marking notifications as read.'
                );
            }

            if (isset($_GET['id'])) {
                $stmt = $pdo->prepare(
                    'UPDATE notifications
                     SET is_read = 1
                     WHERE notification_id = ? AND patient_id = ?'
                );
                $stmt->execute([(int) $_GET['id'], $patientId]);

                if ($stmt->rowCount() === 0) {
                    $check = $pdo->prepare(
                        'SELECT 1 FROM notifications
                         WHERE notification_id = ? AND patient_id = ?'
                    );
                    $check->execute([(int) $_GET['id'], $patientId]);

                    if (!$check->fetchColumn()) {
                        api_fail(404, 'Notification not found.');
                    }
                }
            } else {
                $pdo->prepare(
                    'UPDATE notifications SET is_read = 1 WHERE patient_id = ?'
                )->execute([$patientId]);
            }

            api_reply([], 204);
        }

        if ($method === 'DELETE' && isset($_GET['id'])) {
            $stmt = $pdo->prepare(
                'DELETE FROM notifications
                 WHERE notification_id = ? AND patient_id = ?'
            );
            $stmt->execute([(int) $_GET['id'], $patientId]);

            if ($stmt->rowCount() === 0) {
                api_fail(404, 'Notification not found.');
            }

            api_reply([], 204);
        }

        api_fail(405, 'Method not allowed for notifications.');
    }

    if ($action === 'preferences') {
        $fields = [
            'email_reminders',
            'sms_reminders',
            'booster_alerts',
            'clinic_news',
        ];

        if ($method === 'GET') {
            $stmt = $pdo->prepare(
                'SELECT email_reminders, sms_reminders,
                        booster_alerts, clinic_news
                 FROM notification_preferences
                 WHERE patient_id = ?'
            );
            $stmt->execute([$patientId]);

            $row = $stmt->fetch() ?: array_fill_keys($fields, 1);

            api_reply([
                'preferences' => array_map(
                    static fn($value): bool => (bool) $value,
                    $row
                ),
            ]);
        }

        if ($method === 'PATCH') {
            $body = request_body();

            foreach ($fields as $field) {
                if (!array_key_exists($field, $body)
                    || !is_bool($body[$field])) {
                    api_fail(
                        422,
                        'Choose a value for every notification preference.'
                    );
                }
            }

            $values = array_map(
                static fn(string $field): int => $body[$field] ? 1 : 0,
                $fields
            );

            $pdo->prepare(
                'INSERT INTO notification_preferences
                    (patient_id, email_reminders, sms_reminders,
                     booster_alerts, clinic_news)
                 VALUES (?, ?, ?, ?, ?)
                 ON DUPLICATE KEY UPDATE
                    email_reminders = VALUES(email_reminders),
                    sms_reminders = VALUES(sms_reminders),
                    booster_alerts = VALUES(booster_alerts),
                    clinic_news = VALUES(clinic_news)'
            )->execute(array_merge([$patientId], $values));

            api_reply([], 204);
        }

        api_fail(405, 'Method not allowed for preferences.');
    }

    if ($action === 'precheck-forms') {
        if ($method === 'GET') {
            $stmt = $pdo->prepare(
                'SELECT f.form_id, f.submitted_at, v.name AS vaccine
                 FROM precheck_forms f
                 LEFT JOIN vaccines v ON v.id = f.vaccine_id
                 WHERE f.patient_id = ?
                 ORDER BY f.submitted_at DESC, f.form_id DESC
                 LIMIT 20'
            );
            $stmt->execute([$patientId]);

            $forms = array_map(
                static fn(array $f): array => [
                    'patient_name' => 'Myself',
                    'vaccine' => (string) ($f['vaccine'] ?? ''),
                    'submitted_at' => date(
                        DATE_ATOM,
                        strtotime((string) $f['submitted_at'])
                    ),
                ],
                $stmt->fetchAll()
            );

            api_reply(['forms' => $forms]);
        }

        if ($method === 'POST') {
            $body = request_body();
            $answers = is_array($body['answers'] ?? null)
                ? $body['answers']
                : [];

            foreach (
                ['fever', 'reaction', 'immune', 'recent', 'bleeding', 'pregnant']
                as $question
            ) {
                if (!in_array($answers[$question] ?? null, ['yes', 'no'], true)) {
                    api_fail(422, 'Please answer every health question.');
                }
            }

            $vaccineId = null;

            if (!empty($body['vaccine'])) {
                $vaccine = $pdo->prepare(
                    'SELECT id FROM vaccines WHERE name = ? LIMIT 1'
                );
                $vaccine->execute([(string) $body['vaccine']]);
                $vaccineId = $vaccine->fetchColumn() ?: null;
            }

            $yes = static fn(string $key): int =>
                ($answers[$key] ?? '') === 'yes' ? 1 : 0;

            $pdo->prepare(
                'INSERT INTO precheck_forms
                    (patient_id, vaccine_id, has_fever, severe_reaction,
                     weak_immune_system, pregnant_or_breastfeeding,
                     recent_vaccine, bleeding_disorder, allergies,
                     medications, notes)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
            )->execute([
                $patientId,
                $vaccineId,
                $yes('fever'),
                $yes('reaction'),
                $yes('immune'),
                $yes('pregnant'),
                $yes('recent'),
                $yes('bleeding'),
                limited_text($body['allergies'] ?? '', 300),
                limited_text($body['medications'] ?? '', 300),
                limited_text($body['notes'] ?? '', 500),
            ]);

            api_reply(['id' => (int) $pdo->lastInsertId()], 201);
        }

        api_fail(405, 'Method not allowed for pre-consultation forms.');
    }

    api_fail(404, 'Unknown notification API action.');
} catch (PDOException $exception) {
    api_fail(
        500,
        'Could not complete the request. Run notifications_migration.sql and check the database connection.'
    );
} catch (Throwable $exception) {
    api_fail(500, 'Could not complete the request.');
}