<?php
session_start();
require_once 'db.php';
header('Content-Type: application/json');

// Fallback to doctor_id = 1 if session is not active for testing
$doctor_id = $_SESSION['doctor_id'] ?? 1;

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Fetch messages joined with patients table to display patient names
    $sql = "SELECT m.message_id, m.sender_type, m.message_text, m.created_at, p.full_name 
            FROM messages m 
            JOIN patients p ON m.patient_id = p.patient_id 
            WHERE m.doctor_id = ? 
            ORDER BY m.created_at ASC";
            
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $doctor_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $messages = [];
    while ($row = $result->fetch_assoc()) {
        $messages[] = [
            "id" => $row['message_id'],
            // If sender_type is 'doctor', it's an outgoing message; otherwise incoming
            "type" => ($row['sender_type'] === 'doctor') ? "msg-out" : "msg-in",
            "text" => $row['message_text'],
            "sender_name" => $row['full_name']
        ];
    }
    $stmt->close();
    
    echo json_encode(["status" => "success", "data" => $messages]);

} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    $patient_id = intval($data['patient_id'] ?? 2); // Default to Sarah Jenkins (ID: 2)
    $message_text = trim($data['message_text'] ?? '');
    
    if (!empty($message_text)) {
        $stmt = $conn->prepare("INSERT INTO messages (doctor_id, patient_id, sender_type, message_text) VALUES (?, ?, 'doctor', ?)");
        $stmt->bind_param("iis", $doctor_id, $patient_id, $message_text);
        if ($stmt->execute()) {
            echo json_encode(["status" => "success"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to send message"]);
        }
        $stmt->close();
    }
}
?>