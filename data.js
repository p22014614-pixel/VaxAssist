function daysFromToday(n) {
    const d = new Date();
    d.setDate(d.getDate() + n);
    return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
}

async function getVaccinations() {
    const clinic = 'VaxAssist Clinic, Kuala Lumpur';
    return [
        { id: 501, vaccine_name: 'Typhoid', category: 'Travel', patient_type: 'self', patient_name: 'Myself',
          dose_number: 1, total_doses: 1, date_given: daysFromToday(-12), batch_number: 'TY-22914B', manufacturer: 'Demo Pharma',
          doctor_name: 'Dr. Aisha Rahman', clinic: clinic, next_dose_date: '', notes: 'Booster needed after 3 years if still travelling.' },
        { id: 502, vaccine_name: 'Hepatitis A', category: 'Travel', patient_type: 'self', patient_name: 'Myself',
          dose_number: 1, total_doses: 2, date_given: daysFromToday(-41), batch_number: 'HA-80731C', manufacturer: 'Demo Pharma',
          doctor_name: 'Dr. Jason Wong', clinic: clinic, next_dose_date: daysFromToday(40), notes: 'Second dose 6 to 12 months after the first.' },
        { id: 503, vaccine_name: 'Influenza', category: 'Seasonal', patient_type: 'self', patient_name: 'Myself',
          dose_number: 1, total_doses: 1, date_given: daysFromToday(-210), batch_number: 'FLU-5519A', manufacturer: 'Demo Pharma',
          doctor_name: 'Dr. Priya Nair', clinic: clinic, next_dose_date: daysFromToday(155), notes: '' },
        { id: 504, vaccine_name: 'Td Booster', category: 'Adult', patient_type: 'self', patient_name: 'Myself',
          dose_number: 1, total_doses: 1, date_given: daysFromToday(-1100), batch_number: 'TD-30276D', manufacturer: 'Demo Pharma',
          doctor_name: 'Dr. Priya Nair', clinic: clinic, next_dose_date: daysFromToday(2550), notes: 'Repeat every 10 years.' },

        { id: 511, vaccine_name: 'BCG', category: 'Childhood', patient_type: 'child', patient_name: 'Aiden',
          dose_number: 1, total_doses: 1, date_given: daysFromToday(-430), batch_number: 'BCG-1102', manufacturer: 'Demo Pharma',
          doctor_name: 'Dr. Siti Aminah', clinic: clinic, next_dose_date: '', notes: '' },
        { id: 512, vaccine_name: 'Hepatitis B', category: 'Childhood', patient_type: 'child', patient_name: 'Aiden',
          dose_number: 3, total_doses: 3, date_given: daysFromToday(-250), batch_number: 'HB-77410', manufacturer: 'Demo Pharma',
          doctor_name: 'Dr. Daniel Lim', clinic: clinic, next_dose_date: '', notes: 'Course complete.' },
        { id: 513, vaccine_name: 'Rotavirus', category: 'Childhood', patient_type: 'child', patient_name: 'Aiden',
          dose_number: 2, total_doses: 2, date_given: daysFromToday(-305), batch_number: 'RV-4408', manufacturer: 'Demo Pharma',
          doctor_name: 'Dr. Daniel Lim', clinic: clinic, next_dose_date: '', notes: 'Course complete.' },
        { id: 514, vaccine_name: 'Pneumococcal (PCV)', category: 'Childhood', patient_type: 'child', patient_name: 'Aiden',
          dose_number: 2, total_doses: 3, date_given: daysFromToday(-300), batch_number: 'PCV-9912', manufacturer: 'Demo Pharma',
          doctor_name: 'Dr. Daniel Lim', clinic: clinic, next_dose_date: daysFromToday(-10), notes: 'Booster dose at 12 months.' },
        { id: 515, vaccine_name: 'DTaP-IPV-Hib', category: 'Childhood', patient_type: 'child', patient_name: 'Aiden',
          dose_number: 3, total_doses: 4, date_given: daysFromToday(-30), batch_number: 'DTP-6063', manufacturer: 'Demo Pharma',
          doctor_name: 'Dr. Siti Aminah', clinic: clinic, next_dose_date: daysFromToday(105), notes: 'Booster due at 18 months.' }
    ];
}
