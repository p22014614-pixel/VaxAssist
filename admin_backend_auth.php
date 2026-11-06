<?php
declare(strict_types=1);

// Shared bootstrap for legacy admin dashboard endpoints: use the API session and unified database.
require_once __DIR__ . '/api/lib.php';

if (empty($_SESSION['admin_id'])) {
    http_response_code(401);
    echo json_encode(['error' => 'Please sign in as an administrator.']);
    exit;
}

$pdo = db();