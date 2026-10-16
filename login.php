<?php
session_start();
require_once 'db.php';

$error = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email    = trim($_POST['email']);
    $password = $_POST['password'];

    // Look up user in database
    $stmt = $conn->prepare("SELECT id, first_name, password_hash FROM site_users WHERE email = ?");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $stmt->store_result();

    if ($stmt->num_rows > 0) {
        $stmt->bind_result($id, $firstName, $passwordHash);
        $stmt->fetch();

        // Verify hashed password
        if (password_verify($password, $passwordHash)) {
            $_SESSION['user_id'] = $id;
            $_SESSION['first_name'] = $firstName;
            
            // Successful login -> Redirect to dashboard
            header("Location: home.html");
            exit;
        } else {
            $error = "Invalid password. Please try again.";
        }
    } else {
        $error = "No user account found with that email address.";
    }
    $stmt->close();
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HealthCare Clinic | Patient Login</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { font-family: Arial, sans-serif; background-color: #f8fbfc; color: #183642; min-height: 100vh; display: flex; flex-direction: column; }
        main { flex: 1; display: flex; align-items: center; padding: 60px 0; }
        .login-wrap { max-width: 420px; margin: 0 auto; }
        .login-icon { width: 64px; height: 64px; border-radius: 20px; background: #e8f5f6; display: flex; align-items: center; justify-content: center; font-size: 1.9rem; margin: 0 auto 24px; }
        .login-wrap h1 { font-size: 2rem; font-weight: 700; letter-spacing: -1px; }
        .login-card { background: white; border: 1px solid #e7edef; border-radius: 16px; padding: 32px; }
        .form-label { font-size: 0.9rem; font-weight: 600; }
        .form-control { border: 1px solid #dbe5e8; border-radius: 8px; padding: 12px 14px; color: #183642; }
        .toggle-pw { border: 1px solid #dbe5e8; border-left: none; background: white; color: #52676e; font-size: 0.85rem; border-radius: 0 8px 8px 0; padding: 0 16px; }
        .appointment-btn { background-color: #167d8d; color: white; border: none; padding: 10px 20px; border-radius: 8px; }
        .appointment-btn:hover { background-color: #126a78; color: white; }
        .text-link { color: #24A0ED; text-decoration: none; }
        footer { background-color: #183642; color: #c9d7da; }
        footer span { color: #7fc9d2; }
    </style>
</head>
<body>

    <main>
        <div class="container">
            <div class="login-wrap">
                <div class="text-center mb-4">
                    <div class="login-icon">💉</div>
                    <h1 class="mb-2">Welcome back</h1>
                    <p class="text-secondary mb-0">Log in to view your vaccination schedule.</p>
                </div>

                <div class="login-card">

                    <?php if (!empty($error)): ?>
                        <div class="alert alert-danger" role="alert"><?php echo $error; ?></div>
                    <?php endif; ?>

                    <form action="login.php" method="POST" id="loginForm">
                        <div class="mb-3">
                            <label for="email" class="form-label">Email address</label>
                            <input type="email" name="email" class="form-control" id="email" required>
                        </div>

                        <div class="mb-3">
                            <label for="password" class="form-label">Password</label>
                            <div class="input-group">
                                <input type="password" name="password" class="form-control" id="password" required>
                                <button type="button" class="toggle-pw" id="togglePw">Show</button>
                            </div>
                        </div>

                        <button type="submit" class="btn appointment-btn w-100 mt-2">Log in</button>
                    </form>
                </div>

                <p class="text-center text-secondary small mt-4 mb-0">
                    New here? <a href="register.php" class="text-link">Create an account</a>
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