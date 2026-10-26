<?php
// Returns analytics and login-time updates belonging to the authenticated doctor.
require __DIR__ . '/doctor_backend_auth.php';

// Build appointment metrics and the monthly trend for this doctor's dashboard.
try {
    $summary = $conn->prepare("SELECT
        COALESCE(SUM(appointment_date = CURRENT_DATE() AND status = 'Scheduled'), 0) AS today,
        COALESCE(SUM(appointment_date > CURRENT_DATE() AND appointment_date <= DATE_ADD(CURRENT_DATE(), INTERVAL 7 DAY) AND status = 'Scheduled'), 0) AS next_seven_days,
        COALESCE(SUM(appointment_date >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01') AND appointment_date < DATE_ADD(LAST_DAY(CURRENT_DATE()), INTERVAL 1 DAY) AND status = 'Completed'), 0) AS completed_month
        FROM appointments WHERE doctor_id = ?");
    $summary->bind_param('i', $doctor_id);
    $summary->execute();
    $metrics = $summary->get_result()->fetch_assoc();

    $patients = $conn->prepare('SELECT COUNT(DISTINCT patient_id) AS total FROM appointments WHERE doctor_id = ?');
    $patients->bind_param('i', $doctor_id);
    $patients->execute();
    $patientCount = (int) $patients->get_result()->fetch_assoc()['total'];

    $trend = $conn->prepare("SELECT DATE_FORMAT(appointment_date, '%Y-%m') AS month,
            SUM(status = 'Scheduled') AS scheduled,
            SUM(status = 'Completed') AS completed
        FROM appointments
        WHERE doctor_id = ?
          AND appointment_date >= DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 5 MONTH), '%Y-%m-01')
          AND appointment_date < DATE_ADD(LAST_DAY(CURRENT_DATE()), INTERVAL 1 DAY)
          AND status IN ('Scheduled', 'Completed')
        GROUP BY DATE_FORMAT(appointment_date, '%Y-%m')
        ORDER BY month");
    $trend->bind_param('i', $doctor_id);
    $trend->execute();

    $months = [];
    foreach ($trend->get_result()->fetch_all(MYSQLI_ASSOC) as $row) {
        $months[] = ['month' => $row['month'], 'scheduled' => (int) $row['scheduled'], 'completed' => (int) $row['completed']];
    }

    // Collects updates since this doctor's previous login, while keeping patient records doctor-scoped.
    $showLoginUpdates = !empty($_SESSION['doctor_notifications_pending']);
    $patientUpdates = $_SESSION['doctor_login_updates'] ?? [];
    if ($showLoginUpdates) {
        $conn->begin_transaction();
        $cursorQuery = $conn->prepare('SELECT last_seen_at FROM doctor_notification_cursors WHERE doctor_id = ? FOR UPDATE');
        $cursorQuery->bind_param('i', $doctor_id);
        $cursorQuery->execute();
        $cursorRow = $cursorQuery->get_result()->fetch_assoc();
        $since = $cursorRow['last_seen_at'] ?? date('Y-m-d H:i:s', strtotime('-7 days'));

        $incoming = $conn->prepare("SELECT p.full_name, m.message_text AS detail, m.created_at
            FROM messages m JOIN patients p ON p.patient_id = m.patient_id
            WHERE m.doctor_id = ? AND m.sender_type = 'patient' AND m.is_read = 0
            ORDER BY m.created_at DESC LIMIT 25");
        $incoming->bind_param('i', $doctor_id);
        $incoming->execute();
        foreach ($incoming->get_result()->fetch_all(MYSQLI_ASSOC) as $row) {
            $patientUpdates[] = ['kind' => 'message', 'title' => 'Unread patient message', 'patient' => $row['full_name'], 'detail' => $row['detail'], 'created_at' => $row['created_at']];
        }

        $patientNotices = $conn->prepare("SELECT p.full_name, n.title, n.body, n.created_at
            FROM notifications n JOIN patients p ON p.patient_id = n.patient_id
            WHERE n.is_read = 0 AND n.doctor_id = ?
              AND (n.appointment_id IS NULL OR EXISTS (
                  SELECT 1 FROM appointments a
                  WHERE a.appointment_id = n.appointment_id
                    AND a.doctor_id = n.doctor_id
                    AND a.patient_id = n.patient_id
              ))
            ORDER BY n.created_at DESC LIMIT 25");
        $patientNotices->bind_param('i', $doctor_id);
        $patientNotices->execute();
        foreach ($patientNotices->get_result()->fetch_all(MYSQLI_ASSOC) as $row) {
            $patientUpdates[] = ['kind' => 'patient-notification', 'title' => $row['title'], 'patient' => $row['full_name'], 'detail' => $row['body'] ?: 'A patient notification is unread.', 'created_at' => $row['created_at']];
        }

        $newAppointments = $conn->prepare("SELECT p.full_name, a.appointment_date, a.appointment_time, v.name AS vaccine_name, a.created_at
            FROM appointments a JOIN patients p ON p.patient_id = a.patient_id LEFT JOIN vaccines v ON v.vaccine_id = a.vaccine_id
            WHERE a.doctor_id = ? AND a.status = 'Scheduled' AND a.created_at > ?
            ORDER BY a.created_at DESC LIMIT 25");
        $newAppointments->bind_param('is', $doctor_id, $since);
        $newAppointments->execute();
        foreach ($newAppointments->get_result()->fetch_all(MYSQLI_ASSOC) as $row) {
            $when = $row['appointment_date'] . ($row['appointment_time'] ? ' at ' . $row['appointment_time'] : '');
            $patientUpdates[] = ['kind' => 'appointment', 'title' => 'New scheduled appointment', 'patient' => $row['full_name'], 'detail' => $when . ($row['vaccine_name'] ? ' · ' . $row['vaccine_name'] : ''), 'created_at' => $row['created_at']];
        }

        $newPrechecks = $conn->prepare("SELECT p.full_name, pf.submitted_at, v.name AS vaccine_name
            FROM precheck_forms pf JOIN patients p ON p.patient_id = pf.patient_id
            JOIN appointments a ON a.appointment_id = pf.appointment_id AND a.doctor_id = ? AND a.patient_id = pf.patient_id
            LEFT JOIN vaccines v ON v.vaccine_id = pf.vaccine_id
            WHERE pf.submitted_at > ? ORDER BY pf.submitted_at DESC LIMIT 25");
        $newPrechecks->bind_param('is', $doctor_id, $since);
        $newPrechecks->execute();
        foreach ($newPrechecks->get_result()->fetch_all(MYSQLI_ASSOC) as $row) {
            $patientUpdates[] = ['kind' => 'precheck', 'title' => 'Patient submitted a pre-check form', 'patient' => $row['full_name'], 'detail' => $row['vaccine_name'] ?: 'Review the patient’s vaccination screening responses.', 'created_at' => $row['submitted_at']];
        }

        usort($patientUpdates, static fn($a, $b) => strcmp($b['created_at'], $a['created_at']));
        $cursor = $conn->prepare('INSERT INTO doctor_notification_cursors (doctor_id, last_seen_at) VALUES (?, NOW()) ON DUPLICATE KEY UPDATE last_seen_at = VALUES(last_seen_at)');
        $cursor->bind_param('i', $doctor_id);
        $cursor->execute();
        $conn->commit();
        $_SESSION['doctor_login_updates'] = $patientUpdates;
        $_SESSION['doctor_notifications_pending'] = false;
    }

    echo json_encode([
        'status' => 'success',
        'metrics' => [
            'today' => (int) $metrics['today'],
            'nextSevenDays' => (int) $metrics['next_seven_days'],
            'completedMonth' => (int) $metrics['completed_month'],
            'activePatients' => $patientCount,
            'patientUpdates' => count($patientUpdates),
        ],
        'trend' => array_values($months),
        'patientUpdates' => $patientUpdates,
        'showLoginUpdates' => $showLoginUpdates,
    ], JSON_UNESCAPED_UNICODE);
} catch (Throwable $error) {
    @$conn->rollback();
    error_log('Doctor dashboard query failed: ' . $error->getMessage());
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Dashboard analytics could not be loaded.']);
}
