<?php
// Development router for PHP's built-in server:
//   php -S 127.0.0.1:8000 router.php
// Sends /api/... to the API front controller and serves everything else as normal files.
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
if (strpos($path, '/api/') === 0 && !is_file(__DIR__ . $path)) {
    require __DIR__ . '/api/index.php';
    return true;
}
// A page that does not exist gets the site's own 404 page instead of PHP's plain text.
$file = __DIR__ . $path;
if ($path !== '/' && !is_file($file) && !is_dir($file) && is_file(__DIR__ . '/404.html')) {
    http_response_code(404);
    header('Content-Type: text/html; charset=utf-8');
    readfile(__DIR__ . '/404.html');
    return true;
}
return false;
