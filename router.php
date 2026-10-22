<?php
// Development router for PHP's built-in server:
//   php -S 127.0.0.1:8000 router.php
// Sends /api/... to the API front controller and serves everything else as normal files.
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
if (strpos($path, '/api/') === 0 && !is_file(__DIR__ . $path)) {
    require __DIR__ . '/api/index.php';
    return true;
}
return false;
