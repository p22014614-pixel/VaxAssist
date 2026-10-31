<?php
// Reads and updates the signed-in doctor's profile, photo, and leave requests.
require __DIR__ . '/doctor_backend_auth.php';

$input = json_decode(file_get_contents('php://input'), true) ?: [];
$action = $_GET['action'] ?? $_POST['action'] ?? $input['action'] ?? 'get_profile';

if ($action === 'profile_photo' && $_SERVER['REQUEST_METHOD'] === 'GET') {
    // Streams this doctor's private profile image from the database.
    $stmt = $conn->prepare('SELECT profile_photo, profile_photo_mime FROM doctors WHERE doctor_id = ?');
    $stmt->bind_param('i', $doctor_id);
    $stmt->execute();
    $row = $stmt->get_result()->fetch_assoc();
    if (!$row || $row['profile_photo'] === null) {
        http_response_code(404);
        exit;
    }
    header('Content-Type: ' . $row['profile_photo_mime']);
    header('Cache-Control: private, no-store');
    header('X-Content-Type-Options: nosniff');
    echo $row['profile_photo'];
    exit;
}

if ($action === 'get_profile' && $_SERVER['REQUEST_METHOD'] === 'GET') {
    // Returns editable profile fields and whether a stored photo exists.
    $stmt = $conn->prepare('SELECT first_name, last_name, email, specialization, consultation_room, profile_photo IS NOT NULL AS has_photo FROM doctors WHERE doctor_id = ?');
    $stmt->bind_param('i', $doctor_id);
    $stmt->execute();
    $row = $stmt->get_result()->fetch_assoc();
    if (!$row) {
        http_response_code(404);
        echo json_encode(['status' => 'error', 'message' => 'Doctor profile not found.']);
        exit;
    }
    echo json_encode([
        'status' => 'success',
        'fullName' => 'Dr. ' . $row['first_name'] . ' ' . $row['last_name'],
        'email' => $row['email'],
        'specialization' => $row['specialization'],
        'consultationRoom' => $row['consultation_room'],
        'hasPhoto' => (bool) $row['has_photo'],
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if ($action === 'upload_photo' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    // Checks the image type and size, then saves it to this doctor's profile row.
    $token = $_SERVER['HTTP_X_CSRF_TOKEN'] ?? '';
    if (empty($_SESSION['csrf']) || !hash_equals($_SESSION['csrf'], $token)) {
        http_response_code(403);
        echo json_encode(['status' => 'error', 'message' => 'Your session expired. Please refresh and try again.']);
        exit;
    }
    if (!isset($_FILES['photo']) || $_FILES['photo']['error'] !== UPLOAD_ERR_OK) {
        http_response_code(422);
        echo json_encode(['status' => 'error', 'message' => 'Choose a profile photo to upload.']);
        exit;
    }
    $file = $_FILES['photo'];
    if ($file['size'] < 1 || $file['size'] > 2 * 1024 * 1024 || !is_uploaded_file($file['tmp_name'])) {
        http_response_code(422);
        echo json_encode(['status' => 'error', 'message' => 'The photo must be no larger than 2 MB.']);
        exit;
    }
    $image = @getimagesize($file['tmp_name']);
    $finfo = new finfo(FILEINFO_MIME_TYPE);
    $mime = $finfo->file($file['tmp_name']);
    $allowed = ['image/jpeg', 'image/png', 'image/webp'];
    if (!$image || !in_array($mime, $allowed, true) || $image['mime'] !== $mime) {
        http_response_code(422);
        echo json_encode(['status' => 'error', 'message' => 'Upload a valid JPEG, PNG, or WebP image.']);
        exit;
    }
    $binary = file_get_contents($file['tmp_name']);
    if ($binary === false) {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'The photo could not be read.']);
        exit;
    }
    $stmt = $conn->prepare('UPDATE doctors SET profile_photo = ?, profile_photo_mime = ? WHERE doctor_id = ?');
    $blob = null;
    $stmt->bind_param('bsi', $blob, $mime, $doctor_id);
    $stmt->send_long_data(0, $binary);
    if (!$stmt->execute()) {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'The profile photo could not be saved.']);
        exit;
    }
    echo json_encode(['status' => 'success', 'message' => 'Profile photo updated.']);
    exit;
}

if ($action === 'delete_photo' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    // Removes the saved image from this doctor's profile.
    $stmt = $conn->prepare('UPDATE doctors SET profile_photo = NULL, profile_photo_mime = NULL WHERE doctor_id = ?');
    $stmt->bind_param('i', $doctor_id);
    if (!$stmt->execute()) {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'The profile photo could not be deleted.']);
        exit;
    }
    echo json_encode(['status' => 'success', 'message' => 'Profile photo deleted.']);
    exit;
}

if ($action === 'update_profile' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    // Saves the doctor's specialization and consultation room after validation.
    $specialization = trim($input['specialization'] ?? '');
    $room = trim($input['room'] ?? '');
    if ($specialization === '' || mb_strlen($specialization) > 150 || $room === '' || mb_strlen($room) > 20) {
        http_response_code(422);
        echo json_encode(['status' => 'error', 'message' => 'Enter a specialization (up to 150 characters) and room (up to 20 characters).']);
        exit;
    }
    $stmt = $conn->prepare('UPDATE doctors SET specialization = ?, consultation_room = ? WHERE doctor_id = ?');
    $stmt->bind_param('ssi', $specialization, $room, $doctor_id);
    echo json_encode($stmt->execute() ? ['status' => 'success', 'message' => 'Profile updated.'] : ['status' => 'error', 'message' => 'Could not update profile.']);
    exit;
}

if ($action === 'submit_leave' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    // Validates the requested dates and creates a leave request for this doctor.
    $start = $input['start_date'] ?? '';
    $end = $input['end_date'] ?? '';
    $reason = trim($input['reason'] ?? '');
    $startDate = DateTime::createFromFormat('Y-m-d', $start);
    $endDate = DateTime::createFromFormat('Y-m-d', $end);
    if (!$startDate || !$endDate || $startDate->format('Y-m-d') !== $start || $endDate->format('Y-m-d') !== $end || $start < date('Y-m-d') || $end < $start || $reason === '' || mb_strlen($reason) > 1000) {
        http_response_code(422);
        echo json_encode(['status' => 'error', 'message' => 'Enter future or current leave dates and a reason (up to 1,000 characters).']);
        exit;
    }
    $stmt = $conn->prepare('INSERT INTO leave_requests (doctor_id, start_date, end_date, reason) VALUES (?, ?, ?, ?)');
    $stmt->bind_param('isss', $doctor_id, $start, $end, $reason);
    echo json_encode($stmt->execute() ? ['status' => 'success', 'message' => 'Leave request sent for approval.'] : ['status' => 'error', 'message' => 'Could not submit leave request.']);
    exit;
}

http_response_code(405);
echo json_encode(['status' => 'error', 'message' => 'Unsupported action.']);
