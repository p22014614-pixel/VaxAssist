<?php
require_once 'db.php';

$message = "";
$error = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $firstName = trim($_POST['firstName']);
    $lastName  = trim($_POST['lastName']);
    $email     = trim($_POST['email']);
    $phone     = trim($_POST['phone']);
    $dob       = $_POST['dob'];
    $password  = $_POST['password'];

    // Check if email already exists
    $checkStmt = $conn->prepare("SELECT id FROM site_users WHERE email = ?");
    $checkStmt->bind_param("s", $email);
    $checkStmt->execute();
    $checkStmt->store_result();

    if ($checkStmt->num_rows > 0) {
        $error = "An account with this email address already exists.";
    } else {
        // Securely hash the password
        $hashedPassword = password_hash($password, PASSWORD_DEFAULT);

        // Insert new user into database
        $stmt = $conn->prepare("INSERT INTO site_users (first_name, last_name, email, phone, dob, password_hash) VALUES (?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("ssssss", $firstName, $lastName, $email, $phone, $dob, $hashedPassword);

        if ($stmt->execute()) {
            $message = "Account created successfully! Redirecting to login...";
            header("refresh:2;url=login.php");
        } else {
            $error = "Registration failed. Please try again later.";
        }
        $stmt->close();
    }
    $checkStmt->close();
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HealthCare Clinic | Create Account</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { font-family: Arial, sans-serif; background-color: #f8fbfc; color: #183642; min-height: 100vh; display: flex; flex-direction: column; }
        main { flex: 1; display: flex; align-items: center; padding: 60px 0; }
        .register-wrap { max-width: 480px; margin: 0 auto; }
        .register-icon { width: 64px; height: 64px; border-radius: 20px; background: #e8f5f6; display: flex; align-items: center; justify-content: center; font-size: 1.9rem; margin: 0 auto 24px; }
        .register-wrap h1 { font-size: 2rem; font-weight: 700; letter-spacing: -1px; }
        .register-card { background: white; border: 1px solid #e7edef; border-radius: 16px; padding: 32px; }
        .form-label { font-size: 0.9rem; font-weight: 600; }
        .form-control { border: 1px solid #dbe5e8; border-radius: 8px; padding: 12px 14px; color: #183642; }
        .toggle-pw { border: 1px solid #dbe5e8; border-left: none; background: white; color: #52676e; font-size: 0.85rem; border-radius: 0 8px 8px 0; padding: 0 16px; }
        .appointment-btn { background-color: #167d8d; color: white; border: none; padding: 10px 20px; border-radius: 8px; }
        .appointment-btn:hover { background-color: #126a78; color: white; }
        .text-link { color: #167d8d; text-decoration: none; }
        footer { background-color: #183642; color: #c9d7da; }
        footer span { color: #7fc9d2; }
    </style>
</head>
<body>

    <main>
        <div class="container">
            <div class="register-wrap">
                <div class="text-center mb-4">
                    <div class="register-icon">💉</div>
                    <h1 class="mb-2">Create your account</h1>
                    <p class="text-secondary mb-0">Get a personalised vaccination schedule for you and your family.</p>
                </div>

                <div class="register-card">

                    <?php if (!empty($message)): ?>
                        <div class="alert alert-success" role="alert"><?php echo $message; ?></div>
                    <?php endif; ?>

                    <?php if (!empty($error)): ?>
                        <div class="alert alert-danger" role="alert"><?php echo $error; ?></div>
                    <?php endif; ?>

                    <form action="register.php" method="POST" id="registerForm">
                        <div class="row g-3 mb-3">
                            <div class="col-sm-6">
                                <label for="firstName" class="form-label">First name</label>
                                <input type="text" name="firstName" class="form-control" id="firstName" required>
                            </div>
                            <div class="col-sm-6">
                                <label for="lastName" class="form-label">Last name</label>
                                <input type="text" name="lastName" class="form-control" id="lastName" required>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label for="email" class="form-label">Email address</label>
                            <input type="email" name="email" class="form-control" id="email" required>
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-sm-6">
                                <label for="phone" class="form-label">Phone number</label>
                                <input type="tel" name="phone" class="form-control" id="phone" required>
                            </div>
                            <div class="col-sm-6">
                                <label for="dob" class="form-label">Date of birth</label>
                                <input type="date" name="dob" class="form-control" id="dob" required>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label for="password" class="form-label">Password</label>
                            <div class="input-group">
                                <input type="password" name="password" class="form-control" id="password" minlength="8" required>
                                <button type="button" class="toggle-pw" id="togglePw">Show</button>
                            </div>
                        </div>

                        <div class="form-check mb-4">
                            <input class="form-check-input" type="checkbox" id="terms" required>
                            <label class="form-check-label small text-secondary" for="terms">
                                I agree to the <a href="#" class="text-link">Terms of Service</a>.
                            </label>
                        </div>

                        <button type="submit" class="btn appointment-btn w-100">Create account</button>
                    </form>
                </div>

                <p class="text-center text-secondary small mt-4 mb-0">
                    Already have an account? <a href="login.php" class="text-link">Log in</a>
                </p>
            </div>
        </div>
    </main>

    <footer class="text-center p-4">
        <p class="mb-0">© 2026 <span>HealthCare Clinic</span> | All Rights Reserved</p>
    </footer>

    <script>
        const password = document.getElementById("password");
        document.getElementById("togglePw").addEventListener("click", function () {
            const hidden = password.type === "password";
            password.type = hidden ? "text" : "password";
            this.textContent = hidden ? "Hide" : "Show";
        });
    </script>
</body>
</html>