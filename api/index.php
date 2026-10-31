<?php
// Routes browser API requests to the shared login, patient, appointment, and messaging handlers.
// Front controller: every request to /api/... comes through here.
// METHOD + path -> handler, using real HTTP verbs on named resources.
require __DIR__ . '/lib.php';

foreach (glob(__DIR__ . '/handlers/*.php') as $file) {
    require $file;
}

$routes = [
    // session and accounts
    ['GET',    '/session',                          'session_show'],
    ['POST',   '/session',                          'session_create'],
    ['DELETE', '/session',                          'session_delete'],
    ['POST',   '/patients',                         'patient_create'],
    ['POST',   '/password-resets',                  'reset_request'],
    ['PUT',    '/password-resets/{token}',          'reset_complete'],

    // public reference data
    ['GET',    '/doctors',                          'doctors_list'],
    ['GET',    '/doctors/{id}/slots',               'doctor_slots'],
    ['GET',    '/vaccines',                         'vaccines_list'],
    ['GET',    '/destinations',                     'destinations_list'],
    ['GET',    '/child-schedule',                   'schedule_list'],

    // the logged-in patient
    ['GET',    '/me',                               'me_show'],
    ['PUT',    '/me',                               'me_update'],
    ['GET',    '/me/health',                        'health_show'],
    ['PUT',    '/me/health',                        'health_update'],
    ['PUT',    '/me/password',                      'password_update'],
    ['GET',    '/children',                         'children_list'],
    ['POST',   '/children',                         'children_create'],
    ['DELETE', '/children/{id}',                    'children_delete'],

    ['GET',    '/appointments',                     'appointments_list'],
    ['POST',   '/appointments',                     'appointments_create'],
    ['PATCH',  '/appointments/{id}',                'appointments_update'],
    ['PUT',    '/appointments/{id}/review',         'review_put'],
    ['GET',    '/reviews',                          'reviews_list'],

    ['GET',    '/vaccination-records',              'records_list'],
    ['GET',    '/payments',                         'payments_list'],
    ['PATCH',  '/payments/{id}',                    'payments_update'],

    ['GET',    '/notifications',                    'notifications_list'],
    ['PATCH',  '/notifications',                    'notifications_update_all'],
    ['PATCH',  '/notifications/{id}',               'notifications_update'],
    ['DELETE', '/notifications/{id}',               'notifications_delete'],
    ['GET',    '/notification-preferences',         'preferences_show'],
    ['PUT',    '/notification-preferences',         'preferences_update'],

    ['GET',    '/precheck-forms',                   'precheck_list'],
    ['POST',   '/precheck-forms',                   'precheck_create'],

    ['GET',    '/conversations',                    'conversations_list'],
    ['GET',    '/conversations/{id}/messages',      'messages_list'],
    ['POST',   '/conversations/{id}/messages',      'messages_create'],
    ['PATCH',  '/conversations/{id}/messages',      'messages_mark_read'],
];

$method = $_SERVER['REQUEST_METHOD'];
$path = rtrim(preg_replace('#^.*?/api#', '', parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH)), '/') ?: '/';

$allowed = [];
foreach ($routes as [$verb, $pattern, $handler]) {
    $regex = '#^' . preg_replace('#\{(\w+)\}#', '(?P<$1>[^/]+)', $pattern) . '$#';
    if (!preg_match($regex, $path, $m)) continue;

    $allowed[] = $verb;
    if ($verb !== $method) continue;

    $params = array_filter($m, 'is_string', ARRAY_FILTER_USE_KEY);
    $input = [];
    if ($method !== 'GET') {
        $input = write_input();
    }
    $handler($params, $input);
    exit;
}

if ($allowed) {
    header('Allow: ' . implode(', ', array_unique($allowed)));
    fail(405, 'Method not allowed.');
}
fail(404, 'No such resource.');
