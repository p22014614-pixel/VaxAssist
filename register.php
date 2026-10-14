<?php
require __DIR__ . "/db.php";

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    http_response_code(405);
    exit("Please submit the registration form.");
}

$firstName = trim($_POST["firstName"] ?? "");
$lastName = trim($_POST["lastName"] ?? "");
$email = strtolower(trim($_POST["email"] ?? ""));
$phone = trim($_POST["phone"] ?? "");
$dob = trim($_POST["dob"] ?? "");
$password = $_POST["password"] ?? "";
$confirmPassword = $_POST["confirmPassword"] ?? "";
$termsAccepted = ($_POST["terms"] ?? "") === "accepted";

if (
    $firstName === "" ||
    $lastName === "" ||
    !filter_var($email, FILTER_VALIDATE_EMAIL) ||
    $phone === "" ||
    $dob === "" ||
    strlen($password) < 8 ||
    $password !== $confirmPassword ||
    !$termsAccepted
) {
    http_response_code(400);
    exit("Please check your details, password, and terms acceptance.");
}

$date = DateTime::createFromFormat("!Y-m-d", $dob);

if (
    !$date ||
    $date->format("Y-m-d") !== $dob ||
    $date > new DateTime("today")
) {
    http_response_code(400);
    exit("Please enter a valid date of birth.");
}

$passwordHash = password_hash($password, PASSWORD_DEFAULT);

try {
    $stmt = $pdo->prepare(
        "INSERT INTO users
            (first_name, last_name, email, phone, dob, password_hash, terms_accepted)
         VALUES (?, ?, ?, ?, ?, ?, ?)"
    );

    $stmt->execute([
        $firstName,
        $lastName,
        $email,
        $phone,
        $dob,
        $passwordHash,
        1
    ]);

    echo "Database: " . htmlspecialchars(
        $pdo->query("SELECT DATABASE()")->fetchColumn()
        );
    echo "<br>Rows inserted: " . $stmt->rowCount();
    echo "<br>Total users: " .
        (int) $pdo->query("SELECT COUNT(*) FROM users")->fetchColumn();
    exit;
} catch (PDOException $e) {
    if ($e->getCode() === "23000") {
        http_response_code(409);
        exit("That email may already be registered.");
    }

    error_log($e->getMessage());
    http_response_code(500);
    exit("Account creation failed. Check the database connection and table.");
}