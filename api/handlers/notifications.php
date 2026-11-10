<?php
// Notifications, notification settings and the pre-consultation forms.

function notifications_list(array $p, array $in): void
{
    $patient = require_login();
    $stmt = db()->prepare('SELECT notification_id, type, title, body, action_url, action_label, is_read, 
        created_at FROM notifications WHERE patient_id = ? ORDER BY created_at DESC, notification_id DESC');
    $stmt->execute([$patient['patient_id']]);
    out(['notifications' => array_map(function ($n) {
        return [
            'id' => (int) $n['notification_id'], 
            'type' => strtolower($n['type']), 
            'title' => $n['title'], 
            'message' => (string) $n['body'],
            'action_url' => (string) $n['action_url'], 
            'action_label' => (string) $n['action_label'],
            'is_read' => (int) $n['is_read'], 
            'created_at' => iso_time($n['created_at']),
        ];
    }, $stmt->fetchAll())]);
}

// PATCH /notifications {is_read: true} = mark them all read
function notifications_update_all(array $p, array $in): void
{
    $patient = require_login();
    if (empty($in['is_read'])) fail(422, 'The only change allowed is marking notifications as read.');
    db()->prepare('UPDATE notifications SET is_read = 1 WHERE patient_id = ?')->execute([$patient['patient_id']]);
    out(null, 204);
}

// PATCH /notifications/{id} {is_read: true}
function notifications_update(array $p, array $in): void
{
    $patient = require_login();
    if (empty($in['is_read'])) fail(422, 'The only change allowed is marking a notification as read.');
    $stmt = db()->prepare('UPDATE notifications SET is_read = 1 WHERE notification_id = ? AND patient_id = ?');
    $stmt->execute([(int) $p['id'], $patient['patient_id']]);
    out(null, 204);
}

function notifications_delete(array $p, array $in): void
{
    $patient = require_login();
    $stmt = db()->prepare('DELETE FROM notifications WHERE notification_id = ? AND patient_id = ?');
    $stmt->execute([(int) $p['id'], $patient['patient_id']]);
    if ($stmt->rowCount() === 0) fail(404, 'Notification not found.');
    out(null, 204);
}

function preferences_show(array $p, array $in): void
{
    $patient = require_login();
    $fields = ['email_reminders', 'sms_reminders', 'booster_alerts', 'clinic_news'];
    $stmt = db()->prepare('SELECT email_reminders, sms_reminders, booster_alerts, clinic_news FROM notification_preferences WHERE patient_id = ?');
    $stmt->execute([$patient['patient_id']]);
    $row = $stmt->fetch() ?: array_fill_keys($fields, 1);
    out(['preferences' => array_map('boolval', $row)]);
}

function preferences_update(array $p, array $in): void
{
    $patient = require_login();
    $vals = [];
    foreach (['email_reminders', 'sms_reminders', 'booster_alerts', 'clinic_news'] as $f) $vals[] = empty($in[$f]) ? 0 : 1;
    db()->prepare(
        'INSERT INTO notification_preferences (patient_id, email_reminders, sms_reminders, booster_alerts, clinic_news) VALUES (?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE email_reminders = VALUES(email_reminders), sms_reminders = VALUES(sms_reminders),
                                 booster_alerts = VALUES(booster_alerts), clinic_news = VALUES(clinic_news)'
    )->execute(array_merge([$patient['patient_id']], $vals));
    out(null, 204);
}

function precheck_list(array $p, array $in): void
{
    $patient = require_login();
    $stmt = db()->prepare(
        'SELECT f.*, v.name vaccine, c.first_name child_name FROM precheck_forms f
           LEFT JOIN vaccines v ON v.vaccine_id = f.vaccine_id LEFT JOIN children c ON c.child_id = f.child_id
          WHERE f.patient_id = ? ORDER BY f.submitted_at DESC, f.form_id DESC LIMIT 20'
    );
    $stmt->execute([$patient['patient_id']]);
    out(['forms' => array_map(function ($f) {
        return ['patient_name' => $f['child_name'] ? $f['child_name'] . ' (child)' : 'Myself', 'vaccine' => (string) $f['vaccine'],
                'submitted_at' => iso_time($f['submitted_at'])];
    }, $stmt->fetchAll())]);
}

function precheck_create(array $p, array $in): void
{
    $patient = require_login();
    $pid = (int) $patient['patient_id'];
    $pdo = db();
    $answers = (array) ($in['answers'] ?? []);

    $who = (string) ($in['patient'] ?? 'self');
    $childId = null;
    if ($who !== 'self') {
        $own = $pdo->prepare('SELECT child_id FROM children WHERE child_id = ? AND patient_id = ?');
        $own->execute([(int) str_replace('child-', '', $who), $pid]);
        $childId = $own->fetchColumn();
        if (!$childId) fail(422, 'Please choose who the form is for.');
    }

    foreach (['fever', 'reaction', 'immune', 'recent', 'bleeding'] as $q) {
        if (!in_array($answers[$q] ?? null, ['yes', 'no'], true)) fail(422, 'Please answer every health question.');
    }
    if ($childId === null && !in_array($answers['pregnant'] ?? null, ['yes', 'no'], true)) fail(422, 'Please answer every health question.');

    $vaccineId = null;
    if (!empty($in['vaccine'])) {
        $v = $pdo->prepare('SELECT vaccine_id FROM vaccines WHERE name = ?');
        $v->execute([(string) $in['vaccine']]);
        $vaccineId = $v->fetchColumn() ?: null;
    }

    // If this person already has an upcoming visit, attach the form to it so the doctor sees it.
    $visit = $pdo->prepare(
        "SELECT appointment_id FROM appointments
          WHERE patient_id = ? AND child_id <=> ? AND status = 'Scheduled' AND appointment_date >= CURDATE()
            AND (? IS NULL OR vaccine_id = ?)
          ORDER BY appointment_date, appointment_time LIMIT 1"
    );
    $visit->execute([$pid, $childId ?: null, $vaccineId, $vaccineId]);
    $appointmentId = $visit->fetchColumn() ?: null;

    $yn = function ($k) use ($answers) { return ($answers[$k] ?? '') === 'yes' ? 1 : 0; };
    $pdo->prepare(
        'INSERT INTO precheck_forms (patient_id, appointment_id, child_id, vaccine_id, has_fever, severe_reaction, weak_immune_system,
                pregnant_or_breastfeeding, recent_vaccine, bleeding_disorder, allergies, medications, notes)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
    )->execute([$pid, $appointmentId, $childId ?: null, $vaccineId, $yn('fever'), $yn('reaction'), $yn('immune'),
        $childId === null ? $yn('pregnant') : null, $yn('recent'), $yn('bleeding'),
        text_in($in['allergies'] ?? '', 300) ?: null, text_in($in['medications'] ?? '', 300) ?: null, text_in($in['notes'] ?? '', 500) ?: null]);
    $formId = (int) $pdo->lastInsertId();
    created('/api/precheck-forms/' . $formId, ['id' => $formId]);
}
