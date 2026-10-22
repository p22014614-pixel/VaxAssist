<?php
// Public reference data. Read only.

function doctors_list(array $p, array $in): void
{
    // By default only doctors with working days appear. ?all=1 lists every doctor (used for messaging).
    $having = isset($_GET['all']) ? '1 = 1' : 'EXISTS (SELECT 1 FROM doctor_availability v WHERE v.doctor_id = d.doctor_id)';
    $rows = db()->query(
        "SELECT d.doctor_id, d.first_name, d.last_name, d.specialization, d.years_experience, d.languages, d.bio, d.keywords,
                (SELECT ROUND(AVG(r.rating), 1) FROM reviews r JOIN appointments a ON a.appointment_id = r.appointment_id
                  WHERE a.doctor_id = d.doctor_id) AS rating,
                (SELECT COUNT(*) FROM reviews r JOIN appointments a ON a.appointment_id = r.appointment_id
                  WHERE a.doctor_id = d.doctor_id) AS review_count
           FROM doctors d WHERE $having ORDER BY d.doctor_id"
    )->fetchAll();

    $days = [];
    foreach (db()->query('SELECT doctor_id, weekday FROM doctor_availability ORDER BY weekday')->fetchAll() as $r) {
        $days[$r['doctor_id']][] = (int) $r['weekday'];
    }

    out(['doctors' => array_map(function ($r) use ($days) {
        return [
            'id' => (int) $r['doctor_id'], 'name' => 'Dr. ' . $r['first_name'] . ' ' . $r['last_name'], 'specialty' => $r['specialization'],
            'years_experience' => (int) $r['years_experience'], 'rating' => $r['rating'] === null ? null : (float) $r['rating'],
            'review_count' => (int) $r['review_count'], 'languages' => (string) $r['languages'], 'bio' => (string) $r['bio'],
            'days' => $days[$r['doctor_id']] ?? [],
            'treats' => array_values(array_filter(array_map('trim', explode(',', (string) $r['keywords'])))),
        ];
    }, $rows)]);
}

// GET /doctors/{id}/slots?date=YYYY-MM-DD
function doctor_slots(array $p, array $in): void
{
    $doctorId = (int) $p['id'];
    $date     = (string) ($_GET['date'] ?? '');
    $ignore   = isset($_GET['ignore']) ? (int) $_GET['ignore'] : null;

    if ($doctorId < 1 || !valid_date($date)) fail(422, 'Choose a doctor and a valid date.');
    if ($date > date('Y-m-d', strtotime('+60 days'))) out(['slots' => []]);

    out(['slots' => available_slots($doctorId, $date, $ignore)]);
}

function vaccines_list(array $p, array $in): void
{
    $labels = ['Travel' => 'Travel vaccines', 'Childhood' => 'Childhood vaccines', 'Booster' => 'Boosters', 'Consultation' => 'Consultation'];
    $gp = ['Influenza', 'Td Booster', 'MMR'];

    // Which doctor to suggest for each kind of vaccine.
    $doctorFor = [];
    foreach (db()->query(
        'SELECT d.specialization, MIN(d.doctor_id) id FROM doctors d
          WHERE EXISTS (SELECT 1 FROM doctor_availability a WHERE a.doctor_id = d.doctor_id) GROUP BY d.specialization'
    )->fetchAll() as $r) {
        $doctorFor[$r['specialization']] = (int) $r['id'];
    }

    out(['vaccines' => array_map(function ($v) use ($labels, $gp, $doctorFor) {
        $spec = $v['category'] === 'Travel' ? 'Travel Medicine' : ($v['category'] === 'Childhood' ? 'Paediatrics' : 'General Practice');
        if (in_array($v['name'], $gp, true)) $spec = 'General Practice';
        return [
            'id' => (int) $v['vaccine_id'], 'name' => $v['name'], 'category' => $labels[$v['category']], 'price' => (float) $v['price'],
            'lead_days' => $v['lead_days'] === null ? 14 : (int) $v['lead_days'],
            'doctor_id' => $doctorFor[$spec] ?? null, 'child_doctor_id' => $doctorFor['Paediatrics'] ?? null,
        ];
    }, db()->query('SELECT vaccine_id, name, category, price, lead_days FROM vaccines ORDER BY vaccine_id')->fetchAll())]);
}

function destinations_list(array $p, array $in): void
{
    $dest = db()->query('SELECT destination_id, country_code, country, region FROM destinations ORDER BY country')->fetchAll();
    $list = [];
    foreach (db()->query(
        'SELECT dv.destination_id, v.name, dv.requirement, dv.reason FROM destination_vaccines dv
           JOIN vaccines v ON v.vaccine_id = dv.vaccine_id ORDER BY dv.requirement = "Required" DESC, v.vaccine_id'
    )->fetchAll() as $r) {
        $list[$r['destination_id']][] = ['name' => $r['name'], 'level' => strtolower($r['requirement']), 'why' => (string) $r['reason']];
    }
    out(['destinations' => array_map(function ($d) use ($list) {
        return ['id' => $d['country_code'], 'country' => $d['country'], 'region' => $d['region'], 'vaccines' => $list[$d['destination_id']] ?? []];
    }, $dest)]);
}

function schedule_list(array $p, array $in): void
{
    out(['schedule' => array_map(function ($r) {
        return ['months' => (int) $r['age_months'], 'name' => $r['name'], 'level' => strtolower($r['requirement']),
                'dose' => $r['dose_label'], 'dose_number' => (int) $r['dose_number'], 'why' => (string) $r['reason']];
    }, db()->query(
        'SELECT s.age_months, v.name, s.requirement, s.dose_label, s.dose_number, s.reason
           FROM child_schedule s JOIN vaccines v ON v.vaccine_id = s.vaccine_id ORDER BY s.age_months, s.schedule_id'
    )->fetchAll())]);
}
