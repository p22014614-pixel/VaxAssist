<?php
// Messages from the public Contact Us form.

function contact_create(array $p, array $in): void
{
    $name = text_in($in['name'] ?? '', 100);
    $email = text_in($in['email'] ?? '', 100);
    $subject = text_in($in['subject'] ?? '', 100);
    $message = text_in($in['message'] ?? '', 1000);

    $subjects = ['General question', 'Booking help', 'Vaccines and services', 'Payments and receipts', 'Feedback', 'Something else'];

    $bad = [];
    if (mb_strlen($name) < 2) $bad['name'] = 'Enter your name.';
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) $bad['email'] = 'Enter a valid email address.';
    if (!in_array($subject, $subjects, true)) $bad['subject'] = 'Choose a subject.';
    if (mb_strlen($message) < 10) $bad['message'] = 'Please write at least 10 characters.';
    if ($bad) fail(422, reset($bad), $bad);

    $ip = $_SERVER['REMOTE_ADDR'] ?? '';
    $pdo = db();

    $recent = $pdo->prepare('SELECT COUNT(*) FROM contact_messages WHERE ip_address = ? AND created_at > NOW() - INTERVAL 1 HOUR');
    $recent->execute([$ip]);
    if ((int) $recent->fetchColumn() >= 5) {
        fail(429, 'You have sent a few messages already. Please try again later.');
    }

    $patient = current_patient();
    $pdo->prepare('INSERT INTO contact_messages (patient_id, name, email, subject, message, ip_address) VALUES (?, ?, ?, ?, ?, ?)')
        ->execute([$patient ? $patient['patient_id'] : null, $name, $email, $subject, $message, $ip]);

    created('/api/contact-messages/' . (int) $pdo->lastInsertId(), ['ok' => true]);
}
