<?php
// Sessions and accounts: log in, log out, register, reset a password.

function session_show(array $p, array $in): void
{
    $patient = current_patient();
    $unread = 0;
    if ($patient) {
        $stmt = db()->prepare("SELECT COUNT(*) FROM messages WHERE patient_id = ? AND sender_type = 'doctor' AND is_read = 0");
        $stmt->execute([$patient['patient_id']]);
        $unread = (int) $stmt->fetchColumn();
    }
    out(['user' => $patient ? user_payload($patient) : null, 'csrf' => csrf_token(), 'unread_messages' => $unread]);
}

// POST /session = log in
function session_create(array $p, array $in): void
{
    $email    = strtolower(trim((string) ($in['email'] ?? '')));
    $password = (string) ($in['password'] ?? '');

    // Slow down password guessing: 5 failures locks this session for 5 minutes.
    if (($_SESSION['login_locked_until'] ?? 0) > time()) {
        fail(429, 'Too many attempts. Please wait a few minutes and try again.');
    }

    $stmt = db()->prepare('SELECT patient_id, full_name, email, password_hash FROM patients WHERE email = ?');
    $stmt->execute([$email]);
    $patient = $stmt->fetch();

    // Same check and same message whether the email exists or not.
    $hash  = $patient['password_hash'] ?? password_hash('not-a-real-password', PASSWORD_DEFAULT);
    $valid = password_verify($password, $hash) && $patient && $patient['password_hash'];

    if (!$valid) {
        $_SESSION['login_failures'] = ($_SESSION['login_failures'] ?? 0) + 1;
        if ($_SESSION['login_failures'] >= 5) {
            $_SESSION['login_locked_until'] = time() + 300;
            $_SESSION['login_failures'] = 0;
        }
        fail(401, 'Incorrect email or password.');
    }

    session_regenerate_id(true);
    unset($_SESSION['login_failures'], $_SESSION['login_locked_until']);
    $_SESSION['patient_id'] = (int) $patient['patient_id'];

    if (password_needs_rehash($patient['password_hash'], PASSWORD_DEFAULT)) {
        db()->prepare('UPDATE patients SET password_hash = ? WHERE patient_id = ?')
            ->execute([password_hash($password, PASSWORD_DEFAULT), $patient['patient_id']]);
    }

    out(['user' => user_payload($patient), 'csrf' => csrf_token()], 201);
}

// DELETE /session = log out
function session_delete(array $p, array $in): void
{
    $_SESSION = [];
    if (ini_get('session.use_cookies')) {
        $c = session_get_cookie_params();
        setcookie(session_name(), '', time() - 3600, $c['path'], $c['domain'], $c['secure'], $c['httponly']);
    }
    session_destroy();
    out(null, 204);
}

// POST /patients = register
function patient_create(array $p, array $in): void
{
    $first    = trim((string) ($in['first_name'] ?? ''));
    $last     = trim((string) ($in['last_name'] ?? ''));
    $email    = strtolower(trim((string) ($in['email'] ?? '')));
    $phone    = trim((string) ($in['phone'] ?? ''));
    $dob      = (string) ($in['dob'] ?? '');
    $password = (string) ($in['password'] ?? '');

    $errors = [];
    if ($first === '' || mb_strlen($first) > 50)  $errors['first_name'] = 'Enter your first name.';
    if ($last === ''  || mb_strlen($last) > 50)   $errors['last_name']  = 'Enter your last name.';
    if (!filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($email) > 100) $errors['email'] = 'Enter a valid email address.';
    if (!preg_match('/^[0-9+\s\-]{8,15}$/', $phone)) $errors['phone'] = 'Enter a valid phone number.';
    if (!valid_date($dob) || $dob > date('Y-m-d')) $errors['dob'] = 'Enter a valid date of birth.';
    if (strlen($password) < 8) $errors['password'] = 'Password must be at least 8 characters.';
    if ($errors) fail(422, 'Please check the highlighted fields.', $errors);

    $pdo = db();
    $exists = $pdo->prepare('SELECT 1 FROM patients WHERE email = ?');
    $exists->execute([$email]);
    if ($exists->fetch()) {
        fail(409, 'An account with that email already exists. Try logging in instead.', ['email' => 'Email already registered.']);
    }

    $pdo->beginTransaction();
    $pdo->prepare('INSERT INTO patients (full_name, email, password_hash, phone, dob, blood_type, allergies) VALUES (?, ?, ?, ?, ?, NULL, NULL)')
        ->execute([$first . ' ' . $last, $email, password_hash($password, PASSWORD_DEFAULT), $phone, $dob]);
    $id = (int) $pdo->lastInsertId();
    $pdo->prepare('INSERT INTO notification_preferences (patient_id) VALUES (?)')->execute([$id]);
    $pdo->commit();

    created('/api/patients/' . $id, ['id' => $id]);
}

// POST /password-resets = ask for a reset link
function reset_request(array $p, array $in): void
{
    $email = strtolower(trim((string) ($in['email'] ?? '')));
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) fail(422, 'Enter a valid email address.');

    $stmt = db()->prepare('SELECT patient_id FROM patients WHERE email = ?');
    $stmt->execute([$email]);
    $id = $stmt->fetchColumn();

    if ($id) {
        $token = bin2hex(random_bytes(32));
        db()->prepare('UPDATE password_resets SET used = 1 WHERE patient_id = ? AND used = 0')->execute([$id]);
        db()->prepare('INSERT INTO password_resets (patient_id, token_hash, expires_at) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 1 HOUR))')
            ->execute([$id, hash('sha256', $token)]);
        // No email server yet: the link is written to the PHP server's log (the terminal running php -S).
        $origin = $_SERVER['HTTP_ORIGIN'] ?? 'http://127.0.0.1:8000';
        error_log("[VaxAssist] Password reset link for $email: $origin/reset-password.html?token=$token");
    }

    // The same answer whether or not the email exists, so nobody can check who has an account.
    out(null, 202);
}

// PUT /password-resets/{token} = use the link to set a new password
function reset_complete(array $p, array $in): void
{
    $token = (string) $p['token'];
    $new   = (string) ($in['password'] ?? '');
    if (!preg_match('/^[a-f0-9]{64}$/', $token)) fail(400, 'This reset link is not valid.');
    if (!strong_password($new)) fail(422, 'Your new password needs at least 8 characters, with letters and numbers.');

    $stmt = db()->prepare('SELECT reset_id, patient_id FROM password_resets WHERE token_hash = ? AND used = 0 AND expires_at > NOW()');
    $stmt->execute([hash('sha256', $token)]);
    $row = $stmt->fetch();
    if (!$row) fail(400, 'This reset link has expired or was already used. Please request a new one.');

    db()->beginTransaction();
    db()->prepare('UPDATE patients SET password_hash = ? WHERE patient_id = ?')->execute([password_hash($new, PASSWORD_DEFAULT), $row['patient_id']]);
    db()->prepare('UPDATE password_resets SET used = 1 WHERE patient_id = ?')->execute([$row['patient_id']]);
    db()->commit();

    out(null, 204);
}
