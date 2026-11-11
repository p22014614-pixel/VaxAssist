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

    $notificationQuery = $conn->prepare("SELECT n.notification_id, n.patient_id, n.appointment_id, n.type, n.title, n.body, n.is_read, n.created_at, p.full_name
        FROM notifications n JOIN patients p ON p.patient_id = n.patient_id
        WHERE n.doctor_id = ? AND n.recipient_type = 'doctor'
        ORDER BY n.created_at DESC, n.notification_id DESC");
    $notificationQuery->bind_param('i', $doctor_id);
    $notificationQuery->execute();
    $patientUpdates = array_map(static function (array $row): array {
        return [
            'id' => (int) $row['notification_id'],
            'patient_id' => (int) $row['patient_id'],
            'appointment_id' => $row['appointment_id'] === null ? null : (int) $row['appointment_id'],
            'kind' => strtolower($row['type']),
            'title' => $row['title'],
            'patient' => $row['full_name'],
            'detail' => (string) $row['body'],
            'is_read' => (int) $row['is_read'],
            'created_at' => $row['created_at'],
        ];
    }, $notificationQuery->get_result()->fetch_all(MYSQLI_ASSOC));
    $unreadCount = count(array_filter($patientUpdates, static fn(array $item): bool => $item['is_read'] === 0));
    $showLoginUpdates = $unreadCount > 0;

    echo json_encode([
        'status' => 'success',
        'metrics' => [
            'today' => (int) $metrics['today'],
            'nextSevenDays' => (int) $metrics['next_seven_days'],
            'completedMonth' => (int) $metrics['completed_month'],
            'activePatients' => $patientCount,
            'patientUpdates' => $unreadCount,
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
