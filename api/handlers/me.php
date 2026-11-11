<?php
// The logged-in patient: profile, health details, password, children.

function me_show(array $p, array $in): void
{
    $patient = require_login();
    $row = patient_row((int) $patient['patient_id']);
    [$first, $last] = split_name($row['full_name']);
    out(['profile' => [
        'first_name' => $first, 'last_name' => $last, 'email' => (string) $row['email'], 'phone' => (string) $row['phone'],
        'dob' => (string) $row['dob'], 'gender' => strtolower($row['gender']), 'address' => (string) $row['address'],
        'emergency_contact_name' => (string) $row['emergency_contact_name'],
        'emergency_contact_phone' => (string) $row['emergency_contact_phone'],
    ]]);
}

function me_update(array $p, array $in): void
{
    $patient = require_login();
    $first = text_in($in['first_name'] ?? '', 50);
    $last  = text_in($in['last_name'] ?? '', 50);
    $phone = text_in($in['phone'] ?? '', 20);
    $dob   = (string) ($in['dob'] ?? '');
    $ecp   = text_in($in['emergency_contact_phone'] ?? '', 20);

    $errors = [];
    if ($first === '' || $last === '') $errors['first_name'] = 'Please enter your first and last name.';
    if (!preg_match('/^[0-9+\s\-]{8,15}$/', $phone)) $errors['phone'] = 'Enter a valid phone number.';
    if (!valid_date($dob) || $dob > date('Y-m-d')) $errors['dob'] = 'Enter a valid date of birth.';
    if ($ecp !== '' && !preg_match('/^[0-9+\s\-]{8,15}$/', $ecp)) $errors['emergency_contact_phone'] = 'Enter a valid phone number.';
    if ($errors) fail(422, 'Please check the highlighted fields.', $errors);

    db()->prepare(
        'UPDATE patients SET full_name = ?, phone = ?, dob = ?, gender = ?, address = ?,
                emergency_contact_name = ?, emergency_contact_phone = ? WHERE patient_id = ?'
    )->execute([
        $first . ' ' . $last, $phone, $dob, gender_to_db($in['gender'] ?? ''), text_in($in['address'] ?? '', 500) ?: null,
        text_in($in['emergency_contact_name'] ?? '', 100) ?: null, $ecp ?: null, $patient['patient_id'],
    ]);
    out(null, 204);
}

function health_show(array $p, array $in): void
{
    $patient = require_login();
    $row = patient_row((int) $patient['patient_id']);
    $lists = ['Allergy' => [], 'Condition' => [], 'Medication' => []];
    $stmt = db()->prepare('SELECT item_type, name FROM patient_health_items WHERE patient_id = ? ORDER BY item_id');
    $stmt->execute([$patient['patient_id']]);
    foreach ($stmt->fetchAll() as $r) $lists[$r['item_type']][] = $r['name'];

    out(['health' => [
        'blood_type' => (string) $row['blood_type'],
        'height_cm' => $row['height_cm'] === null ? null : (int) $row['height_cm'],
        'weight_kg' => $row['weight_kg'] === null ? null : (float) $row['weight_kg'],
        'no_known_allergies' => (bool) $row['no_known_allergies'],
        'allergies' => $lists['Allergy'], 'conditions' => $lists['Condition'], 'medications' => $lists['Medication'],
    ]]);
}

function health_update(array $p, array $in): void
{
    $patient = require_login();
    $id = (int) $patient['patient_id'];
    $pdo = db();

    $bloodTypes = ['', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    $blood  = (string) ($in['blood_type'] ?? '');
    $height = $in['height_cm'] ?? null;
    $weight = $in['weight_kg'] ?? null;
    $errors = [];
    if (!in_array($blood, $bloodTypes, true)) $errors['blood_type'] = 'Choose a blood type from the list.';
    if ($height !== null && (!is_numeric($height) || $height < 30 || $height > 250)) $errors['height_cm'] = 'Enter a height between 30 and 250 cm.';
    if ($weight !== null && (!is_numeric($weight) || $weight < 2 || $weight > 400)) $errors['weight_kg'] = 'Enter a weight between 2 and 400 kg.';
    if ($errors) fail(422, 'Please check the highlighted fields.', $errors);

    $items = [];
    if (!empty($in['no_known_allergies'])) $in['allergies'] = [];
    foreach (['Allergy' => 'allergies', 'Condition' => 'conditions', 'Medication' => 'medications'] as $type => $key) {
        $names = [];
        foreach ((array) ($in[$key] ?? []) as $n) {
            $n = text_in($n, 100);
            if ($n !== '' && !isset($names[mb_strtolower($n)])) $names[mb_strtolower($n)] = $n;
        }
        foreach (array_slice(array_values($names), 0, 20) as $n) $items[] = [$type, $n];
    }

    $pdo->beginTransaction();
    $pdo->prepare('UPDATE patients SET blood_type = ?, height_cm = ?, weight_kg = ?, no_known_allergies = ? WHERE patient_id = ?')
        ->execute([$blood === '' ? null : $blood, $height === null ? null : (int) $height, $weight, empty($in['no_known_allergies']) ? 0 : 1, $id]);
    $pdo->prepare('DELETE FROM patient_health_items WHERE patient_id = ?')->execute([$id]);
    $ins = $pdo->prepare('INSERT INTO patient_health_items (patient_id, item_type, name) VALUES (?, ?, ?)');
    foreach ($items as [$type, $name]) $ins->execute([$id, $type, $name]);
    $pdo->commit();
    out(null, 204);
}

function password_update(array $p, array $in): void
{
    $patient = require_login();
    $current = (string) ($in['current'] ?? '');
    $new     = (string) ($in['new'] ?? '');

    $stmt = db()->prepare('SELECT password_hash FROM patients WHERE patient_id = ?');
    $stmt->execute([$patient['patient_id']]);
    $hash = (string) $stmt->fetchColumn();

    if (!password_verify($current, $hash)) fail(403, 'Your current password is not correct.');
    if (!strong_password($new)) fail(422, 'Your new password needs at least 8 characters, with letters and numbers.');
    if ($new === $current) fail(422, 'Your new password must be different from the current one.');

    db()->prepare('UPDATE patients SET password_hash = ? WHERE patient_id = ?')
        ->execute([password_hash($new, PASSWORD_DEFAULT), $patient['patient_id']]);
    out(null, 204);
}

function children_list(array $p, array $in): void
{
    $patient = require_login();
    $stmt = db()->prepare('SELECT child_id, first_name, dob, gender FROM children WHERE patient_id = ? ORDER BY child_id');
    $stmt->execute([$patient['patient_id']]);
    out(['children' => array_map(function ($c) {
        return ['id' => (int) $c['child_id'], 'first_name' => $c['first_name'], 'dob' => $c['dob'], 'gender' => strtolower($c['gender'])];
    }, $stmt->fetchAll())]);
}

function children_create(array $p, array $in): void
{
    $patient = require_login();
    $id = (int) $patient['patient_id'];
    $pdo = db();

    $name = text_in($in['first_name'] ?? '', 50);
    $dob  = (string) ($in['dob'] ?? '');
    $errors = [];
    if ($name === '') $errors['first_name'] = "Please enter your child's name.";
    if (!valid_date($dob) || $dob > date('Y-m-d')) $errors['dob'] = 'Enter a valid date of birth.';
    elseif ($dob < date('Y-m-d', strtotime('-18 years'))) $errors['dob'] = 'Children must be under 18.';
    if ($errors) fail(422, 'Please check the highlighted fields.', $errors);

    $count = $pdo->prepare('SELECT COUNT(*) FROM children WHERE patient_id = ?');
    $count->execute([$id]);
    if ((int) $count->fetchColumn() >= 10) fail(422, 'You can save up to 10 children.');

    $pdo->prepare('INSERT INTO children (patient_id, first_name, dob, gender) VALUES (?, ?, ?, ?)')
        ->execute([$id, $name, $dob, gender_to_db($in['gender'] ?? '')]);
    $childId = (int) $pdo->lastInsertId();
    created('/api/children/' . $childId, ['id' => $childId]);
}

function children_delete(array $p, array $in): void
{
    $patient = require_login();
    $pdo = db();

    // Removing a child would also erase their vaccination records and turn their visits into the
    // parent's own, so a child with any history cannot be removed.
    $own = $pdo->prepare('SELECT first_name FROM children WHERE child_id = ? AND patient_id = ?');
    $own->execute([(int) $p['id'], $patient['patient_id']]);
    $name = $own->fetchColumn();
    if ($name === false) fail(404, 'Child not found.');
    $history = $pdo->prepare('SELECT (SELECT COUNT(*) FROM vaccination_records WHERE child_id = ?) + (SELECT COUNT(*) FROM appointments WHERE child_id = ?)');
    $history->execute([(int) $p['id'], (int) $p['id']]);
    if ((int) $history->fetchColumn() > 0) {
        fail(409, $name . ' has vaccination records or appointments, so they cannot be removed. Their health history is kept for safety.');
    }

    $stmt = $pdo->prepare('DELETE FROM children WHERE child_id = ? AND patient_id = ?');
    $stmt->execute([(int) $p['id'], $patient['patient_id']]);
    if ($stmt->rowCount() === 0) fail(404, 'Child not found.');
    out(null, 204);
}
