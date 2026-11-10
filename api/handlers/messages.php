<?php
// Conversations between the patient and a doctor (the team's `messages` table).

function doctor_label(array $d): string
{
    return 'Dr. ' . $d['first_name'] . ' ' . $d['last_name'];
}

function conversations_list(array $p, array $in): void
{
    $patient = require_login();
    $stmt = db()->prepare(
        'SELECT m.message_id, m.doctor_id, m.sender_type, m.message_text, m.is_read, m.created_at,
                d.first_name, d.last_name, d.specialization
           FROM messages m JOIN doctors d ON d.doctor_id = m.doctor_id
          WHERE m.patient_id = ? ORDER BY m.created_at, m.message_id'
    );
    $stmt->execute([$patient['patient_id']]);

    $threads = [];
    foreach ($stmt->fetchAll() as $m) {
        $id = (int) $m['doctor_id'];
        $threads[$id] = [
            'doctor_id' => $id, 'doctor_name' => doctor_label($m), 'specialty' => $m['specialization'],
            'last_text' => mb_substr($m['message_text'], 0, 80), 'last_time' => iso_time($m['created_at']), 'last_sender' => $m['sender_type'],
            'unread' => ($threads[$id]['unread'] ?? 0) + ($m['sender_type'] === 'doctor' && !$m['is_read'] ? 1 : 0),
        ];
    }
    usort($threads, function ($a, $b) { return strcmp($b['last_time'], $a['last_time']); });
    out(['conversations' => array_values($threads)]);
}

// GET /conversations/{doctor}/messages?after=ID  (reading never changes anything)
function messages_list(array $p, array $in): void
{
    $patient = require_login();
    $doctorId = (int) $p['id'];
    $after = (int) ($_GET['after'] ?? 0);

    $doc = db()->prepare('SELECT doctor_id, first_name, last_name, specialization FROM doctors WHERE doctor_id = ?');
    $doc->execute([$doctorId]);
    $doctor = $doc->fetch();
    if (!$doctor) fail(404, 'Doctor not found.');

    $stmt = db()->prepare(
        'SELECT message_id, sender_type, message_text, created_at FROM messages
          WHERE patient_id = ? AND doctor_id = ? AND message_id > ? ORDER BY created_at, message_id'
    );
    $stmt->execute([$patient['patient_id'], $doctorId, $after]);

    out([
        'doctor' => ['id' => (int) $doctor['doctor_id'], 'name' => doctor_label($doctor), 'specialty' => $doctor['specialization']],
        'messages' => array_map(function ($m) {
            return ['id' => (int) $m['message_id'], 'sender' => $m['sender_type'], 'text' => $m['message_text'], 'created_at' => iso_time($m['created_at'])];
        }, $stmt->fetchAll()),
    ]);
}

// POST /conversations/{doctor}/messages
function messages_create(array $p, array $in): void
{
    $patient = require_login();
    $pid = (int) $patient['patient_id'];
    $pdo = db();
    $doctorId = (int) $p['id'];
    $text = trim(preg_replace('/[\x00-\x08\x0B\x0C\x0E-\x1F]/', '', (string) ($in['text'] ?? '')));

    if ($text === '') fail(422, 'Please type a message.');
    if (mb_strlen($text) > 1000) fail(422, 'Messages can be up to 1000 characters.');

    $doc = $pdo->prepare('SELECT 1 FROM doctors WHERE doctor_id = ?');
    $doc->execute([$doctorId]);
    if (!$doc->fetch()) fail(404, 'Doctor not found.');

    // Stop message flooding: 20 messages a minute is plenty for a chat.
    $recent = $pdo->prepare("SELECT COUNT(*) FROM messages WHERE patient_id = ? AND sender_type = 'patient' AND created_at > DATE_SUB(NOW(), INTERVAL 1 MINUTE)");
    $recent->execute([$pid]);
    if ((int) $recent->fetchColumn() >= 20) fail(429, 'You are sending messages too fast. Please wait a moment.');

    // is_read = 0 means "the doctor has not read it yet".
    $pdo->prepare("INSERT INTO messages (doctor_id, patient_id, sender_type, message_text, is_read) VALUES (?, ?, 'patient', ?, 0)")
        ->execute([$doctorId, $pid, $text]);
    $id = (int) $pdo->lastInsertId();
    add_doctor_notification($pdo, $doctorId, $pid, null, 'Announcement', 'New patient message', $text);

    $row = $pdo->prepare('SELECT created_at FROM messages WHERE message_id = ?');
    $row->execute([$id]);
    created('/api/conversations/' . $doctorId . '/messages/' . $id,
        ['message' => ['id' => $id, 'sender' => 'patient', 'text' => $text, 'created_at' => iso_time($row->fetchColumn())]]);
}

// PATCH /conversations/{doctor}/messages {is_read: true} = I have read the doctor's messages
function messages_mark_read(array $p, array $in): void
{
    $patient = require_login();
    if (empty($in['is_read'])) fail(422, 'The only change allowed is marking messages as read.');
    db()->prepare("UPDATE messages SET is_read = 1 WHERE patient_id = ? AND doctor_id = ? AND sender_type = 'doctor' AND is_read = 0")
        ->execute([$patient['patient_id'], (int) $p['id']]);
    out(null, 204);
}
