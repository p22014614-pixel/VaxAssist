-- =====================================================================
-- VaxAssist patient-side database extension
--
-- Run this AFTER vaxassist_db.sql (the team's database). It does not
-- delete or rename anything the doctor/admin side already uses. It only:
--   1. adds columns to patients, doctors and appointments
--   2. creates the new tables the patient pages need
--   3. fills in the vaccine, destination and childhood-schedule data
--
-- Run it once. (Re-running fails at the FOREIGN KEY lines because they
-- already exist.)
-- =====================================================================

USE `vaxassist_db`;

-- ---------------------------------------------------------------------
-- 1. Changes to the team's existing tables
-- ---------------------------------------------------------------------

-- Patients need an email + password to log in. The registration form has
-- no IC/passport field, so that column must allow NULL (the UNIQUE index
-- still stops duplicates when a value is given).
ALTER TABLE `patients`
  MODIFY `ic_passport` varchar(50) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `email` varchar(100) DEFAULT NULL AFTER `full_name`,
  ADD COLUMN IF NOT EXISTS `password_hash` varchar(255) DEFAULT NULL AFTER `email`,
  ADD COLUMN IF NOT EXISTS `address` text DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `emergency_contact_name` varchar(100) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `emergency_contact_phone` varchar(20) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `height_cm` smallint(6) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `weight_kg` decimal(5,1) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `no_known_allergies` tinyint(1) NOT NULL DEFAULT 0,
  ADD UNIQUE KEY `uq_patients_email` (`email`);

-- The Doctors page shows a bio, experience and languages.
ALTER TABLE `doctors`
  ADD COLUMN IF NOT EXISTS `bio` text DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `years_experience` tinyint(3) unsigned DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `languages` varchar(150) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `keywords` text DEFAULT NULL COMMENT 'comma-separated search words for the Doctors page';

-- ---------------------------------------------------------------------
-- 2. New tables
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `children` (
  `child_id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_id` int(11) NOT NULL COMMENT 'the parent',
  `first_name` varchar(50) NOT NULL,
  `dob` date NOT NULL,
  `gender` enum('Male','Female','Other') NOT NULL DEFAULT 'Male',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`child_id`),
  KEY `idx_children_patient` (`patient_id`),
  CONSTRAINT `fk_children_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `patient_health_items` (
  `item_id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_id` int(11) NOT NULL,
  `item_type` enum('Allergy','Condition','Medication') NOT NULL,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`item_id`),
  UNIQUE KEY `uq_health_item` (`patient_id`,`item_type`,`name`),
  CONSTRAINT `fk_health_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `password_resets` (
  `reset_id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_id` int(11) NOT NULL,
  `token_hash` char(64) NOT NULL COMMENT 'SHA-256 of the emailed token; the token itself is never stored',
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`reset_id`),
  UNIQUE KEY `uq_reset_token` (`token_hash`),
  CONSTRAINT `fk_reset_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `vaccines` (
  `vaccine_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `category` enum('Travel','Childhood','Booster','Consultation') NOT NULL,
  `total_doses` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `price` decimal(8,2) NOT NULL DEFAULT 0.00 COMMENT 'demo price in RM',
  `lead_days` smallint(6) DEFAULT NULL COMMENT 'travel vaccines: ideal days before departure',
  PRIMARY KEY (`vaccine_id`),
  UNIQUE KEY `uq_vaccine_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `vaccine_batches` (
  `batch_id` int(11) NOT NULL AUTO_INCREMENT,
  `vaccine_id` int(11) NOT NULL,
  `batch_number` varchar(50) NOT NULL,
  `manufacturer` varchar(100) DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `quantity_in_stock` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`batch_id`),
  UNIQUE KEY `uq_batch_number` (`batch_number`),
  KEY `idx_batch_expiry` (`expiry_date`),
  CONSTRAINT `fk_batch_vaccine` FOREIGN KEY (`vaccine_id`) REFERENCES `vaccines` (`vaccine_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `destinations` (
  `destination_id` int(11) NOT NULL AUTO_INCREMENT,
  `country_code` char(2) NOT NULL,
  `country` varchar(100) NOT NULL,
  `region` varchar(50) NOT NULL,
  PRIMARY KEY (`destination_id`),
  UNIQUE KEY `uq_country_code` (`country_code`),
  UNIQUE KEY `uq_country` (`country`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `destination_vaccines` (
  `destination_id` int(11) NOT NULL,
  `vaccine_id` int(11) NOT NULL,
  `requirement` enum('Required','Recommended') NOT NULL,
  `reason` text DEFAULT NULL,
  PRIMARY KEY (`destination_id`,`vaccine_id`),
  CONSTRAINT `fk_dv_destination` FOREIGN KEY (`destination_id`) REFERENCES `destinations` (`destination_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_dv_vaccine` FOREIGN KEY (`vaccine_id`) REFERENCES `vaccines` (`vaccine_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `child_schedule` (
  `schedule_id` int(11) NOT NULL AUTO_INCREMENT,
  `vaccine_id` int(11) NOT NULL,
  `age_months` smallint(6) NOT NULL COMMENT 'age when the dose is due',
  `dose_number` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT '0 = not tracked (e.g. yearly flu shot)',
  `dose_label` varchar(30) NOT NULL,
  `requirement` enum('Required','Recommended') NOT NULL,
  `reason` text DEFAULT NULL,
  PRIMARY KEY (`schedule_id`),
  KEY `idx_schedule_age` (`age_months`),
  CONSTRAINT `fk_schedule_vaccine` FOREIGN KEY (`vaccine_id`) REFERENCES `vaccines` (`vaccine_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `doctor_availability` (
  `doctor_id` int(11) NOT NULL,
  `weekday` tinyint(3) unsigned NOT NULL COMMENT '1 = Monday ... 5 = Friday',
  PRIMARY KEY (`doctor_id`,`weekday`),
  CONSTRAINT `fk_avail_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Booking a child or a specific vaccine, and the exact start time.
-- The team's time_slot (2-hour window) is still filled in so the
-- doctor-side schedule keeps working.
-- 'Missed' is added to the team's status list; their existing values are unchanged.
ALTER TABLE `appointments`
  MODIFY `status` enum('Scheduled','Completed','Cancelled','Missed') DEFAULT 'Scheduled',
  ADD COLUMN IF NOT EXISTS `cancel_reason` varchar(300) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `child_id` int(11) DEFAULT NULL AFTER `patient_id`,
  ADD COLUMN IF NOT EXISTS `vaccine_id` int(11) DEFAULT NULL AFTER `child_id`,
  ADD COLUMN IF NOT EXISTS `appointment_time` time DEFAULT NULL AFTER `appointment_date`,
  ADD KEY `idx_appt_child` (`child_id`),
  ADD KEY `idx_appt_vaccine` (`vaccine_id`),
  ADD KEY `idx_appt_doctor_date` (`doctor_id`,`appointment_date`),
  ADD CONSTRAINT `fk_appt_child` FOREIGN KEY (`child_id`) REFERENCES `children` (`child_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_appt_vaccine` FOREIGN KEY (`vaccine_id`) REFERENCES `vaccines` (`vaccine_id`) ON DELETE SET NULL;

CREATE TABLE IF NOT EXISTS `vaccination_records` (
  `record_id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_id` int(11) NOT NULL COMMENT 'the account owner (the parent, for a child)',
  `child_id` int(11) DEFAULT NULL COMMENT 'NULL = the patient themself',
  `vaccine_id` int(11) NOT NULL,
  `batch_id` int(11) DEFAULT NULL,
  `doctor_id` int(11) DEFAULT NULL,
  `appointment_id` int(11) DEFAULT NULL,
  `dose_number` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `date_given` date NOT NULL,
  `next_dose_date` date DEFAULT NULL,
  `notes` text DEFAULT NULL,
  PRIMARY KEY (`record_id`),
  KEY `idx_vr_patient` (`patient_id`),
  KEY `idx_vr_child` (`child_id`),
  KEY `idx_vr_vaccine` (`vaccine_id`),
  KEY `idx_vr_batch` (`batch_id`),
  CONSTRAINT `fk_vr_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_vr_child` FOREIGN KEY (`child_id`) REFERENCES `children` (`child_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_vr_vaccine` FOREIGN KEY (`vaccine_id`) REFERENCES `vaccines` (`vaccine_id`),
  CONSTRAINT `fk_vr_batch` FOREIGN KEY (`batch_id`) REFERENCES `vaccine_batches` (`batch_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_vr_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_vr_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`appointment_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `notifications` (
  `notification_id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_id` int(11) NOT NULL,
  `type` enum('Appointment','Reminder','Booster','Late','Announcement') NOT NULL,
  `title` varchar(150) NOT NULL,
  `body` text DEFAULT NULL,
  `action_url` varchar(200) DEFAULT NULL,
  `action_label` varchar(50) DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`notification_id`),
  KEY `idx_notif_patient_read` (`patient_id`,`is_read`),
  CONSTRAINT `fk_notif_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `notification_preferences` (
  `patient_id` int(11) NOT NULL,
  `email_reminders` tinyint(1) NOT NULL DEFAULT 1,
  `sms_reminders` tinyint(1) NOT NULL DEFAULT 1,
  `booster_alerts` tinyint(1) NOT NULL DEFAULT 1,
  `clinic_news` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`patient_id`),
  CONSTRAINT `fk_pref_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `payments` (
  `payment_id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_id` int(11) NOT NULL,
  `appointment_id` int(11) DEFAULT NULL,
  `receipt_no` varchar(20) NOT NULL,
  `status` enum('Paid','Pending','Refunded') NOT NULL DEFAULT 'Pending',
  `method` varchar(30) DEFAULT NULL,
  `insurance_covered` decimal(8,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `paid_at` datetime DEFAULT NULL,
  PRIMARY KEY (`payment_id`),
  UNIQUE KEY `uq_receipt_no` (`receipt_no`),
  KEY `idx_pay_patient_status` (`patient_id`,`status`),
  CONSTRAINT `fk_pay_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_pay_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`appointment_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `payment_items` (
  `item_id` int(11) NOT NULL AUTO_INCREMENT,
  `payment_id` int(11) NOT NULL,
  `label` varchar(150) NOT NULL,
  `amount` decimal(8,2) NOT NULL,
  PRIMARY KEY (`item_id`),
  KEY `idx_item_payment` (`payment_id`),
  CONSTRAINT `fk_item_payment` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`payment_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `reviews` (
  `review_id` int(11) NOT NULL AUTO_INCREMENT,
  `appointment_id` int(11) NOT NULL COMMENT 'one review per visit; the doctor comes from the appointment',
  `patient_id` int(11) NOT NULL,
  `rating` tinyint(3) unsigned NOT NULL,
  `comment` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`review_id`),
  UNIQUE KEY `uq_review_appointment` (`appointment_id`),
  KEY `idx_review_patient` (`patient_id`),
  CONSTRAINT `chk_review_rating` CHECK (`rating` BETWEEN 1 AND 5),
  CONSTRAINT `fk_review_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`appointment_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_review_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `precheck_forms` (
  `form_id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_id` int(11) NOT NULL,
  `child_id` int(11) DEFAULT NULL,
  `vaccine_id` int(11) DEFAULT NULL,
  `has_fever` tinyint(1) NOT NULL,
  `severe_reaction` tinyint(1) NOT NULL,
  `weak_immune_system` tinyint(1) NOT NULL,
  `pregnant_or_breastfeeding` tinyint(1) DEFAULT NULL COMMENT 'NULL when the form is for a child',
  `recent_vaccine` tinyint(1) NOT NULL,
  `bleeding_disorder` tinyint(1) NOT NULL,
  `allergies` varchar(300) DEFAULT NULL,
  `medications` varchar(300) DEFAULT NULL,
  `notes` varchar(500) DEFAULT NULL,
  `submitted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`form_id`),
  KEY `idx_precheck_patient` (`patient_id`),
  CONSTRAINT `fk_precheck_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_precheck_child` FOREIGN KEY (`child_id`) REFERENCES `children` (`child_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_precheck_vaccine` FOREIGN KEY (`vaccine_id`) REFERENCES `vaccines` (`vaccine_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `contact_messages` (
  `message_id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_id` int(11) DEFAULT NULL COMMENT 'set when the sender was logged in',
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `subject` varchar(100) NOT NULL,
  `message` varchar(1000) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `status` enum('New','Read','Replied') NOT NULL DEFAULT 'New',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`message_id`),
  KEY `idx_contact_ip_time` (`ip_address`,`created_at`),
  CONSTRAINT `fk_contact_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ---------------------------------------------------------------------
-- 3. Reference data (same lists the Planner and Booking pages use)
--    Prices are demo prices in RM.
-- ---------------------------------------------------------------------

INSERT IGNORE INTO `vaccines` (`vaccine_id`, `name`, `category`, `total_doses`, `price`, `lead_days`) VALUES
(1, 'Yellow Fever', 'Travel', 1, 130.00, 10),
(2, 'Typhoid', 'Travel', 1, 95.00, 14),
(3, 'Hepatitis A', 'Travel', 2, 120.00, 14),
(4, 'Rabies', 'Travel', 3, 160.00, 28),
(5, 'Japanese Encephalitis', 'Travel', 2, 220.00, 28),
(6, 'Meningococcal ACWY', 'Travel', 1, 210.00, 10),
(7, 'Cholera', 'Travel', 2, 110.00, 14),
(8, 'Polio (IPV)', 'Travel', 1, 85.00, 28),
(9, 'BCG', 'Childhood', 1, 40.00, NULL),
(10, 'Hepatitis B', 'Childhood', 3, 60.00, NULL),
(11, 'DTaP-IPV-Hib', 'Childhood', 4, 180.00, NULL),
(12, 'Pneumococcal (PCV)', 'Childhood', 4, 230.00, NULL),
(13, 'Rotavirus', 'Childhood', 2, 150.00, NULL),
(14, 'MMR', 'Childhood', 2, 75.00, 28),
(15, 'Varicella', 'Childhood', 2, 130.00, NULL),
(16, 'Td Booster', 'Booster', 1, 55.00, 14),
(17, 'Influenza', 'Booster', 1, 70.00, 14),
(18, 'Vaccine consultation', 'Consultation', 1, 40.00, NULL);

INSERT IGNORE INTO `destinations` (`destination_id`, `country_code`, `country`, `region`) VALUES
(1, 'AU', 'Australia', 'Oceania'),
(2, 'BR', 'Brazil', 'South America'),
(3, 'KH', 'Cambodia', 'Asia'),
(4, 'CN', 'China', 'Asia'),
(5, 'EG', 'Egypt', 'Middle East'),
(6, 'GH', 'Ghana', 'Africa'),
(7, 'IN', 'India', 'Asia'),
(8, 'ID', 'Indonesia', 'Asia'),
(9, 'JP', 'Japan', 'Asia'),
(10, 'KE', 'Kenya', 'Africa'),
(11, 'NP', 'Nepal', 'Asia'),
(12, 'NG', 'Nigeria', 'Africa'),
(13, 'PE', 'Peru', 'South America'),
(14, 'PH', 'Philippines', 'Asia'),
(15, 'SA', 'Saudi Arabia', 'Middle East'),
(16, 'SG', 'Singapore', 'Asia'),
(17, 'ZA', 'South Africa', 'Africa'),
(18, 'KR', 'South Korea', 'Asia'),
(19, 'TZ', 'Tanzania', 'Africa'),
(20, 'TH', 'Thailand', 'Asia'),
(21, 'UG', 'Uganda', 'Africa'),
(22, 'GB', 'United Kingdom', 'Europe'),
(23, 'US', 'United States', 'North America'),
(24, 'VN', 'Vietnam', 'Asia');

INSERT IGNORE INTO `destination_vaccines` (`destination_id`, `vaccine_id`, `requirement`, `reason`) VALUES
(1, 17, 'Recommended', 'Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),
(1, 16, 'Recommended', 'Keeps tetanus and diphtheria cover up to date (every 10 years).'),
(1, 14, 'Recommended', 'Measles outbreaks happen worldwide. Make sure you have had two doses.'),
(2, 1, 'Recommended', 'Mosquito-borne and present in this region. One dose gives lifelong protection.'),
(2, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(2, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(2, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(2, 17, 'Recommended', 'Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),
(3, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(3, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(3, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(3, 5, 'Recommended', 'Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),
(4, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(4, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(4, 5, 'Recommended', 'Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),
(4, 17, 'Recommended', 'Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),
(4, 14, 'Recommended', 'Measles outbreaks happen worldwide. Make sure you have had two doses.'),
(5, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(5, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(5, 8, 'Recommended', 'Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),
(5, 16, 'Recommended', 'Keeps tetanus and diphtheria cover up to date (every 10 years).'),
(6, 1, 'Required', 'A yellow fever certificate is required to enter. One dose gives lifelong protection.'),
(6, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(6, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(6, 6, 'Recommended', 'Advised for the African meningitis belt, especially during the dry season.'),
(6, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(6, 8, 'Recommended', 'Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),
(7, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(7, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(7, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(7, 5, 'Recommended', 'Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),
(7, 8, 'Recommended', 'Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),
(7, 7, 'Recommended', 'Mainly for aid workers or travellers to areas with active outbreaks.'),
(8, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(8, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(8, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(8, 5, 'Recommended', 'Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),
(8, 16, 'Recommended', 'Keeps tetanus and diphtheria cover up to date (every 10 years).'),
(9, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(9, 5, 'Recommended', 'Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),
(9, 17, 'Recommended', 'Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),
(9, 14, 'Recommended', 'Measles outbreaks happen worldwide. Make sure you have had two doses.'),
(10, 1, 'Recommended', 'Mosquito-borne and present in this region. One dose gives lifelong protection.'),
(10, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(10, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(10, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(10, 6, 'Recommended', 'Advised for the African meningitis belt, especially during the dry season.'),
(10, 8, 'Recommended', 'Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),
(11, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(11, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(11, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(11, 5, 'Recommended', 'Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),
(11, 8, 'Recommended', 'Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),
(11, 6, 'Recommended', 'Advised for the African meningitis belt, especially during the dry season.'),
(12, 1, 'Required', 'A yellow fever certificate is required to enter. One dose gives lifelong protection.'),
(12, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(12, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(12, 6, 'Recommended', 'Advised for the African meningitis belt, especially during the dry season.'),
(12, 8, 'Recommended', 'Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),
(12, 7, 'Recommended', 'Mainly for aid workers or travellers to areas with active outbreaks.'),
(13, 1, 'Recommended', 'Mosquito-borne and present in this region. One dose gives lifelong protection.'),
(13, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(13, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(13, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(14, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(14, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(14, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(14, 5, 'Recommended', 'Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),
(14, 7, 'Recommended', 'Mainly for aid workers or travellers to areas with active outbreaks.'),
(15, 6, 'Required', 'Proof of vaccination is required for Hajj and Umrah visas.'),
(15, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(15, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(15, 17, 'Recommended', 'Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),
(15, 8, 'Recommended', 'Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),
(16, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(16, 16, 'Recommended', 'Keeps tetanus and diphtheria cover up to date (every 10 years).'),
(17, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(17, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(17, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(17, 16, 'Recommended', 'Keeps tetanus and diphtheria cover up to date (every 10 years).'),
(18, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(18, 17, 'Recommended', 'Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),
(18, 14, 'Recommended', 'Measles outbreaks happen worldwide. Make sure you have had two doses.'),
(19, 1, 'Recommended', 'Mosquito-borne and present in this region. One dose gives lifelong protection.'),
(19, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(19, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(19, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(19, 6, 'Recommended', 'Advised for the African meningitis belt, especially during the dry season.'),
(19, 8, 'Recommended', 'Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),
(20, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(20, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(20, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(20, 5, 'Recommended', 'Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),
(20, 16, 'Recommended', 'Keeps tetanus and diphtheria cover up to date (every 10 years).'),
(21, 1, 'Required', 'A yellow fever certificate is required to enter. One dose gives lifelong protection.'),
(21, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(21, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(21, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(21, 6, 'Recommended', 'Advised for the African meningitis belt, especially during the dry season.'),
(21, 8, 'Recommended', 'Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),
(22, 17, 'Recommended', 'Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),
(22, 16, 'Recommended', 'Keeps tetanus and diphtheria cover up to date (every 10 years).'),
(22, 14, 'Recommended', 'Measles outbreaks happen worldwide. Make sure you have had two doses.'),
(23, 17, 'Recommended', 'Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),
(23, 16, 'Recommended', 'Keeps tetanus and diphtheria cover up to date (every 10 years).'),
(23, 14, 'Recommended', 'Measles outbreaks happen worldwide. Make sure you have had two doses.'),
(24, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(24, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(24, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(24, 5, 'Recommended', 'Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),
(24, 16, 'Recommended', 'Keeps tetanus and diphtheria cover up to date (every 10 years).');

INSERT INTO `child_schedule` (`vaccine_id`, `age_months`, `dose_number`, `dose_label`, `requirement`, `reason`) VALUES
(9, 0, 1, 'Single dose', 'Required', 'Protects against severe forms of tuberculosis.'),
(10, 0, 1, 'Dose 1 of 3', 'Required', 'Protects the liver against hepatitis B infection.'),
(10, 1, 2, 'Dose 2 of 3', 'Required', 'Second dose of the hepatitis B course.'),
(11, 2, 1, 'Dose 1 of 4', 'Required', 'Covers diphtheria, tetanus, whooping cough, polio and Hib in one injection.'),
(12, 2, 1, 'Dose 1 of 4', 'Required', 'Protects against pneumonia, meningitis and ear infections.'),
(13, 2, 1, 'Dose 1 of 2', 'Recommended', 'Oral vaccine that prevents severe diarrhoea in babies.'),
(11, 3, 2, 'Dose 2 of 4', 'Required', 'Second dose of the five-in-one vaccine.'),
(12, 3, 2, 'Dose 2 of 4', 'Required', 'Second dose of the pneumococcal course.'),
(13, 3, 2, 'Dose 2 of 2', 'Recommended', 'Completes the rotavirus course.'),
(11, 5, 3, 'Dose 3 of 4', 'Required', 'Third dose of the five-in-one vaccine.'),
(12, 5, 3, 'Dose 3 of 4', 'Required', 'Third dose of the pneumococcal course.'),
(10, 6, 3, 'Dose 3 of 3', 'Required', 'Completes the hepatitis B course.'),
(17, 6, 0, 'Yearly', 'Recommended', 'Flu vaccine is advised every year from 6 months old.'),
(14, 9, 1, 'Dose 1 of 2', 'Required', 'Protects against measles, mumps and rubella.'),
(12, 12, 4, 'Booster', 'Required', 'Booster dose to keep protection strong.'),
(14, 12, 2, 'Dose 2 of 2', 'Required', 'Second dose gives long-lasting protection.'),
(15, 12, 1, 'Dose 1 of 2', 'Recommended', 'Protects against chickenpox and shingles later in life.'),
(11, 18, 4, 'Booster', 'Required', 'Booster dose of the five-in-one vaccine.'),
(15, 36, 2, 'Dose 2 of 2', 'Recommended', 'Second dose completes chickenpox protection.');
