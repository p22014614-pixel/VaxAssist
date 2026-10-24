<?php
require __DIR__ . '/doctor_backend_auth.php';
$today = $conn->prepare("SELECT COUNT(*) total FROM appointments WHERE doctor_id = ? AND appointment_date = CURRENT_DATE() AND status = 'Scheduled'");
$today->bind_param('i', $doctor_id); $today->execute();
$todayCount = (int) $today->get_result()->fetch_assoc()['total'];
$week = $conn->prepare("SELECT COUNT(*) total FROM appointments WHERE doctor_id = ? AND YEARWEEK(appointment_date, 1) = YEARWEEK(CURRENT_DATE(), 1) AND status = 'Scheduled'");
$week->bind_param('i', $doctor_id); $week->execute();
$weeklyCount = (int) $week->get_result()->fetch_assoc()['total'];
$patients = $conn->prepare('SELECT COUNT(DISTINCT patient_id) total FROM appointments WHERE doctor_id = ?');
$patients->bind_param('i', $doctor_id); $patients->execute();
$patientCount = (int) $patients->get_result()->fetch_assoc()['total'];
$messages = $conn->prepare("SELECT COUNT(*) total FROM messages WHERE doctor_id = ? AND sender_type = 'patient' AND is_read = 0");
$messages->bind_param('i', $doctor_id); $messages->execute();
$messageCount = (int) $messages->get_result()->fetch_assoc()['total'];
echo json_encode(['status' => 'success', 'today' => $todayCount, 'weekly' => $weeklyCount, 'patients' => $patientCount, 'messages' => $messageCount]);
