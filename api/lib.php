<?php
// Shared helpers for every patient-side API file.
// This file is separate from the team's db.php on purpose, so the patient side
// never changes the files the doctor/admin side relies on.

const DB_HOST = '127.0.0.1';
const DB_NAME = 'vaxassist_db';
const DB_USER = 'root';
const DB_PASS = '';

date_default_timezone_set('Asia/Kuala_Lumpur');

// Development only: let the pages served by VS Code's Live Server / Live Preview
// (ports 3000 and 5500) call this API on port 8000. Only these exact origins are
// allowed, never "*", because the requests carry the login cookie.
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
if (preg_match('#^http://(127\.0\.0\.1|localhost):(3000|5500|8000)$#', $origin)) {
    header('Access-Control-Allow-Origin: ' . $origin);
    header('Access-Control-Allow-Credentials: true');
    header('Access-Control-Allow-Headers: Content-Type, X-CSRF-Token, X-Dev-Session, Accept');
    header('Access-Control-Expose-Headers: X-Dev-Session');
    header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');
    header('Vary: Origin');
}
if (($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// Development only, for VS Code's embedded Live Preview (port 3000). That preview runs
// inside an iframe, where the browser refuses to keep the session cookie. For that one
// origin the session id is also passed in a header. Real sites never use this.
$devPreview = (bool) preg_match('#^http://(127\.0\.0\.1|localhost):3000$#', $origin);
if ($devPreview && !empty($_SERVER['HTTP_X_DEV_SESSION'])
    && preg_match('/^[A-Za-z0-9,-]{22,128}$/', $_SERVER['HTTP_X_DEV_SESSION'])) {
    ini_set('session.use_strict_mode', '1');
    session_id($_SERVER['HTTP_X_DEV_SESSION']);
}

session_set_cookie_params([
    'lifetime' => 0,
    'path'     => '/',
    'httponly' => true,
    'samesite' => 'Lax',
    'secure'   => !empty($_SERVER['HTTPS']),
]);
session_name('vaxassist_patient');
session_start();

header('Content-Type: application/json; charset=utf-8');
header('X-Content-Type-Options: nosniff');
header('Cache-Control: no-store');

function db(): PDO
{
    static $pdo = null;
    if ($pdo === null) {
        try {
            $pdo = new PDO(
                'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4',
                DB_USER,
                DB_PASS,
                [
                    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES   => false,
                ]
            );
            $pdo->exec("SET time_zone = '+08:00'");
        } catch (PDOException $e) {
            error_log('DB connection failed: ' . $e->getMessage());
            fail(500, 'The service is temporarily unavailable.');
        }
    }
    return $pdo;
}

function out($data, int $status = 200): void
{
    global $devPreview;
    if ($devPreview) {
        header('X-Dev-Session: ' . session_id());
    }
    http_response_code($status);
    if ($status !== 204) {
        echo json_encode($data, JSON_UNESCAPED_UNICODE);
    }
    exit;
}

// 201 Created, with the address of the new resource in the Location header.
function created(string $location, $data): void
{
    header('Location: ' . $location);
    out($data, 201);
}

function fail(int $status, string $message, array $fields = []): void
{
    out(['ok' => false, 'error' => $message, 'fields' => $fields], $status);
}

function csrf_token(): string
{
    if (empty($_SESSION['csrf'])) {
        $_SESSION['csrf'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf'];
}

function current_patient(): ?array
{
    if (empty($_SESSION['patient_id'])) {
        return null;
    }
    $stmt = db()->prepare('SELECT patient_id, full_name, email FROM patients WHERE patient_id = ?');
    $stmt->execute([$_SESSION['patient_id']]);
    $row = $stmt->fetch();
    return $row ?: null;
}

function require_login(): array
{
    $patient = current_patient();
    if (!$patient) {
        fail(401, 'Please log in first.');
    }
    return $patient;
}

function user_payload(array $patient): array
{
    $parts = explode(' ', trim($patient['full_name']), 2);
    return [
        'id'         => (int) $patient['patient_id'],
        'first_name' => $parts[0],
        'last_name'  => $parts[1] ?? '',
        'email'      => $patient['email'],
    ];
}

function only_get(): void
{
    if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
        header('Allow: GET');
        fail(405, 'Method not allowed.');
    }
}

function text_in($value, int $max): string
{
    $value = trim((string) $value);
    return mb_substr($value, 0, $max);
}

function valid_date(string $date): bool
{
    $d = DateTime::createFromFormat('Y-m-d', $date);
    return $d && $d->format('Y-m-d') === $date;
}

function hm(?string $time): string
{
    return $time ? substr($time, 0, 5) : '';
}

// The team's appointments table stores a 2-hour window; patient bookings fill it in too.
function time_window(string $hm): string
{
    $h = (int) substr($hm, 0, 2);
    if ($h < 10) return '08:00 AM - 10:00 AM';
    if ($h < 12) return '10:00 AM - 12:00 PM';
    if ($h < 15) return '01:00 PM - 03:00 PM';
    return '03:00 PM - 05:00 PM';
}

function window_start(?string $window): string
{
    if (!$window || !preg_match('/^(\d\d):(\d\d) (AM|PM)/', $window, $m)) return '';
    $h = (int) $m[1] % 12 + ($m[3] === 'PM' ? 12 : 0);
    return sprintf('%02d:%s', $h, $m[2]);
}

function slot_times(): array
{
    $times = [];
    foreach ([9, 10, 11, 13, 14, 15, 16] as $h) {
        $times[] = sprintf('%02d:00', $h);
        $times[] = sprintf('%02d:30', $h);
    }
    return $times;
}

function doctor_works_on(int $doctorId, string $date): bool
{
    if (!valid_date($date)) return false;
    $weekday = (int) date('N', strtotime($date));
    $stmt = db()->prepare('SELECT 1 FROM doctor_availability WHERE doctor_id = ? AND weekday = ?');
    $stmt->execute([$doctorId, $weekday]);
    if (!$stmt->fetch()) return false;

    $leave = db()->prepare("SELECT 1 FROM leave_requests WHERE doctor_id = ? AND status = 'Approved' AND ? BETWEEN start_date AND end_date");
    $leave->execute([$doctorId, $date]);
    return !$leave->fetch();
}

// Every half-hour slot for a doctor on a date, marked available or not.
function available_slots(int $doctorId, string $date, ?int $ignoreAppointment = null): array
{
    if (!doctor_works_on($doctorId, $date) || $date < date('Y-m-d')) return [];

    $stmt = db()->prepare(
        "SELECT appointment_id, appointment_time, time_slot FROM appointments
         WHERE doctor_id = ? AND appointment_date = ? AND status = 'Scheduled'"
    );
    $stmt->execute([$doctorId, $date]);
    $taken = [];
    $windows = [];
    foreach ($stmt->fetchAll() as $row) {
        if ($ignoreAppointment !== null && (int) $row['appointment_id'] === $ignoreAppointment) continue;
        if ($row['appointment_time']) $taken[hm($row['appointment_time'])] = true;
        else $windows[$row['time_slot']] = true;
    }

    $now = date('H:i', time() + 3600);
    $isToday = $date === date('Y-m-d');
    $slots = [];
    foreach (slot_times() as $t) {
        $free = empty($taken[$t]) && empty($windows[time_window($t)]) && !($isToday && $t < $now);
        $slots[] = ['time' => $t, 'available' => $free];
    }
    return $slots;
}

function add_notification(int $patientId, string $type, string $title, string $body, ?string $url = null, ?string $label = null): void
{
    db()->prepare('INSERT INTO notifications (patient_id, type, title, body, action_url, action_label) VALUES (?, ?, ?, ?, ?, ?)')
        ->execute([$patientId, $type, $title, $body, $url, $label]);
}

function iso_time(string $dbTime): string
{
    return (new DateTime($dbTime))->format('c');
}

function gender_to_db($g): string
{
    $g = strtolower((string) $g);
    return $g === 'male' ? 'Male' : ($g === 'female' ? 'Female' : 'Other');
}

function patient_row(int $id): array
{
    $stmt = db()->prepare('SELECT * FROM patients WHERE patient_id = ?');
    $stmt->execute([$id]);
    return $stmt->fetch();
}

function split_name(string $full): array
{
    $parts = explode(' ', trim($full), 2);
    return [$parts[0], $parts[1] ?? ''];
}

function strong_password(string $p): bool
{
    return strlen($p) >= 8 && preg_match('/[A-Za-z]/', $p) && preg_match('/\d/', $p);
}

// For POST, PUT, PATCH and DELETE: check the security token and read the JSON body.
function write_input(): array
{
    $sent = $_SERVER['HTTP_X_CSRF_TOKEN'] ?? '';
    if (!hash_equals(csrf_token(), $sent)) {
        fail(403, 'Your session has expired. Please refresh the page and try again.');
    }
    $body = json_decode(file_get_contents('php://input'), true);
    return is_array($body) ? $body : [];
}
