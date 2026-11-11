<?php
// Shared API bootstrap: configures database/session/security helpers; doctor auth reuses its session setup.
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
    'secure'   => !empty($_SERVER['HTTPS'])
        && strtolower((string) $_SERVER['HTTPS']) !== 'off',
]);
session_name('vaxassist_patient');
session_start();

header('Content-Type: application/json; charset=utf-8');
header('X-Content-Type-Options: nosniff');
header('Cache-Control: no-store');

// Opens and reuses the PDO connection used by the shared API.
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

// Sends a JSON response with the requested HTTP status.
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
// Sends a 201 response for a newly created API resource.
function created(string $location, $data): void
{
    header('Location: ' . $location);
    out($data, 201);
}

// Returns a consistent JSON error response and stops the request.
function fail(int $status, string $message, array $fields = []): void
{
    out(['ok' => false, 'error' => $message, 'fields' => $fields], $status);
}

// Creates or returns the CSRF token shared by protected API requests.
function csrf_token(): string
{
    if (empty($_SESSION['csrf'])) {
        $_SESSION['csrf'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf'];
}

// Loads the patient attached to the current API session, if one is signed in.
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

// Requires a valid patient session before protected patient API actions continue.
function require_login(): array
{
    $patient = current_patient();
    if (!$patient) {
        fail(401, 'Please log in first.');
    }
    return $patient;
}

// Converts a patient row into the safe user summary returned to the browser.
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

// Rejects requests whose HTTP method is not GET.
function only_get(): void
{
    if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
        header('Allow: GET');
        fail(405, 'Method not allowed.');
    }
}

// Trims and limits user-provided text to the requested maximum length.
function text_in($value, int $max): string
{
    $value = trim((string) $value);
    return mb_substr($value, 0, $max);
}

// Checks that a value is a real date written in YYYY-MM-DD format.
function valid_date(string $date): bool
{
    $d = DateTime::createFromFormat('Y-m-d', $date);
    return $d && $d->format('Y-m-d') === $date;
}

// Normalizes a time value to 24-hour HH:MM format.
function hm(?string $time): string
{
    return $time ? substr($time, 0, 5) : '';
}

// The team's appointments table stores a 2-hour window; patient bookings fill it in too.
// Maps a clock time to one of the appointment booking windows.
function time_window(string $hm): string
{
    $h = (int) substr($hm, 0, 2);
    if ($h < 10) return '08:00 AM - 10:00 AM';
    if ($h < 12) return '10:00 AM - 12:00 PM';
    if ($h < 15) return '01:00 PM - 03:00 PM';
    return '03:00 PM - 05:00 PM';
}

// Returns the starting time represented by a booking-window label.
function window_start(?string $window): string
{
    if (!$window || !preg_match('/^(\d\d):(\d\d) (AM|PM)/', $window, $m)) return '';
    $h = (int) $m[1] % 12 + ($m[3] === 'PM' ? 12 : 0);
    return sprintf('%02d:%s', $h, $m[2]);
}

// The visit's real start time. The admin page edits only the 2-hour window (time_slot), which can leave
// the exact appointment_time behind, so the exact time counts only while it still sits inside that window.
function visit_time(array $row): string
{
    $exact = !empty($row['appointment_time']) ? hm($row['appointment_time']) : '';
    if ($exact !== '' && time_window($exact) === ($row['time_slot'] ?? '')) return $exact;
    return window_start($row['time_slot'] ?? null);
}

// Lists the clinic's bookable half-hour appointment times.
function slot_times(): array
{
    $times = [];
    foreach ([9, 10, 11, 13, 14, 15, 16] as $h) {
        $times[] = sprintf('%02d:00', $h);
        $times[] = sprintf('%02d:30', $h);
    }
    return $times;
}

// Checks the doctor's weekday availability and approved leave for a date.
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
// Marks appointment times as available or taken for a doctor and date.
function available_slots(int $doctorId, string $date, ?int $ignoreAppointment = null): array
{
    if (!doctor_works_on($doctorId, $date) || $date < date('Y-m-d')) return [];

    $stmt = db()->prepare(
        "SELECT appointment_id, appointment_time, time_slot FROM appointments
         WHERE doctor_id = ? AND appointment_date = ? AND status IN ('Scheduled', 'Confirmed')"
    );
    $stmt->execute([$doctorId, $date]);
    $taken = [];
    $windows = [];
    foreach ($stmt->fetchAll() as $row) {
        if ($ignoreAppointment !== null && (int) $row['appointment_id'] === $ignoreAppointment) continue;
        $exact = !empty($row['appointment_time']) && time_window(hm($row['appointment_time'])) === $row['time_slot'];
        if ($exact) $taken[hm($row['appointment_time'])] = true;
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

// True when the patient already has a scheduled visit (with any doctor) at this date and time.
function patient_busy(int $patientId, string $date, string $time, ?int $ignoreAppointment = null): bool
{
    $stmt = db()->prepare("SELECT appointment_id, appointment_time, time_slot FROM appointments WHERE patient_id = ? AND appointment_date = ? AND status IN ('Scheduled', 'Confirmed')");
    $stmt->execute([$patientId, $date]);
    foreach ($stmt->fetchAll() as $row) {
        if ($ignoreAppointment !== null && (int) $row['appointment_id'] === $ignoreAppointment) continue;
        $exact = !empty($row['appointment_time']) && time_window(hm($row['appointment_time'])) === $row['time_slot'];
        if ($exact ? hm($row['appointment_time']) === $time : $row['time_slot'] === time_window($time)) return true;
    }
    return false;
}

// Saves a patient notification and, when supplied, links it to its responsible doctor visit.
function add_notification(int $patientId, string $type, string $title, string $body, ?string $url = null, ?string $label = null, ?int $doctorId = null, ?int $appointmentId = null): void
{
    db()->prepare("INSERT INTO notifications (patient_id, recipient_type, doctor_id, appointment_id, type, title, body, action_url, action_label) VALUES (?, 'patient', ?, ?, ?, ?, ?, ?, ?)")
        ->execute([$patientId, $doctorId, $appointmentId, $type, $title, $body, $url, $label]);
}

// Keeps the patient's payments and notices in step with what the clinic did to their visits without the
// patient being involved: an admin cancelling a visit, or a doctor going on approved leave on a booked day.
// It is safe to run often, because each change is made once and then no longer matches.
function sync_clinic_changes(int $patientId): void
{
    $pdo = db();

    // A visit the clinic cancelled must not stay payable. (When the patient cancels, the payment is already cleared.)
    $cancelled = $pdo->prepare(
        "SELECT p.payment_id, p.status AS pay_status, a.appointment_date, COALESCE(v.name, 'Consultation') AS vaccine
           FROM payments p
           JOIN appointments a ON a.appointment_id = p.appointment_id
           LEFT JOIN vaccines v ON v.vaccine_id = a.vaccine_id
          WHERE p.patient_id = ? AND a.status = 'Cancelled' AND p.status IN ('Pending', 'Paid')"
    );
    $cancelled->execute([$patientId]);
    foreach ($cancelled->fetchAll() as $row) {
        if ($row['pay_status'] === 'Paid') {
            $pdo->prepare("UPDATE payments SET status = 'Refunded' WHERE payment_id = ? AND status = 'Paid'")->execute([$row['payment_id']]);
        } else {
            $pdo->prepare("DELETE FROM payments WHERE payment_id = ? AND status = 'Pending'")->execute([$row['payment_id']]);
        }
        add_notification($patientId, 'Appointment', 'Appointment cancelled by the clinic',
            'Your ' . $row['vaccine'] . ' appointment on ' . date('j M Y', strtotime($row['appointment_date'])) . ' was cancelled by the clinic.'
            . ($row['pay_status'] === 'Paid' ? ' Your payment has been marked as refunded.' : ''),
            'appointments.html?tab=history', 'View history');
    }

    // A booked visit that falls on a day the doctor is on approved leave needs a new time.
    $clash = $pdo->prepare(
        "SELECT a.appointment_date, d.first_name, d.last_name, COALESCE(v.name, 'Consultation') AS vaccine
           FROM appointments a
           JOIN doctors d ON d.doctor_id = a.doctor_id
           LEFT JOIN vaccines v ON v.vaccine_id = a.vaccine_id
          WHERE a.patient_id = ? AND a.status IN ('Scheduled', 'Confirmed') AND a.appointment_date >= CURDATE()
            AND EXISTS (SELECT 1 FROM leave_requests l WHERE l.doctor_id = a.doctor_id AND l.status = 'Approved'
                          AND a.appointment_date BETWEEN l.start_date AND l.end_date)"
    );
    $clash->execute([$patientId]);
    $seen = $pdo->prepare("SELECT 1 FROM notifications WHERE patient_id = ? AND title = 'Doctor unavailable' AND body = ? LIMIT 1");
    foreach ($clash->fetchAll() as $row) {
        $body = 'Dr. ' . $row['first_name'] . ' ' . $row['last_name'] . ' is on leave on ' . date('j M Y', strtotime($row['appointment_date']))
              . ', the day of your ' . $row['vaccine'] . ' appointment. Please reschedule.';
        $seen->execute([$patientId, $body]);
        if (!$seen->fetch()) {
            add_notification($patientId, 'Appointment', 'Doctor unavailable', $body, 'appointments.html', 'Reschedule');
        }
    }
}

// Stores a doctor alert in the shared notification table without exposing it in the patient's feed.
function add_doctor_notification(PDO $pdo, int $doctorId, int $patientId, ?int $appointmentId, string $type, string $title, string $body): void
{
    $pdo->prepare("INSERT INTO notifications (patient_id, recipient_type, doctor_id, appointment_id, type, title, body, action_url, action_label)
        VALUES (?, 'doctor', ?, ?, ?, ?, ?, 'doctor_dashboard.html', 'View notification')")
        ->execute([$patientId, $doctorId, $appointmentId, $type, $title, $body]);
}

// Formats a database time value as an ISO-compatible timestamp.
function iso_time(string $dbTime): string
{
    return (new DateTime($dbTime))->format('c');
}

// Converts a submitted gender value to the database enum spelling.
function gender_to_db($g): string
{
    $g = strtolower((string) $g);
    return $g === 'male' ? 'Male' : ($g === 'female' ? 'Female' : 'Other');
}

// Loads one patient record by its database ID.
function patient_row(int $id): array
{
    $stmt = db()->prepare('SELECT * FROM patients WHERE patient_id = ?');
    $stmt->execute([$id]);
    return $stmt->fetch();
}

// Splits a full name into first and remaining name parts.
function split_name(string $full): array
{
    $parts = explode(' ', trim($full), 2);
    return [$parts[0], $parts[1] ?? ''];
}

// Checks the minimum password length and character requirements.
function strong_password(string $p): bool
{
    return strlen($p) >= 8 && preg_match('/[A-Za-z]/', $p) && preg_match('/\d/', $p);
}

// For POST, PUT, PATCH and DELETE: check the security token and read the JSON body.
// Validates the CSRF token and decodes a protected JSON request body.
function write_input(): array
{
    $sent = $_SERVER['HTTP_X_CSRF_TOKEN'] ?? '';
    if (!hash_equals(csrf_token(), $sent)) {
        fail(403, 'Your session has expired. Please refresh the page and try again.');
    }
    $body = json_decode(file_get_contents('php://input'), true);
    return is_array($body) ? $body : [];
}
