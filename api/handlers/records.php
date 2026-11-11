<?php
// Vaccination records and payments.

// Lists the patient's vaccination records.
function records_list(array $p, array $in): void
{
    $patient = require_login();
    $stmt = db()->prepare(
        "SELECT r.record_id, v.name vaccine, v.category, v.total_doses, r.child_id, c.first_name child_name,
                r.dose_number, r.date_given, r.next_dose_date, r.notes,
                b.batch_number, b.manufacturer, d.first_name dfirst, d.last_name dlast
           FROM vaccination_records r
           JOIN vaccines v ON v.vaccine_id = r.vaccine_id
           LEFT JOIN children c ON c.child_id = r.child_id
           LEFT JOIN vaccine_batches b ON b.batch_id = r.batch_id
           LEFT JOIN doctors d ON d.doctor_id = r.doctor_id
          WHERE r.patient_id = ?
          ORDER BY r.date_given DESC, r.record_id DESC"
    );
    $stmt->execute([$patient['patient_id']]);

    $category = function (string $name, string $cat): string {
        if ($cat === 'Booster') return $name === 'Influenza' ? 'Seasonal' : 'Adult';
        return $cat === 'Consultation' ? 'Adult' : $cat;
    };

    out(['records' => array_map(function ($r) use ($category) {
        return [
            'id' => (int) $r['record_id'], 'vaccine_name' => $r['vaccine'], 'category' => $category($r['vaccine'], $r['category']),
            'patient_type' => $r['child_id'] ? 'child' : 'self', 'patient_name' => $r['child_id'] ? $r['child_name'] : 'Myself',
            'dose_number' => (int) $r['dose_number'], 'total_doses' => max((int) $r['total_doses'], (int) $r['dose_number']),
            'date_given' => $r['date_given'], 'batch_number' => (string) $r['batch_number'], 'manufacturer' => (string) $r['manufacturer'],
            'doctor_name' => $r['dfirst'] ? 'Dr. ' . $r['dfirst'] . ' ' . $r['dlast'] : '',
            'clinic' => 'VaxAssist Clinic, Kuala Lumpur', 'next_dose_date' => (string) $r['next_dose_date'], 'notes' => (string) $r['notes'],
        ];
    }, $stmt->fetchAll())]);
}

// Lists the patient's payments.
function payments_list(array $p, array $in): void
{
    $patient = require_login();
    sync_clinic_changes((int) $patient['patient_id']);
    $pdo = db();

    $stmt = $pdo->prepare(
        "SELECT p.payment_id, p.receipt_no, p.status, p.method, p.insurance_covered, p.created_at, p.paid_at,
                a.appointment_date, c.first_name child_name, d.first_name dfirst, d.last_name dlast, v.name vaccine
           FROM payments p
           LEFT JOIN appointments a ON a.appointment_id = p.appointment_id
           LEFT JOIN children c ON c.child_id = a.child_id
           LEFT JOIN doctors d ON d.doctor_id = a.doctor_id
           LEFT JOIN vaccines v ON v.vaccine_id = a.vaccine_id
          WHERE p.patient_id = ?
          ORDER BY p.created_at DESC, p.payment_id DESC"
    );
    $stmt->execute([$patient['patient_id']]);

    $items = [];
    $all = $pdo->prepare('SELECT i.payment_id, i.label, i.amount FROM payment_items i JOIN payments p ON p.payment_id = i.payment_id WHERE p.patient_id = ? ORDER BY i.item_id');
    $all->execute([$patient['patient_id']]);
    foreach ($all->fetchAll() as $i) $items[$i['payment_id']][] = ['label' => $i['label'], 'amount' => (float) $i['amount']];

    out(['payments' => array_map(function ($r) use ($items) {
        $date = $r['status'] === 'Pending' && $r['appointment_date'] ? $r['appointment_date'] : substr($r['paid_at'] ?: $r['created_at'], 0, 10);
        return [
            'id' => (int) $r['payment_id'], 'receipt_no' => $r['receipt_no'], 'date' => $date,
            'description' => ($r['vaccine'] ?: 'Consultation') . ($r['status'] === 'Refunded' ? ' (refunded)' : ''),
            'patient' => $r['child_name'] ? $r['child_name'] . ' (child)' : 'Myself',
            'doctor' => $r['dfirst'] ? 'Dr. ' . $r['dfirst'] . ' ' . $r['dlast'] : 'VaxAssist Clinic',
            'items' => $items[$r['payment_id']] ?? [], 'method' => (string) $r['method'],
            'insurance_covered' => (float) $r['insurance_covered'], 'status' => strtolower($r['status']),
        ];
    }, $stmt->fetchAll())]);
}

// Pays a pending payment.
function payments_update(array $p, array $in): void
{
    $patient = require_login();
    sync_clinic_changes((int) $patient['patient_id']);
    if (($in['status'] ?? '') !== 'paid') fail(422, 'The only change allowed is paying a pending payment.');

    $method = (string) ($in['method'] ?? '');
    if (!in_array($method, ['Credit card', 'E-wallet', 'Online banking'], true)) fail(422, 'Choose a payment method.');

    $stmt = db()->prepare("UPDATE payments SET status = 'Paid', method = ?, paid_at = NOW() WHERE payment_id = ? AND patient_id = ? AND status = 'Pending'");
    $stmt->execute([$method, (int) $p['id'], $patient['patient_id']]);
    if ($stmt->rowCount() !== 1) fail(404, 'That payment cannot be paid.');
    out(null, 204);
}
