<?php
session_start();
require_once 'db.php';
header('Content-Type: application/json');

if (!isset($_SESSION['doctor_id'])) {
    echo json_encode(["status" => "error", "message" => "Unauthorized"]);
    exit;
}

$doctor_id = $_SESSION['doctor_id'];
$action = $_GET['action'] ?? 'get_day';

if ($action === 'get_day') {
    $date = $_GET['date'] ?? date('Y-m-d');
    
    $sql = "SELECT a.time_slot, p.full_name, a.symptoms_notes, p.patient_id 
            FROM appointments a 
            JOIN patients p ON a.patient_id = p.patient_id 
            WHERE a.doctor_id = ? AND a.appointment_date = ?";
            
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("is", $doctor_id, $date);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $appointments = [];
    while ($row = $result->fetch_assoc()) {
        $appointments[$row['time_slot']] = [
            "name" => $row['full_name'],
            "reason" => $row['symptoms_notes'],
            "patient_id" => $row['patient_id']
        ];
    }
    $stmt->close();
    
    echo json_encode(["status" => "success", "data" => $appointments]);

} elseif ($action === 'get_month') {
    $year = intval($_GET['year'] ?? date('Y'));
    $month = intval($_GET['month'] ?? date('m'));
    
    $sql = "SELECT DAY(appointment_date) as day_num, COUNT(*) as booking_count 
            FROM appointments 
            WHERE doctor_id = ? AND YEAR(appointment_date) = ? AND MONTH(appointment_date) = ? 
            GROUP BY appointment_date";
            
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("iii", $doctor_id, $year, $month);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $counts = [];
    while ($row = $result->fetch_assoc()) {
        $counts[$row['day_num']] = $row['booking_count'];
    }
    $stmt->close();
    
    echo json_encode(["status" => "success", "data" => $counts]);
}
?>