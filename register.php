<?php
declare(strict_types=1);

require __DIR__ . '/db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    exit('Please submit the registration form.');
}

// Accept either separate first/last names or one full name.
$firstName = trim((string) ($_POST['firstName'] ?? ''));
$lastName = trim((string) ($_POST['lastName'] ?? ''));
$fullName = trim((string) ($_POST['fullName'] ?? ''));

if ($firstName === '' && $fullName !== '') {
    $nameParts = preg_split('/\s+/', $fullName, 2);
    $firstName = $nameParts[0] ?? '';
    $lastName = $nameParts[1] ?? '';
}

$email = strtolower(trim((string) ($_POST['email'] ?? '')));
$phone = trim((string) ($_POST['phone'] ?? ''));
$dob = trim((string) ($_POST['dob'] ?? ''));
$password = (string) ($_POST['password'] ?? '');
$confirmPassword = (string) ($_POST['confirmPassword'] ?? $password);

// Only require terms if the form includes a terms checkbox.
$hasTermsField = array_key_exists('terms', $_POST);
$termsAccepted = !$hasTermsField || $_POST['terms'] === 'accepted';

if (
    $firstName === '' ||
    $lastName === '' ||
    !filter_var($email, FILTER_VALIDATE_EMAIL) ||
    strlen($password) < 8 ||
    $password !== $confirmPassword ||
    !$termsAccepted
) {
    http_response_code(400);
    exit(
        'Please check your name, email, password, and terms acceptance. ' .
        'Passwords must be at least 8 characters and match.'
    );
}

// Validate date of birth only if the form supplied one.
if ($dob !== '') {
    $date = DateTime::createFromFormat('!Y-m-d', $dob);

    if (
        !$date ||
        $date->format('Y-m-d') !== $dob ||
        $date > new DateTime('today')
    ) {
        http_response_code(400);
        exit('Please enter a valid date of birth.');
    }
} else {
    $dob = null;
}

$passwordHash = password_hash($password, PASSWORD_DEFAULT);

try {
    $statement = $pdo->prepare(
        'INSERT INTO users
            (first_name, last_name, email, phone, dob, password_hash, terms_accepted)
         VALUES
            (:first_name, :last_name, :email, :phone, :dob, :password_hash, :terms_accepted)'
    );

    $statement->execute([
        ':first_name' => $firstName,
        ':last_name' => $lastName,
        ':email' => $email,
        ':phone' => $phone !== '' ? $phone : null,
        ':dob' => $dob,
        ':password_hash' => $passwordHash,
        ':terms_accepted' => $hasTermsField ? 1 : 0,
    ]);

    header('Location: login.html');
    exit; 

} catch (PDOException $exception) {
    if ($exception->getCode() === '23000') {
        http_response_code(409);
        exit('An account with that email already exists. <a href="signup.html">Go back</a>');
    }

    error_log($exception->getMessage());
    http_response_code(500);
    exit('Account creation failed. Check the database setup and try again.');
}