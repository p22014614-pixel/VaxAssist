<?php
// Appointments: list, book, reschedule, cancel and reviews.

// Lists the patient's appointments (GET /appointments).
function appointments_list(array $p, array $in): void
{
    $patient = require_login();
    sync_clinic_changes((int) $patient['patient_id']);
    $stmt = db()->prepare(
        "SELECT a.appointment_id, a.doctor_id, d.first_name dfirst, d.last_name dlast, d.specialization,
                v.name vaccine, a.appointment_date, a.appointment_time, a.time_slot, a.child_id, c.first_name child_name,
                a.symptoms_notes, a.status,
                EXISTS (SELECT 1 FROM leave_requests l WHERE l.doctor_id = a.doctor_id AND l.status = 'Approved'
                          AND a.appointment_date BETWEEN l.start_date AND l.end_date) AS on_leave
           FROM appointments a
           JOIN doctors d ON d.doctor_id = a.doctor_id
           LEFT JOIN vaccines v ON v.vaccine_id = a.vaccine_id
           LEFT JOIN children c ON c.child_id = a.child_id
          WHERE a.patient_id = ?
          ORDER BY a.appointment_date DESC, a.appointment_time DESC"
    );
    $stmt->execute([$patient['patient_id']]);
    $status = ['Scheduled' => 'booked', 'Confirmed' => 'booked', 'Completed' => 'completed', 'Cancelled' => 'cancelled', 'Missed' => 'missed'];

    out(['appointments' => array_map(function ($r) use ($status) {
        return [
            'id' => (int) $r['appointment_id'], 'doctor_id' => (int) $r['doctor_id'],
            'doctor_name' => 'Dr. ' . $r['dfirst'] . ' ' . $r['dlast'], 'specialty' => $r['specialization'],
            'vaccine_name' => $r['vaccine'] ?: 'Consultation',
            'appointment_date' => $r['appointment_date'],
            'appointment_time' => visit_time($r),
            'patient_type' => $r['child_id'] ? 'child' : 'self', 'child_name' => (string) $r['child_name'],
            'notes' => (string) $r['symptoms_notes'], 'status' => $status[$r['status']] ?? 'booked',
            'doctor_on_leave' => in_array($r['status'], ['Scheduled', 'Confirmed'], true) && (bool) $r['on_leave'],
        ];
    }, $stmt->fetchAll())]);
}

// Books an appointment (POST /appointments).
function appointments_create(array $p, array $in): void
{
    $patient = require_login();
    $pdo = db();
    $patientId = (int) $patient['patient_id'];

    $doctorId  = (int) ($in['doctor_id'] ?? 0);
    $vaccineId = (int) ($in['vaccine_id'] ?? 0);
    $date      = (string) ($in['appointment_date'] ?? '');
    $time      = (string) ($in['appointment_time'] ?? '');
    $forChild  = ($in['patient_type'] ?? 'self') === 'child';
    $notes     = text_in($in['notes'] ?? '', 500);

    $vaccine = $pdo->prepare('SELECT vaccine_id, name, price FROM vaccines WHERE vaccine_id = ?');
    $vaccine->execute([$vaccineId]);
    $vaccine = $vaccine->fetch();
    if (!$vaccine) fail(422, 'Please choose a vaccine or service.');

    $doctor = $pdo->prepare('SELECT 1 FROM doctors WHERE doctor_id = ?');
    $doctor->execute([$doctorId]);
    if (!$doctor->fetch()) fail(422, 'Please choose a doctor.');

    if (!valid_date($date) || $date < date('Y-m-d') || $date > date('Y-m-d', strtotime('+60 days'))) {
        fail(422, 'Choose a date within the next 60 days.');
    }
    if (!in_array($time, slot_times(), true)) fail(422, 'Please choose a time slot.');

    $childId = null;
    $newChild = null;
    if ($forChild) {
        $name = text_in($in['child_name'] ?? '', 50);
        $dob  = (string) ($in['child_dob'] ?? '');
        if ($name === '') fail(422, "Please enter your child's name.");
        $find = $pdo->prepare('SELECT child_id FROM children WHERE patient_id = ? AND LOWER(first_name) = LOWER(?)');
        $find->execute([$patientId, $name]);
        $childId = $find->fetchColumn() ?: null;
        if (!$childId) {
            if (!valid_date($dob) || $dob > date('Y-m-d') || $dob < date('Y-m-d', strtotime('-18 years'))) {
                fail(422, "Please enter your child's date of birth.");
            }
            $count = $pdo->prepare('SELECT COUNT(*) FROM children WHERE patient_id = ?');
            $count->execute([$patientId]);
            if ((int) $count->fetchColumn() >= 10) fail(422, 'You can save up to 10 children.');
            $newChild = [$name, $dob];
        }
    }

    $pdo->beginTransaction();
    $pdo->prepare('SELECT appointment_id FROM appointments WHERE doctor_id = ? AND appointment_date = ? FOR UPDATE')->execute([$doctorId, $date]);
    $free = false;
    foreach (available_slots($doctorId, $date) as $s) {
        if ($s['time'] === $time && $s['available']) $free = true;
    }
    if (!$free) {
        $pdo->rollBack();
        fail(409, 'Sorry, that time is no longer available. Please choose another slot.');
    }
    if (patient_busy($patientId, $date, $time)) {
        $pdo->rollBack();
        fail(409, 'You already have another appointment at that time. Please choose a different time.');
    }

    if ($newChild) {
        $pdo->prepare("INSERT INTO children (patient_id, first_name, dob, gender) VALUES (?, ?, ?, 'Other')")->execute([$patientId, $newChild[0], $newChild[1]]);
        $childId = (int) $pdo->lastInsertId();
    }

    $pdo->prepare(
        "INSERT INTO appointments (doctor_id, patient_id, child_id, vaccine_id, appointment_date, appointment_time, time_slot, status, symptoms_notes)
         VALUES (?, ?, ?, ?, ?, ?, ?, 'Scheduled', ?)"
    )->execute([$doctorId, $patientId, $childId, $vaccineId, $date, $time . ':00', time_window($time), $notes ?: null]);
    $appointmentId = (int) $pdo->lastInsertId();

    $form = $pdo->prepare(
        'SELECT form_id FROM precheck_forms
          WHERE patient_id = ? AND child_id <=> ? AND appointment_id IS NULL AND (vaccine_id IS NULL OR vaccine_id = ?)
            AND submitted_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
          ORDER BY submitted_at DESC, form_id DESC LIMIT 1'
    );
    $form->execute([$patientId, $childId, $vaccineId]);
    $formId = $form->fetchColumn();
    if ($formId) {
        $pdo->prepare('UPDATE precheck_forms SET appointment_id = ? WHERE form_id = ?')->execute([$appointmentId, $formId]);
    }

    $consult = (float) $pdo->query("SELECT price FROM vaccines WHERE name = 'Vaccine consultation'")->fetchColumn();
    $pdo->prepare("INSERT INTO payments (patient_id, appointment_id, receipt_no, status) VALUES (?, ?, ?, 'Pending')")
        ->execute([$patientId, $appointmentId, 'T' . bin2hex(random_bytes(8))]);
    $paymentId = (int) $pdo->lastInsertId();
    $pdo->prepare('UPDATE payments SET receipt_no = ? WHERE payment_id = ?')->execute([sprintf('VA-%s-%04d', date('Y'), $paymentId), $paymentId]);
    $item = $pdo->prepare('INSERT INTO payment_items (payment_id, label, amount) VALUES (?, ?, ?)');
    if ($vaccine['name'] !== 'Vaccine consultation') $item->execute([$paymentId, $vaccine['name'], $vaccine['price']]);
    $item->execute([$paymentId, 'Consultation fee', $consult]);

    add_notification($patientId, 'Appointment', 'Booking confirmed',
        'Your ' . $vaccine['name'] . ' appointment on ' . date('j M Y', strtotime($date)) . ' at ' . $time . ' has been confirmed.',
        'appointments.html', 'View appointment');
    add_doctor_notification($pdo, $doctorId, $patientId, $appointmentId, 'Appointment', 'New vaccination appointment booked',
        $vaccine['name'] . ' on ' . date('j M Y', strtotime($date)) . ' at ' . $time . '.');
    if ($formId) {
        add_doctor_notification($pdo, $doctorId, $patientId, $appointmentId, 'Announcement', 'Patient submitted a pre-check form',
            'A pre-check form is ready for review before the ' . $vaccine['name'] . ' appointment.');
    }
    $pdo->commit();

    created('/api/appointments/' . $appointmentId, ['id' => $appointmentId]);
}

// Reschedules or cancels an appointment (PATCH /appointments/{id}).
function appointments_update(array $p, array $in): void
{
    $patient = require_login();
    $pdo = db();
    $id = (int) $p['id'];

    $stmt = $pdo->prepare("SELECT a.doctor_id, a.appointment_date, a.appointment_time, a.time_slot, COALESCE(v.name, 'Consultation') vaccine
                             FROM appointments a LEFT JOIN vaccines v ON v.vaccine_id = a.vaccine_id
                            WHERE a.appointment_id = ? AND a.patient_id = ? AND a.status IN ('Scheduled', 'Confirmed')");
    $stmt->execute([$id, $patient['patient_id']]);
    $appt = $stmt->fetch();
    if (!$appt) fail(404, 'That appointment cannot be changed.');

    if (($in['status'] ?? '') === 'cancelled') {
        $pdo->beginTransaction();
        $pdo->prepare("UPDATE appointments SET status = 'Cancelled', cancel_reason = ? WHERE appointment_id = ?")
            ->execute([text_in($in['reason'] ?? '', 300) ?: null, $id]);
        $pdo->prepare("DELETE FROM payments WHERE appointment_id = ? AND status = 'Pending'")->execute([$id]);
        $pdo->prepare("UPDATE payments SET status = 'Refunded' WHERE appointment_id = ? AND status = 'Paid'")->execute([$id]);
        add_notification((int) $patient['patient_id'], 'Appointment', 'Appointment cancelled',
            'Your ' . $appt['vaccine'] . ' appointment on ' . date('j M Y', strtotime($appt['appointment_date'])) . ' has been cancelled.', 'appointments.html?tab=history', 'View history');
        add_doctor_notification($pdo, (int) $appt['doctor_id'], (int) $patient['patient_id'], $id, 'Appointment', 'Patient cancelled an appointment',
            'The patient cancelled the appointment scheduled for ' . date('j M Y', strtotime($appt['appointment_date'])) . '.');
        $pdo->commit();
        out(null, 204);
    }

    $date = (string) ($in['date'] ?? '');
    $time = (string) ($in['time'] ?? '');
    if (!valid_date($date) || $date < date('Y-m-d') || $date > date('Y-m-d', strtotime('+60 days'))) fail(422, 'Choose a date within the next 60 days.');
    if (!in_array($time, slot_times(), true)) fail(422, 'Please choose a time slot.');

    if ($date === $appt['appointment_date'] && visit_time($appt) === $time) {
        fail(422, 'That is already your appointment time. Please choose a different time.');
    }

    $pdo->beginTransaction();
    $pdo->prepare('SELECT appointment_id FROM appointments WHERE doctor_id = ? AND appointment_date = ? FOR UPDATE')->execute([$appt['doctor_id'], $date]);
    $free = false;
    foreach (available_slots((int) $appt['doctor_id'], $date, $id) as $s) {
        if ($s['time'] === $time && $s['available']) $free = true;
    }
    if (!$free) {
        $pdo->rollBack();
        fail(409, 'Sorry, that time is no longer available. Please choose another slot.');
    }
    if (patient_busy((int) $patient['patient_id'], $date, $time, $id)) {
        $pdo->rollBack();
        fail(409, 'You already have another appointment at that time. Please choose a different time.');
    }
    $pdo->prepare('UPDATE appointments SET appointment_date = ?, appointment_time = ?, time_slot = ? WHERE appointment_id = ?')
        ->execute([$date, $time . ':00', time_window($time), $id]);
    add_notification((int) $patient['patient_id'], 'Appointment', 'Appointment rescheduled',
        'Your appointment was moved to ' . date('j M Y', strtotime($date)) . ' at ' . $time . '.', 'appointments.html', 'View appointment');
    $oldTime = visit_time($appt) ?: 'time not set';
    add_doctor_notification($pdo, (int) $appt['doctor_id'], (int) $patient['patient_id'], $id, 'Appointment', 'Patient rescheduled an appointment',
        'Moved from ' . date('j M Y', strtotime($appt['appointment_date'])) . ' at ' . $oldTime . ' to ' . date('j M Y', strtotime($date)) . ' at ' . $time . '.');
    $pdo->commit();
    out(null, 204);
}

// Saves a rating for a completed visit (PUT).
function review_put(array $p, array $in): void
{
    $patient = require_login();
    $visit  = (int) $p['id'];
    $rating = (int) ($in['rating'] ?? 0);
    if ($rating < 1 || $rating > 5) fail(422, 'Please choose a star rating.');

    $own = db()->prepare("SELECT 1 FROM appointments WHERE appointment_id = ? AND patient_id = ? AND status = 'Completed'");
    $own->execute([$visit, $patient['patient_id']]);
    if (!$own->fetch()) fail(404, 'You can only review your own completed visits.');

    db()->prepare(
        'INSERT INTO reviews (appointment_id, patient_id, rating, comment) VALUES (?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE rating = VALUES(rating), comment = VALUES(comment)'
    )->execute([$visit, $patient['patient_id'], $rating, text_in($in['comment'] ?? '', 500) ?: null]);
    out(null, 204);
}

// Lists the patient's reviews (GET /reviews).
function reviews_list(array $p, array $in): void
{
    $patient = require_login();
    $mine = db()->prepare('SELECT appointment_id, rating, comment FROM reviews WHERE patient_id = ?');
    $mine->execute([$patient['patient_id']]);
    $reviews = new stdClass();
    foreach ($mine->fetchAll() as $r) {
        $reviews->{$r['appointment_id']} = ['rating' => (int) $r['rating'], 'comment' => (string) $r['comment']];
    }
    out(['reviews' => $reviews]);
}
