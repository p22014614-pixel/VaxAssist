-- Unified VaxAssist database setup: doctor base schema, patient extension, shared seed data, and doctor portal additions.
-- This file replaces the separate vaxassist_db_alvan.sql, patients_extension.sql, and patients_seed.sql import steps.

-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 18, 2026 at 10:12 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `vaxassist_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `appointments`
--

CREATE TABLE `appointments` (
  `appointment_id` int(11) NOT NULL,
  `doctor_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `appointment_date` date NOT NULL,
  `time_slot` enum('08:00 AM - 10:00 AM','10:00 AM - 12:00 PM','01:00 PM - 03:00 PM','03:00 PM - 05:00 PM') NOT NULL,
  `status` enum('Scheduled','Completed','Cancelled') DEFAULT 'Scheduled',
  `symptoms_notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `appointments`
--

INSERT INTO `appointments` (`appointment_id`, `doctor_id`, `patient_id`, `appointment_date`, `time_slot`, `status`, `symptoms_notes`, `created_at`) VALUES
(1, 1, 1, '2026-10-18', '08:00 AM - 10:00 AM', 'Scheduled', 'Cardiology Routine Review & ECG', '2026-10-18 06:58:13'),
(2, 1, 2, '2026-10-18', '10:00 AM - 12:00 PM', 'Scheduled', 'Influenza Vaccine Consultation', '2026-10-18 06:58:13'),
(3, 1, 3, '2026-10-18', '01:00 PM - 03:00 PM', 'Scheduled', 'Orthopedic Joint Checkup', '2026-10-18 06:58:13');

-- --------------------------------------------------------

--
-- Table structure for table `consultation_records`
--

CREATE TABLE `consultation_records` (
  `record_id` int(11) NOT NULL,
  `doctor_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `subjective_notes` text DEFAULT NULL,
  `objective_notes` text DEFAULT NULL,
  `assessment` varchar(255) DEFAULT NULL,
  `plan` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- --------------------------------------------------------

--
-- Table structure for table `doctors`
--

CREATE TABLE `doctors` (
  `doctor_id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `dob` date NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `specialization` varchar(150) NOT NULL DEFAULT 'Cardiology & Orthopedic Medicine',
  `consultation_room` varchar(20) NOT NULL DEFAULT 'Room 304',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `doctors`
--

INSERT INTO `doctors` (`doctor_id`, `first_name`, `last_name`, `email`, `phone`, `dob`, `password_hash`, `specialization`, `consultation_room`, `created_at`) VALUES
(1, 'Alex', 'Taylor', 'try1@gmail.com', '0129998888', '1985-05-12', '$2y$10$Wbao0n/7NbEDtp2HJOEhie3ch63L8C4Gr/.THsbiZkmzmE3nOwmdm', 'Cardiology & Orthopedic Medicine', 'Room 304', '2026-10-18 06:58:13');

-- --------------------------------------------------------

--
-- Table structure for table `leave_requests`
--

CREATE TABLE `leave_requests` (
  `leave_id` int(11) NOT NULL,
  `doctor_id` int(11) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `reason` text NOT NULL,
  `status` enum('Pending','Approved','Rejected') DEFAULT 'Pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `message_id` int(11) NOT NULL,
  `doctor_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `sender_type` enum('doctor','patient') NOT NULL,
  `message_text` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`message_id`, `doctor_id`, `patient_id`, `sender_type`, `message_text`, `is_read`, `created_at`) VALUES
(1, 1, 2, 'patient', 'Hello Dr. Alex, I received my flu vaccine yesterday. My arm feels slightly warm and sore. Is this normal?', 0, '2026-10-18 06:58:13'),
(2, 1, 2, 'doctor', 'Hi Sarah, yes, mild soreness and warmth at the injection site are common post-vaccine reactions.', 1, '2026-10-18 06:58:13'),
(3, 1, 2, 'doctor', 'test 1', 0, '2026-10-18 07:48:43');

-- --------------------------------------------------------

--
-- Table structure for table `patients`
--

CREATE TABLE `patients` (
  `patient_id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `ic_passport` varchar(50) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `gender` enum('Male','Female','Other') NOT NULL DEFAULT 'Male',
  `blood_type` varchar(5) DEFAULT 'O+',
  `allergies` text DEFAULT 'Penicillin',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Links a clinic-created walk-in patient to the doctor who registered them.
CREATE TABLE IF NOT EXISTS `doctor_patient_links` (
  `doctor_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`doctor_id`, `patient_id`),
  KEY `idx_doctor_patient_links_patient` (`patient_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
--
-- Dumping data for table `patients`
--
INSERT INTO `patients` (`patient_id`, `full_name`, `ic_passport`, `phone`, `dob`, `gender`, `blood_type`, `allergies`, `created_at`) VALUES
(1, 'Michael Wong', '800820-07-5531', '0191112222', '1980-08-20', 'Male', 'O+', 'Penicillin', '2026-10-18 06:58:13'),
(2, 'Sarah Jenkins', '920315-08-6622', '0183334444', '1992-03-15', 'Female', 'A+', 'None', '2026-10-18 06:58:13'),
(3, 'Ahmad Razak', '881105-10-7711', '0175556666', '1988-11-05', 'Male', 'B+', 'Aspirin', '2026-10-18 06:58:13');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `appointments`
--
ALTER TABLE `appointments`
  ADD PRIMARY KEY (`appointment_id`),
  ADD KEY `doctor_id` (`doctor_id`),
  ADD KEY `patient_id` (`patient_id`);

--
-- Indexes for table `consultation_records`
--
ALTER TABLE `consultation_records`
  ADD PRIMARY KEY (`record_id`),
  ADD KEY `doctor_id` (`doctor_id`),
  ADD KEY `patient_id` (`patient_id`);

--
-- Indexes for table `doctors`
--
ALTER TABLE `doctors`
  ADD PRIMARY KEY (`doctor_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `leave_requests`
--
ALTER TABLE `leave_requests`
  ADD PRIMARY KEY (`leave_id`),
  ADD KEY `doctor_id` (`doctor_id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `doctor_id` (`doctor_id`),
  ADD KEY `patient_id` (`patient_id`);

--
-- Indexes for table `patients`
--
ALTER TABLE `patients`
  ADD PRIMARY KEY (`patient_id`),
  ADD UNIQUE KEY `ic_passport` (`ic_passport`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `appointments`
--
ALTER TABLE `appointments`
  MODIFY `appointment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `consultation_records`
--
ALTER TABLE `consultation_records`
  MODIFY `record_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `doctors`
--
ALTER TABLE `doctors`
  MODIFY `doctor_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `leave_requests`
--
ALTER TABLE `leave_requests`
  MODIFY `leave_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `message_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `patients`
--
ALTER TABLE `patients`
  MODIFY `patient_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `appointments`
--
ALTER TABLE `appointments`
  ADD CONSTRAINT `appointments_ibfk_1` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `appointments_ibfk_2` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE;

--
-- Constraints for table `consultation_records`
--
ALTER TABLE `consultation_records`
  ADD CONSTRAINT `consultation_records_ibfk_1` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `consultation_records_ibfk_2` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE;

--
-- Constraints for table `leave_requests`
--
ALTER TABLE `leave_requests`
  ADD CONSTRAINT `leave_requests_ibfk_1` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE CASCADE;

--
-- Constraints for table `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

-- Doctor portal profile photo fields are used by the doctor profile and navigation pages.
ALTER TABLE `doctors`
  ADD COLUMN `profile_photo` mediumblob DEFAULT NULL,
  ADD COLUMN `profile_photo_mime` varchar(50) DEFAULT NULL;

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

-- Doctor portal support fields: patient notices and pre-checks can be tied to a specific appointment owner.
ALTER TABLE `notifications`
  ADD COLUMN `doctor_id` int(11) DEFAULT NULL AFTER `patient_id`,
  ADD COLUMN `appointment_id` int(11) DEFAULT NULL AFTER `doctor_id`,
  ADD KEY `idx_notif_doctor_unread` (`doctor_id`,`is_read`),
  ADD KEY `idx_notif_appointment` (`appointment_id`),
  ADD CONSTRAINT `fk_notif_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_notif_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`appointment_id`) ON DELETE SET NULL;

ALTER TABLE `precheck_forms`
  ADD COLUMN `appointment_id` int(11) DEFAULT NULL AFTER `patient_id`,
  ADD KEY `idx_precheck_appointment` (`appointment_id`),
  ADD CONSTRAINT `fk_precheck_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`appointment_id`) ON DELETE SET NULL;

CREATE TABLE `doctor_notification_cursors` (
  `doctor_id` int(11) NOT NULL,
  `last_seen_at` datetime DEFAULT NULL,
  PRIMARY KEY (`doctor_id`),
  CONSTRAINT `fk_doctor_cursor_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =====================================================================
-- VaxAssist DEMO DATA for the patient side (local testing only)
--
-- Run AFTER vaxassist_db.sql and patients_extension.sql, once.
-- It adds demo doctors, demo patients with children, vaccination records,
-- appointments, payments, reviews and notifications so every patient page has
-- something to show. Nothing the team already has is deleted or renamed.
--
-- Logins (all local testing only):
--     demo@example.com     /  DemoPass123   (Demo Patient: child Aiden, records, history)
--     michael@example.com  /  Michael123    (the team's sample patient Michael Wong)
--     sarah@example.com    /  Sarah1234     (the team's sample patient Sarah Jenkins)
--     ahmad@example.com    /  Ahmad1234     (the team's sample patient Ahmad Razak)
-- The 8 demo doctors cannot log in (their password hash is deliberately invalid).
-- =====================================================================

USE `vaxassist_db`;

INSERT IGNORE INTO `doctors` (`first_name`, `last_name`, `email`, `phone`, `dob`, `password_hash`, `specialization`, `consultation_room`, `bio`, `years_experience`, `languages`, `keywords`) VALUES
('Aisha', 'Rahman', 'aisha.rahman@vaxassist.demo', '+60 3-0000 1000', '1985-01-01', '!', 'Travel Medicine', 'Room 101', 'Advises travellers on vaccines, malaria prevention and health planning for overseas trips.', 12, 'English, Malay', 'travel, yellow fever, typhoid, hepatitis a, rabies, malaria'),
('Daniel', 'Lim', 'daniel.lim@vaxassist.demo', '+60 3-0000 1001', '1985-01-01', '!', 'Paediatrics', 'Room 102', 'Looks after babies and children, including growth checks and the childhood vaccination schedule.', 9, 'English, Mandarin', 'child, baby, fever, mmr, booster, rotavirus, bcg'),
('Priya', 'Nair', 'priya.nair@vaxassist.demo', '+60 3-0000 1002', '1985-01-01', '!', 'General Practice', 'Room 103', 'Family doctor for everyday health concerns, check-ups and vaccine advice for all ages.', 15, 'English, Tamil, Malay', 'cough, cold, fever, flu, influenza, check-up, vaccine, tetanus'),
('Ahmad', 'Farid', 'ahmad.farid@vaxassist.demo', '+60 3-0000 1003', '1985-01-01', '!', 'Internal Medicine', 'Room 104', 'Manages long-term conditions such as diabetes, blood pressure and liver health.', 18, 'English, Malay', 'diabetes, blood pressure, hepatitis b, liver, fatigue'),
('Mei', 'Ling Tan', 'mei.ling.tan@vaxassist.demo', '+60 3-0000 1004', '1985-01-01', '!', 'Infectious Diseases', 'Room 105', 'Treats infections and advises on vaccine-preventable diseases, outbreaks and post-exposure care.', 8, 'English, Mandarin', 'infection, hepatitis b, rabies, post-exposure, measles, dengue, allergy, vaccine reaction'),
('Rajesh', 'Kumar', 'rajesh.kumar@vaxassist.demo', '+60 3-0000 1005', '1985-01-01', '!', 'Preventive Medicine', 'Room 106', 'Plans adult immunisation, health screening and workplace or community vaccination programmes.', 14, 'English, Hindi', 'adult vaccine, screening, influenza, tetanus, workplace, pneumococcal, booster'),
('Siti', 'Aminah', 'siti.aminah@vaxassist.demo', '+60 3-0000 1006', '1985-01-01', '!', 'Paediatrics', 'Room 107', 'Child health and development, with a special interest in newborn care and immunisation.', 6, 'English, Malay', 'newborn, baby, child, hepatitis b, dtap, pneumococcal, vaccine'),
('Jason', 'Wong', 'jason.wong@vaxassist.demo', '+60 3-0000 1007', '1985-01-01', '!', 'General Practice', 'Room 108', 'Walk-in friendly family doctor offering vaccinations, travel health letters and minor procedures.', 10, 'English, Mandarin, Cantonese', 'vaccine, travel, typhoid, hepatitis a, cough, fever, headache');

INSERT IGNORE INTO `doctor_availability` (`doctor_id`, `weekday`) VALUES
((SELECT doctor_id FROM doctors WHERE email = 'aisha.rahman@vaxassist.demo'), 1),
((SELECT doctor_id FROM doctors WHERE email = 'aisha.rahman@vaxassist.demo'), 3),
((SELECT doctor_id FROM doctors WHERE email = 'aisha.rahman@vaxassist.demo'), 5),
((SELECT doctor_id FROM doctors WHERE email = 'daniel.lim@vaxassist.demo'), 1),
((SELECT doctor_id FROM doctors WHERE email = 'daniel.lim@vaxassist.demo'), 2),
((SELECT doctor_id FROM doctors WHERE email = 'daniel.lim@vaxassist.demo'), 4),
((SELECT doctor_id FROM doctors WHERE email = 'priya.nair@vaxassist.demo'), 1),
((SELECT doctor_id FROM doctors WHERE email = 'priya.nair@vaxassist.demo'), 2),
((SELECT doctor_id FROM doctors WHERE email = 'priya.nair@vaxassist.demo'), 3),
((SELECT doctor_id FROM doctors WHERE email = 'priya.nair@vaxassist.demo'), 4),
((SELECT doctor_id FROM doctors WHERE email = 'priya.nair@vaxassist.demo'), 5),
((SELECT doctor_id FROM doctors WHERE email = 'ahmad.farid@vaxassist.demo'), 2),
((SELECT doctor_id FROM doctors WHERE email = 'ahmad.farid@vaxassist.demo'), 3),
((SELECT doctor_id FROM doctors WHERE email = 'ahmad.farid@vaxassist.demo'), 5),
((SELECT doctor_id FROM doctors WHERE email = 'mei.ling.tan@vaxassist.demo'), 2),
((SELECT doctor_id FROM doctors WHERE email = 'mei.ling.tan@vaxassist.demo'), 4),
((SELECT doctor_id FROM doctors WHERE email = 'rajesh.kumar@vaxassist.demo'), 1),
((SELECT doctor_id FROM doctors WHERE email = 'rajesh.kumar@vaxassist.demo'), 3),
((SELECT doctor_id FROM doctors WHERE email = 'siti.aminah@vaxassist.demo'), 3),
((SELECT doctor_id FROM doctors WHERE email = 'siti.aminah@vaxassist.demo'), 4),
((SELECT doctor_id FROM doctors WHERE email = 'siti.aminah@vaxassist.demo'), 5),
((SELECT doctor_id FROM doctors WHERE email = 'jason.wong@vaxassist.demo'), 1),
((SELECT doctor_id FROM doctors WHERE email = 'jason.wong@vaxassist.demo'), 2),
((SELECT doctor_id FROM doctors WHERE email = 'jason.wong@vaxassist.demo'), 3),
((SELECT doctor_id FROM doctors WHERE email = 'jason.wong@vaxassist.demo'), 4),
((SELECT doctor_id FROM doctors WHERE email = 'jason.wong@vaxassist.demo'), 5);

INSERT IGNORE INTO `patients` (`full_name`, `email`, `password_hash`, `phone`, `dob`, `gender`, `blood_type`, `allergies`, `height_cm`, `weight_kg`) VALUES
('Demo Patient', 'demo@example.com', '$2y$10$nVyjH6mh7qwLVmsX1rVc4eibjDKCNBMCeyiiW48s0Lx.Aw8iOMGyi', '+60 12-345 6789', '1998-05-14', 'Female', 'O+', NULL, 165, 58.0);

UPDATE `patients` SET `email` = 'michael@example.com', `password_hash` = '$2y$10$kYVmuR.B4vEXGw6L6i8CGuN0TzuT9zmWe2YpWYo8SrPLdecU6Uswm' WHERE `full_name` = 'Michael Wong' AND `email` IS NULL;
UPDATE `patients` SET `email` = 'sarah@example.com', `password_hash` = '$2y$10$6vGcJSEjmZ6ObZ60i3UHNe7Z/NOHebH50mKDTXE1v1YpMV/HO1Jb2' WHERE `full_name` = 'Sarah Jenkins' AND `email` IS NULL;
UPDATE `patients` SET `email` = 'ahmad@example.com', `password_hash` = '$2y$10$oDqglPVErvmxxp6R2b4wJOQLbsS2de9SMSifjAwb2wXVhEaPTfr32' WHERE `full_name` = 'Ahmad Razak' AND `email` IS NULL;

INSERT IGNORE INTO `notification_preferences` (`patient_id`) SELECT patient_id FROM patients WHERE email IN ('demo@example.com', 'michael@example.com', 'sarah@example.com', 'ahmad@example.com');

INSERT INTO `patient_health_items` (`patient_id`, `item_type`, `name`) VALUES
((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), 'Allergy', 'Penicillin'), ((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), 'Allergy', 'Egg'), ((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), 'Condition', 'Asthma'), ((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), 'Medication', 'Salbutamol inhaler'),
((SELECT patient_id FROM patients WHERE email = 'michael@example.com'), 'Allergy', 'Latex'), ((SELECT patient_id FROM patients WHERE email = 'sarah@example.com'), 'Condition', 'Hay fever');

INSERT INTO `children` (`patient_id`, `first_name`, `dob`, `gender`) VALUES
((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), 'Aiden', CURDATE() - INTERVAL 430 DAY, 'Male'),
((SELECT patient_id FROM patients WHERE email = 'michael@example.com'), 'Noah', CURDATE() - INTERVAL 900 DAY, 'Male');

INSERT IGNORE INTO `vaccine_batches` (`vaccine_id`, `batch_number`, `manufacturer`, `expiry_date`, `quantity_in_stock`) VALUES
((SELECT vaccine_id FROM vaccines WHERE name = 'Typhoid'), 'TY-22914B', 'Demo Pharma', CURDATE() + INTERVAL 18 MONTH, 100),
((SELECT vaccine_id FROM vaccines WHERE name = 'Hepatitis A'), 'HA-80731C', 'Demo Pharma', CURDATE() + INTERVAL 18 MONTH, 100),
((SELECT vaccine_id FROM vaccines WHERE name = 'Influenza'), 'FLU-5519A', 'Demo Pharma', CURDATE() + INTERVAL 18 MONTH, 100),
((SELECT vaccine_id FROM vaccines WHERE name = 'Td Booster'), 'TD-30276D', 'Demo Pharma', CURDATE() + INTERVAL 18 MONTH, 100),
((SELECT vaccine_id FROM vaccines WHERE name = 'BCG'), 'BCG-1102', 'Demo Pharma', CURDATE() + INTERVAL 18 MONTH, 100),
((SELECT vaccine_id FROM vaccines WHERE name = 'Hepatitis B'), 'HB-77410', 'Demo Pharma', CURDATE() + INTERVAL 18 MONTH, 100),
((SELECT vaccine_id FROM vaccines WHERE name = 'Rotavirus'), 'RV-4408', 'Demo Pharma', CURDATE() + INTERVAL 18 MONTH, 100),
((SELECT vaccine_id FROM vaccines WHERE name = 'Pneumococcal (PCV)'), 'PCV-9912', 'Demo Pharma', CURDATE() + INTERVAL 18 MONTH, 100),
((SELECT vaccine_id FROM vaccines WHERE name = 'DTaP-IPV-Hib'), 'DTP-6063', 'Demo Pharma', CURDATE() + INTERVAL 18 MONTH, 100),
((SELECT vaccine_id FROM vaccines WHERE name = 'Hepatitis B'), 'HB-5521', 'Demo Pharma', CURDATE() + INTERVAL 18 MONTH, 100),
((SELECT vaccine_id FROM vaccines WHERE name = 'DTaP-IPV-Hib'), 'DTP-5110', 'Demo Pharma', CURDATE() + INTERVAL 18 MONTH, 100),
((SELECT vaccine_id FROM vaccines WHERE name = 'BCG'), 'BCG-0991', 'Demo Pharma', CURDATE() + INTERVAL 18 MONTH, 100),
((SELECT vaccine_id FROM vaccines WHERE name = 'Hepatitis A'), 'HA-9902', 'Demo Pharma', CURDATE() + INTERVAL 18 MONTH, 100),
((SELECT vaccine_id FROM vaccines WHERE name = 'Typhoid'), 'TY-30011', 'Demo Pharma', CURDATE() + INTERVAL 18 MONTH, 100);

INSERT INTO `vaccination_records` (`patient_id`, `child_id`, `vaccine_id`, `batch_id`, `doctor_id`, `dose_number`, `date_given`, `next_dose_date`, `notes`) VALUES
((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Typhoid'), (SELECT batch_id FROM vaccine_batches WHERE batch_number = 'TY-22914B'), (SELECT doctor_id FROM doctors WHERE email = 'aisha.rahman@vaxassist.demo'), 1, CURDATE() - INTERVAL 12 DAY, NULL, 'Booster needed after 3 years if still travelling.'),
((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Hepatitis A'), (SELECT batch_id FROM vaccine_batches WHERE batch_number = 'HA-80731C'), (SELECT doctor_id FROM doctors WHERE email = 'jason.wong@vaxassist.demo'), 1, CURDATE() - INTERVAL 41 DAY, CURDATE() + INTERVAL 40 DAY, 'Second dose 6 to 12 months after the first.'),
((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Influenza'), (SELECT batch_id FROM vaccine_batches WHERE batch_number = 'FLU-5519A'), (SELECT doctor_id FROM doctors WHERE email = 'priya.nair@vaxassist.demo'), 1, CURDATE() - INTERVAL 210 DAY, CURDATE() + INTERVAL 155 DAY, NULL),
((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Td Booster'), (SELECT batch_id FROM vaccine_batches WHERE batch_number = 'TD-30276D'), (SELECT doctor_id FROM doctors WHERE email = 'priya.nair@vaxassist.demo'), 1, CURDATE() - INTERVAL 1100 DAY, CURDATE() + INTERVAL 2550 DAY, 'Repeat every 10 years.'),
((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), (SELECT child_id FROM children WHERE first_name = 'Aiden' AND patient_id = (SELECT patient_id FROM patients WHERE email = 'demo@example.com') LIMIT 1), (SELECT vaccine_id FROM vaccines WHERE name = 'BCG'), (SELECT batch_id FROM vaccine_batches WHERE batch_number = 'BCG-1102'), (SELECT doctor_id FROM doctors WHERE email = 'siti.aminah@vaxassist.demo'), 1, CURDATE() - INTERVAL 430 DAY, NULL, NULL),
((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), (SELECT child_id FROM children WHERE first_name = 'Aiden' AND patient_id = (SELECT patient_id FROM patients WHERE email = 'demo@example.com') LIMIT 1), (SELECT vaccine_id FROM vaccines WHERE name = 'Hepatitis B'), (SELECT batch_id FROM vaccine_batches WHERE batch_number = 'HB-77410'), (SELECT doctor_id FROM doctors WHERE email = 'daniel.lim@vaxassist.demo'), 3, CURDATE() - INTERVAL 250 DAY, NULL, 'Course complete.'),
((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), (SELECT child_id FROM children WHERE first_name = 'Aiden' AND patient_id = (SELECT patient_id FROM patients WHERE email = 'demo@example.com') LIMIT 1), (SELECT vaccine_id FROM vaccines WHERE name = 'Rotavirus'), (SELECT batch_id FROM vaccine_batches WHERE batch_number = 'RV-4408'), (SELECT doctor_id FROM doctors WHERE email = 'daniel.lim@vaxassist.demo'), 2, CURDATE() - INTERVAL 305 DAY, NULL, 'Course complete.'),
((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), (SELECT child_id FROM children WHERE first_name = 'Aiden' AND patient_id = (SELECT patient_id FROM patients WHERE email = 'demo@example.com') LIMIT 1), (SELECT vaccine_id FROM vaccines WHERE name = 'Pneumococcal (PCV)'), (SELECT batch_id FROM vaccine_batches WHERE batch_number = 'PCV-9912'), (SELECT doctor_id FROM doctors WHERE email = 'daniel.lim@vaxassist.demo'), 2, CURDATE() - INTERVAL 300 DAY, CURDATE() - INTERVAL 10 DAY, 'Booster dose at 12 months.'),
((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), (SELECT child_id FROM children WHERE first_name = 'Aiden' AND patient_id = (SELECT patient_id FROM patients WHERE email = 'demo@example.com') LIMIT 1), (SELECT vaccine_id FROM vaccines WHERE name = 'DTaP-IPV-Hib'), (SELECT batch_id FROM vaccine_batches WHERE batch_number = 'DTP-6063'), (SELECT doctor_id FROM doctors WHERE email = 'siti.aminah@vaxassist.demo'), 3, CURDATE() - INTERVAL 30 DAY, CURDATE() + INTERVAL 105 DAY, 'Booster due at 18 months.'),
((SELECT patient_id FROM patients WHERE email = 'michael@example.com'), (SELECT child_id FROM children WHERE first_name = 'Noah' AND patient_id = (SELECT patient_id FROM patients WHERE email = 'michael@example.com') LIMIT 1), (SELECT vaccine_id FROM vaccines WHERE name = 'BCG'), (SELECT batch_id FROM vaccine_batches WHERE batch_number = 'BCG-0991'), (SELECT doctor_id FROM doctors WHERE email = 'siti.aminah@vaxassist.demo'), 1, CURDATE() - INTERVAL 880 DAY, NULL, NULL),
((SELECT patient_id FROM patients WHERE email = 'michael@example.com'), (SELECT child_id FROM children WHERE first_name = 'Noah' AND patient_id = (SELECT patient_id FROM patients WHERE email = 'michael@example.com') LIMIT 1), (SELECT vaccine_id FROM vaccines WHERE name = 'Hepatitis B'), (SELECT batch_id FROM vaccine_batches WHERE batch_number = 'HB-5521'), (SELECT doctor_id FROM doctors WHERE email = 'siti.aminah@vaxassist.demo'), 1, CURDATE() - INTERVAL 880 DAY, NULL, NULL),
((SELECT patient_id FROM patients WHERE email = 'michael@example.com'), (SELECT child_id FROM children WHERE first_name = 'Noah' AND patient_id = (SELECT patient_id FROM patients WHERE email = 'michael@example.com') LIMIT 1), (SELECT vaccine_id FROM vaccines WHERE name = 'Hepatitis B'), (SELECT batch_id FROM vaccine_batches WHERE batch_number = 'HB-5521'), (SELECT doctor_id FROM doctors WHERE email = 'daniel.lim@vaxassist.demo'), 2, CURDATE() - INTERVAL 850 DAY, NULL, NULL),
((SELECT patient_id FROM patients WHERE email = 'michael@example.com'), (SELECT child_id FROM children WHERE first_name = 'Noah' AND patient_id = (SELECT patient_id FROM patients WHERE email = 'michael@example.com') LIMIT 1), (SELECT vaccine_id FROM vaccines WHERE name = 'DTaP-IPV-Hib'), (SELECT batch_id FROM vaccine_batches WHERE batch_number = 'DTP-5110'), (SELECT doctor_id FROM doctors WHERE email = 'daniel.lim@vaxassist.demo'), 1, CURDATE() - INTERVAL 820 DAY, CURDATE() - INTERVAL 700 DAY, 'Dose 2 was due about two months later.'),
((SELECT patient_id FROM patients WHERE email = 'sarah@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Hepatitis A'), (SELECT batch_id FROM vaccine_batches WHERE batch_number = 'HA-9902'), (SELECT doctor_id FROM doctors WHERE email = 'aisha.rahman@vaxassist.demo'), 1, CURDATE() - INTERVAL 20 DAY, CURDATE() + INTERVAL 160 DAY, 'Second dose 6 months after the first.'),
((SELECT patient_id FROM patients WHERE email = 'sarah@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Typhoid'), (SELECT batch_id FROM vaccine_batches WHERE batch_number = 'TY-30011'), (SELECT doctor_id FROM doctors WHERE email = 'aisha.rahman@vaxassist.demo'), 1, CURDATE() - INTERVAL 20 DAY, NULL, NULL);

-- Demo appointments are tagged with the seed marker in symptoms_notes only where needed; ids are looked up by patient/doctor/date below.
INSERT INTO `appointments` (`doctor_id`, `patient_id`, `child_id`, `vaccine_id`, `appointment_date`, `appointment_time`, `time_slot`, `status`, `symptoms_notes`, `cancel_reason`) VALUES
((SELECT doctor_id FROM doctors WHERE email = 'aisha.rahman@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'demo@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Yellow Fever'), ((CURDATE() + INTERVAL 3 DAY) + INTERVAL MOD(0 - WEEKDAY((CURDATE() + INTERVAL 3 DAY)) + 7, 7) DAY), '10:00:00', '10:00 AM - 12:00 PM', 'Scheduled', 'Travelling to Ghana next month.', NULL),
((SELECT doctor_id FROM doctors WHERE email = 'daniel.lim@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'demo@example.com'), (SELECT child_id FROM children WHERE first_name = 'Aiden' AND patient_id = (SELECT patient_id FROM patients WHERE email = 'demo@example.com') LIMIT 1), (SELECT vaccine_id FROM vaccines WHERE name = 'MMR'), ((CURDATE() + INTERVAL 9 DAY) + INTERVAL MOD(0 - WEEKDAY((CURDATE() + INTERVAL 9 DAY)) + 7, 7) DAY), '14:30:00', '01:00 PM - 03:00 PM', 'Scheduled', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'priya.nair@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'demo@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Influenza'), ((CURDATE() + INTERVAL 20 DAY) + INTERVAL MOD(0 - WEEKDAY((CURDATE() + INTERVAL 20 DAY)) + 7, 7) DAY), '09:30:00', '08:00 AM - 10:00 AM', 'Scheduled', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'aisha.rahman@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'demo@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Typhoid'), CURDATE() - INTERVAL 12 DAY, '11:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'siti.aminah@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'demo@example.com'), (SELECT child_id FROM children WHERE first_name = 'Aiden' AND patient_id = (SELECT patient_id FROM patients WHERE email = 'demo@example.com') LIMIT 1), (SELECT vaccine_id FROM vaccines WHERE name = 'DTaP-IPV-Hib'), CURDATE() - INTERVAL 30 DAY, '15:00:00', '03:00 PM - 05:00 PM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'jason.wong@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'demo@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Hepatitis A'), CURDATE() - INTERVAL 41 DAY, '10:30:00', '10:00 AM - 12:00 PM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'jason.wong@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'demo@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Hepatitis A'), CURDATE() - INTERVAL 18 DAY, '11:30:00', '10:00 AM - 12:00 PM', 'Cancelled', NULL, 'Change of plans.'),
((SELECT doctor_id FROM doctors WHERE email = 'priya.nair@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'demo@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Td Booster'), CURDATE() - INTERVAL 60 DAY, '16:00:00', '03:00 PM - 05:00 PM', 'Missed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'priya.nair@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'demo@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Influenza'), CURDATE() - INTERVAL 210 DAY, '09:00:00', '08:00 AM - 10:00 AM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'priya.nair@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'michael@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Influenza'), ((CURDATE() + INTERVAL 5 DAY) + INTERVAL MOD(0 - WEEKDAY((CURDATE() + INTERVAL 5 DAY)) + 7, 7) DAY), '10:30:00', '10:00 AM - 12:00 PM', 'Scheduled', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'daniel.lim@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'michael@example.com'), (SELECT child_id FROM children WHERE first_name = 'Noah' AND patient_id = (SELECT patient_id FROM patients WHERE email = 'michael@example.com') LIMIT 1), (SELECT vaccine_id FROM vaccines WHERE name = 'MMR'), CURDATE() - INTERVAL 60 DAY, '14:00:00', '01:00 PM - 03:00 PM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'aisha.rahman@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'sarah@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Yellow Fever'), ((CURDATE() + INTERVAL 7 DAY) + INTERVAL MOD(0 - WEEKDAY((CURDATE() + INTERVAL 7 DAY)) + 7, 7) DAY), '09:00:00', '08:00 AM - 10:00 AM', 'Scheduled', 'Trip to Kenya in six weeks.', NULL),
((SELECT doctor_id FROM doctors WHERE email = 'jason.wong@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Td Booster'), ((CURDATE() + INTERVAL 2 DAY) + INTERVAL MOD(0 - WEEKDAY((CURDATE() + INTERVAL 2 DAY)) + 7, 7) DAY), '15:30:00', '03:00 PM - 05:00 PM', 'Scheduled', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'aisha.rahman@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'michael@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Typhoid'), CURDATE() - INTERVAL 90 DAY, '09:00:00', '08:00 AM - 10:00 AM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'aisha.rahman@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'sarah@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Typhoid'), CURDATE() - INTERVAL 120 DAY, '10:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'aisha.rahman@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Typhoid'), CURDATE() - INTERVAL 150 DAY, '11:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'daniel.lim@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'michael@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'MMR'), CURDATE() - INTERVAL 97 DAY, '09:00:00', '08:00 AM - 10:00 AM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'daniel.lim@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'sarah@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'MMR'), CURDATE() - INTERVAL 127 DAY, '10:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'daniel.lim@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'MMR'), CURDATE() - INTERVAL 157 DAY, '11:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'priya.nair@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'michael@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Influenza'), CURDATE() - INTERVAL 104 DAY, '09:00:00', '08:00 AM - 10:00 AM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'priya.nair@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'sarah@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Influenza'), CURDATE() - INTERVAL 134 DAY, '10:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'priya.nair@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Influenza'), CURDATE() - INTERVAL 164 DAY, '11:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'ahmad.farid@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'michael@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Td Booster'), CURDATE() - INTERVAL 111 DAY, '09:00:00', '08:00 AM - 10:00 AM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'ahmad.farid@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'sarah@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Td Booster'), CURDATE() - INTERVAL 141 DAY, '10:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'ahmad.farid@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Td Booster'), CURDATE() - INTERVAL 171 DAY, '11:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'mei.ling.tan@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'michael@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Hepatitis B'), CURDATE() - INTERVAL 118 DAY, '09:00:00', '08:00 AM - 10:00 AM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'mei.ling.tan@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'sarah@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Hepatitis B'), CURDATE() - INTERVAL 148 DAY, '10:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'mei.ling.tan@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Hepatitis B'), CURDATE() - INTERVAL 178 DAY, '11:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'rajesh.kumar@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'michael@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Td Booster'), CURDATE() - INTERVAL 125 DAY, '09:00:00', '08:00 AM - 10:00 AM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'rajesh.kumar@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'sarah@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Td Booster'), CURDATE() - INTERVAL 155 DAY, '10:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'rajesh.kumar@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Td Booster'), CURDATE() - INTERVAL 185 DAY, '11:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'siti.aminah@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'michael@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'MMR'), CURDATE() - INTERVAL 132 DAY, '09:00:00', '08:00 AM - 10:00 AM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'siti.aminah@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'sarah@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'MMR'), CURDATE() - INTERVAL 162 DAY, '10:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'siti.aminah@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'MMR'), CURDATE() - INTERVAL 192 DAY, '11:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'jason.wong@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'michael@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Influenza'), CURDATE() - INTERVAL 139 DAY, '09:00:00', '08:00 AM - 10:00 AM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'jason.wong@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'sarah@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Influenza'), CURDATE() - INTERVAL 169 DAY, '10:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, NULL),
((SELECT doctor_id FROM doctors WHERE email = 'jason.wong@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com'), NULL, (SELECT vaccine_id FROM vaccines WHERE name = 'Influenza'), CURDATE() - INTERVAL 199 DAY, '11:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, NULL);

INSERT INTO `payments` (`patient_id`, `appointment_id`, `receipt_no`, `status`, `method`, `insurance_covered`, `created_at`, `paid_at`) VALUES ((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), (SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'demo@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'aisha.rahman@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Typhoid') AND appointment_date = CURDATE() - INTERVAL 12 DAY AND appointment_time = '11:00:00' LIMIT 1), CONCAT('T', LEFT(REPLACE(UUID(), '-', ''), 15)), 'Paid', 'Credit card', 0, CURDATE() - INTERVAL 12 DAY + INTERVAL 0 DAY, CURDATE() - INTERVAL 12 DAY + INTERVAL 10 HOUR);
SET @pay = LAST_INSERT_ID();
UPDATE `payments` SET `receipt_no` = CONCAT('VA-', YEAR(CURDATE()), '-', LPAD(@pay, 4, '0')) WHERE `payment_id` = @pay;
INSERT INTO `payment_items` (`payment_id`, `label`, `amount`) VALUES (@pay, 'Typhoid vaccine', 95), (@pay, 'Consultation fee', 40);
INSERT INTO `payments` (`patient_id`, `appointment_id`, `receipt_no`, `status`, `method`, `insurance_covered`, `created_at`, `paid_at`) VALUES ((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), (SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'demo@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'jason.wong@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Hepatitis A') AND appointment_date = CURDATE() - INTERVAL 41 DAY AND appointment_time = '10:30:00' LIMIT 1), CONCAT('T', LEFT(REPLACE(UUID(), '-', ''), 15)), 'Paid', 'Insurance + e-wallet', 100, CURDATE() - INTERVAL 41 DAY + INTERVAL 0 DAY, CURDATE() - INTERVAL 41 DAY + INTERVAL 10 HOUR);
SET @pay = LAST_INSERT_ID();
UPDATE `payments` SET `receipt_no` = CONCAT('VA-', YEAR(CURDATE()), '-', LPAD(@pay, 4, '0')) WHERE `payment_id` = @pay;
INSERT INTO `payment_items` (`payment_id`, `label`, `amount`) VALUES (@pay, 'Hepatitis A vaccine (dose 1)', 120), (@pay, 'Consultation fee', 40);
INSERT INTO `payments` (`patient_id`, `appointment_id`, `receipt_no`, `status`, `method`, `insurance_covered`, `created_at`, `paid_at`) VALUES ((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), (SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'demo@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'siti.aminah@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'DTaP-IPV-Hib') AND appointment_date = CURDATE() - INTERVAL 30 DAY AND appointment_time = '15:00:00' LIMIT 1), CONCAT('T', LEFT(REPLACE(UUID(), '-', ''), 15)), 'Paid', 'E-wallet', 0, CURDATE() - INTERVAL 30 DAY + INTERVAL 0 DAY, CURDATE() - INTERVAL 30 DAY + INTERVAL 10 HOUR);
SET @pay = LAST_INSERT_ID();
UPDATE `payments` SET `receipt_no` = CONCAT('VA-', YEAR(CURDATE()), '-', LPAD(@pay, 4, '0')) WHERE `payment_id` = @pay;
INSERT INTO `payment_items` (`payment_id`, `label`, `amount`) VALUES (@pay, 'DTaP-IPV-Hib (dose 3)', 180), (@pay, 'Consultation fee', 40);
INSERT INTO `payments` (`patient_id`, `appointment_id`, `receipt_no`, `status`, `method`, `insurance_covered`, `created_at`, `paid_at`) VALUES ((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), (SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'demo@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'priya.nair@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Influenza') AND appointment_date = CURDATE() - INTERVAL 210 DAY AND appointment_time = '09:00:00' LIMIT 1), CONCAT('T', LEFT(REPLACE(UUID(), '-', ''), 15)), 'Paid', 'Credit card', 0, CURDATE() - INTERVAL 210 DAY + INTERVAL 0 DAY, CURDATE() - INTERVAL 210 DAY + INTERVAL 10 HOUR);
SET @pay = LAST_INSERT_ID();
UPDATE `payments` SET `receipt_no` = CONCAT('VA-', YEAR(CURDATE()), '-', LPAD(@pay, 4, '0')) WHERE `payment_id` = @pay;
INSERT INTO `payment_items` (`payment_id`, `label`, `amount`) VALUES (@pay, 'Influenza vaccine', 70), (@pay, 'Consultation fee', 40);
INSERT INTO `payments` (`patient_id`, `appointment_id`, `receipt_no`, `status`, `method`, `insurance_covered`, `created_at`, `paid_at`) VALUES ((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), (SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'demo@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'aisha.rahman@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Yellow Fever') AND appointment_date = ((CURDATE() + INTERVAL 3 DAY) + INTERVAL MOD(0 - WEEKDAY((CURDATE() + INTERVAL 3 DAY)) + 7, 7) DAY) AND appointment_time = '10:00:00' LIMIT 1), CONCAT('T', LEFT(REPLACE(UUID(), '-', ''), 15)), 'Pending', NULL, 0, NOW(), NULL);
SET @pay = LAST_INSERT_ID();
UPDATE `payments` SET `receipt_no` = CONCAT('VA-', YEAR(CURDATE()), '-', LPAD(@pay, 4, '0')) WHERE `payment_id` = @pay;
INSERT INTO `payment_items` (`payment_id`, `label`, `amount`) VALUES (@pay, 'Yellow Fever vaccine', 130), (@pay, 'Consultation fee', 40);
INSERT INTO `payments` (`patient_id`, `appointment_id`, `receipt_no`, `status`, `method`, `insurance_covered`, `created_at`, `paid_at`) VALUES ((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), (SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'demo@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'priya.nair@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Influenza') AND appointment_date = ((CURDATE() + INTERVAL 20 DAY) + INTERVAL MOD(0 - WEEKDAY((CURDATE() + INTERVAL 20 DAY)) + 7, 7) DAY) AND appointment_time = '09:30:00' LIMIT 1), CONCAT('T', LEFT(REPLACE(UUID(), '-', ''), 15)), 'Pending', NULL, 0, NOW(), NULL);
SET @pay = LAST_INSERT_ID();
UPDATE `payments` SET `receipt_no` = CONCAT('VA-', YEAR(CURDATE()), '-', LPAD(@pay, 4, '0')) WHERE `payment_id` = @pay;
INSERT INTO `payment_items` (`payment_id`, `label`, `amount`) VALUES (@pay, 'Influenza vaccine', 70), (@pay, 'Consultation fee', 40);
INSERT INTO `payments` (`patient_id`, `appointment_id`, `receipt_no`, `status`, `method`, `insurance_covered`, `created_at`, `paid_at`) VALUES ((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), (SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'demo@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'jason.wong@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Hepatitis A') AND appointment_date = CURDATE() - INTERVAL 18 DAY AND appointment_time = '11:30:00' LIMIT 1), CONCAT('T', LEFT(REPLACE(UUID(), '-', ''), 15)), 'Refunded', 'Credit card', 0, CURDATE() - INTERVAL 18 DAY + INTERVAL 0 DAY, CURDATE() - INTERVAL 18 DAY + INTERVAL 10 HOUR);
SET @pay = LAST_INSERT_ID();
UPDATE `payments` SET `receipt_no` = CONCAT('VA-', YEAR(CURDATE()), '-', LPAD(@pay, 4, '0')) WHERE `payment_id` = @pay;
INSERT INTO `payment_items` (`payment_id`, `label`, `amount`) VALUES (@pay, 'Booking deposit (refunded)', 20);
INSERT INTO `payments` (`patient_id`, `appointment_id`, `receipt_no`, `status`, `method`, `insurance_covered`, `created_at`, `paid_at`) VALUES ((SELECT patient_id FROM patients WHERE email = 'michael@example.com'), (SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'michael@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'priya.nair@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Influenza') AND appointment_date = ((CURDATE() + INTERVAL 5 DAY) + INTERVAL MOD(0 - WEEKDAY((CURDATE() + INTERVAL 5 DAY)) + 7, 7) DAY) AND appointment_time = '10:30:00' LIMIT 1), CONCAT('T', LEFT(REPLACE(UUID(), '-', ''), 15)), 'Pending', NULL, 0, NOW(), NULL);
SET @pay = LAST_INSERT_ID();
UPDATE `payments` SET `receipt_no` = CONCAT('VA-', YEAR(CURDATE()), '-', LPAD(@pay, 4, '0')) WHERE `payment_id` = @pay;
INSERT INTO `payment_items` (`payment_id`, `label`, `amount`) VALUES (@pay, 'Influenza vaccine', 70), (@pay, 'Consultation fee', 40);
INSERT INTO `payments` (`patient_id`, `appointment_id`, `receipt_no`, `status`, `method`, `insurance_covered`, `created_at`, `paid_at`) VALUES ((SELECT patient_id FROM patients WHERE email = 'sarah@example.com'), (SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'sarah@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'aisha.rahman@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Yellow Fever') AND appointment_date = ((CURDATE() + INTERVAL 7 DAY) + INTERVAL MOD(0 - WEEKDAY((CURDATE() + INTERVAL 7 DAY)) + 7, 7) DAY) AND appointment_time = '09:00:00' LIMIT 1), CONCAT('T', LEFT(REPLACE(UUID(), '-', ''), 15)), 'Paid', 'Online banking', 0, CURDATE() - INTERVAL 1 DAY + INTERVAL 0 DAY, CURDATE() - INTERVAL 1 DAY + INTERVAL 10 HOUR);
SET @pay = LAST_INSERT_ID();
UPDATE `payments` SET `receipt_no` = CONCAT('VA-', YEAR(CURDATE()), '-', LPAD(@pay, 4, '0')) WHERE `payment_id` = @pay;
INSERT INTO `payment_items` (`payment_id`, `label`, `amount`) VALUES (@pay, 'Yellow Fever vaccine', 130), (@pay, 'Consultation fee', 40);

INSERT INTO `reviews` (`appointment_id`, `patient_id`, `rating`, `comment`) VALUES
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'michael@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'aisha.rahman@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Typhoid') AND appointment_date = CURDATE() - INTERVAL 90 DAY AND appointment_time = '09:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'michael@example.com'), 5, 'Very gentle and clear.'),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'sarah@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'aisha.rahman@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Typhoid') AND appointment_date = CURDATE() - INTERVAL 120 DAY AND appointment_time = '10:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'sarah@example.com'), 5, 'Explained everything well.'),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'aisha.rahman@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Typhoid') AND appointment_date = CURDATE() - INTERVAL 150 DAY AND appointment_time = '11:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com'), 5, 'Quick and friendly.'),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'michael@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'daniel.lim@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'MMR') AND appointment_date = CURDATE() - INTERVAL 97 DAY AND appointment_time = '09:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'michael@example.com'), 5, 'Explained everything well.'),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'sarah@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'daniel.lim@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'MMR') AND appointment_date = CURDATE() - INTERVAL 127 DAY AND appointment_time = '10:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'sarah@example.com'), 5, 'Quick and friendly.'),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'daniel.lim@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'MMR') AND appointment_date = CURDATE() - INTERVAL 157 DAY AND appointment_time = '11:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com'), 4, 'Felt looked after.'),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'michael@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'priya.nair@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Influenza') AND appointment_date = CURDATE() - INTERVAL 104 DAY AND appointment_time = '09:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'michael@example.com'), 5, 'Quick and friendly.'),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'sarah@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'priya.nair@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Influenza') AND appointment_date = CURDATE() - INTERVAL 134 DAY AND appointment_time = '10:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'sarah@example.com'), 4, 'Felt looked after.'),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'priya.nair@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Influenza') AND appointment_date = CURDATE() - INTERVAL 164 DAY AND appointment_time = '11:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com'), 5, 'Good advice, short wait.'),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'michael@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'ahmad.farid@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Td Booster') AND appointment_date = CURDATE() - INTERVAL 111 DAY AND appointment_time = '09:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'michael@example.com'), 5, 'Felt looked after.'),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'sarah@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'ahmad.farid@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Td Booster') AND appointment_date = CURDATE() - INTERVAL 141 DAY AND appointment_time = '10:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'sarah@example.com'), 4, 'Good advice, short wait.'),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'ahmad.farid@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Td Booster') AND appointment_date = CURDATE() - INTERVAL 171 DAY AND appointment_time = '11:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com'), 4, NULL),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'michael@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'mei.ling.tan@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Hepatitis B') AND appointment_date = CURDATE() - INTERVAL 118 DAY AND appointment_time = '09:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'michael@example.com'), 4, 'Good advice, short wait.'),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'sarah@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'mei.ling.tan@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Hepatitis B') AND appointment_date = CURDATE() - INTERVAL 148 DAY AND appointment_time = '10:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'sarah@example.com'), 5, NULL),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'mei.ling.tan@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Hepatitis B') AND appointment_date = CURDATE() - INTERVAL 178 DAY AND appointment_time = '11:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com'), 5, 'Very gentle and clear.'),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'michael@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'rajesh.kumar@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Td Booster') AND appointment_date = CURDATE() - INTERVAL 125 DAY AND appointment_time = '09:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'michael@example.com'), 5, NULL),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'sarah@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'rajesh.kumar@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Td Booster') AND appointment_date = CURDATE() - INTERVAL 155 DAY AND appointment_time = '10:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'sarah@example.com'), 5, 'Very gentle and clear.'),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'rajesh.kumar@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Td Booster') AND appointment_date = CURDATE() - INTERVAL 185 DAY AND appointment_time = '11:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com'), 4, 'Explained everything well.'),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'michael@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'siti.aminah@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'MMR') AND appointment_date = CURDATE() - INTERVAL 132 DAY AND appointment_time = '09:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'michael@example.com'), 4, 'Very gentle and clear.'),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'sarah@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'siti.aminah@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'MMR') AND appointment_date = CURDATE() - INTERVAL 162 DAY AND appointment_time = '10:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'sarah@example.com'), 5, 'Explained everything well.'),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'siti.aminah@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'MMR') AND appointment_date = CURDATE() - INTERVAL 192 DAY AND appointment_time = '11:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com'), 4, 'Quick and friendly.'),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'michael@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'jason.wong@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Influenza') AND appointment_date = CURDATE() - INTERVAL 139 DAY AND appointment_time = '09:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'michael@example.com'), 5, 'Explained everything well.'),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'sarah@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'jason.wong@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Influenza') AND appointment_date = CURDATE() - INTERVAL 169 DAY AND appointment_time = '10:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'sarah@example.com'), 5, 'Quick and friendly.'),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'jason.wong@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Influenza') AND appointment_date = CURDATE() - INTERVAL 199 DAY AND appointment_time = '11:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'ahmad@example.com'), 5, 'Felt looked after.'),
((SELECT appointment_id FROM appointments WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'demo@example.com') AND doctor_id = (SELECT doctor_id FROM doctors WHERE email = 'priya.nair@vaxassist.demo') AND vaccine_id = (SELECT vaccine_id FROM vaccines WHERE name = 'Influenza') AND appointment_date = CURDATE() - INTERVAL 210 DAY AND appointment_time = '09:00:00' LIMIT 1), (SELECT patient_id FROM patients WHERE email = 'demo@example.com'), 5, 'Quick and painless.');

INSERT INTO `notifications` (`patient_id`, `type`, `title`, `body`, `action_url`, `action_label`, `is_read`, `created_at`) VALUES
((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), 'Late', 'Doctor running late', 'Dr. Aisha Rahman is running about 15 minutes behind. Your Yellow Fever appointment is still on, with a slightly later start.', 'appointments.html', 'View appointment', 0, NOW() - INTERVAL 12 MINUTE),
((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), 'Reminder', 'Appointment tomorrow', 'Reminder: Yellow Fever vaccine with Dr. Aisha Rahman at 10:00 AM. Please bring your ID and travel details.', 'appointments.html', 'View appointment', 0, NOW() - INTERVAL 180 MINUTE),
((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), 'Booster', 'Aiden''s pneumococcal booster is overdue', 'Aiden is due for his Pneumococcal (PCV) booster. Book a visit to keep his schedule on track.', 'booking.html?vaccine=Pneumococcal%20(PCV)', 'Book now', 0, NOW() - INTERVAL 1200 MINUTE),
((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), 'Appointment', 'Booking confirmed', 'Your MMR appointment for Aiden with Dr. Daniel Lim has been confirmed.', 'appointments.html', 'View appointment', 1, NOW() - INTERVAL 1680 MINUTE),
((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), 'Booster', 'Hepatitis A second dose coming up', 'Your second Hepatitis A dose is due in about 40 days. You can book a slot any time before then.', 'vaccinations.html', 'See my records', 0, NOW() - INTERVAL 4320 MINUTE),
((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), 'Announcement', 'Discounted flu booster slots', 'Selected influenza booster slots this month are available at a reduced price while stocks last.', 'booking.html?vaccine=Influenza', 'Book a slot', 1, NOW() - INTERVAL 7200 MINUTE),
((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), 'Appointment', 'Appointment rescheduled', 'Your Typhoid appointment was moved to a new time at your request.', 'appointments.html?tab=history', 'View history', 1, NOW() - INTERVAL 23040 MINUTE),
((SELECT patient_id FROM patients WHERE email = 'demo@example.com'), 'Announcement', 'Welcome to VaxAssist', 'Thanks for joining. Complete your health profile so your doctor has what they need before each vaccine.', 'profile.html?tab=health', 'Open profile', 1, NOW() - INTERVAL 57600 MINUTE),
((SELECT patient_id FROM patients WHERE email = 'michael@example.com'), 'Reminder', 'Influenza booking confirmed', 'Your influenza appointment with Dr. Priya Nair is booked. Please complete the pre-consultation form beforehand.', 'precheck.html?vaccine=Influenza', 'Fill in the form', 0, NOW() - INTERVAL 90 MINUTE),
((SELECT patient_id FROM patients WHERE email = 'michael@example.com'), 'Booster', 'Noah''s DTaP-IPV-Hib dose 2 is overdue', 'Noah is due for the next dose in his DTaP-IPV-Hib course. Book a visit to catch up.', 'booking.html?vaccine=DTaP-IPV-Hib', 'Book now', 0, NOW() - INTERVAL 3000 MINUTE),
((SELECT patient_id FROM patients WHERE email = 'michael@example.com'), 'Announcement', 'Welcome to VaxAssist', 'Thanks for joining. Complete your health profile so your doctor has what they need before each vaccine.', 'profile.html?tab=health', 'Open profile', 1, NOW() - INTERVAL 40000 MINUTE),
((SELECT patient_id FROM patients WHERE email = 'sarah@example.com'), 'Reminder', 'Yellow Fever appointment booked', 'Your Yellow Fever appointment is booked. Bring your passport and travel details.', 'appointments.html', 'View appointment', 0, NOW() - INTERVAL 60 MINUTE),
((SELECT patient_id FROM patients WHERE email = 'sarah@example.com'), 'Booster', 'Hepatitis A second dose coming up', 'Your second Hepatitis A dose is due in about five months.', 'vaccinations.html', 'See my records', 1, NOW() - INTERVAL 5000 MINUTE),
((SELECT patient_id FROM patients WHERE email = 'ahmad@example.com'), 'Announcement', 'Welcome to VaxAssist', 'Thanks for joining. Complete your health profile so your doctor has what they need before each vaccine.', 'profile.html?tab=health', 'Open profile', 0, NOW() - INTERVAL 200 MINUTE);

INSERT INTO `messages` (`doctor_id`, `patient_id`, `sender_type`, `message_text`, `is_read`, `created_at`) VALUES
((SELECT doctor_id FROM doctors WHERE email = 'aisha.rahman@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'demo@example.com'), 'patient', 'Hi Dr. Rahman, I''m travelling to Ghana next month. Besides yellow fever, is there anything else I should have?', 1, NOW() - INTERVAL 2900 MINUTE),
((SELECT doctor_id FROM doctors WHERE email = 'aisha.rahman@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'demo@example.com'), 'doctor', 'Hello! Typhoid and hepatitis A are both advised for Ghana, and we should talk about malaria tablets. Bring your itinerary to your appointment and we will go through it.', 1, NOW() - INTERVAL 2880 MINUTE),
((SELECT doctor_id FROM doctors WHERE email = 'aisha.rahman@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'demo@example.com'), 'patient', 'Thank you, I will bring it along.', 1, NOW() - INTERVAL 2870 MINUTE),
((SELECT doctor_id FROM doctors WHERE email = 'daniel.lim@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'demo@example.com'), 'doctor', 'Hi, this is a reminder that Aiden''s MMR appointment is coming up. Please let us know if he has a fever on the day.', 0, NOW() - INTERVAL 35 MINUTE),
((SELECT doctor_id FROM doctors WHERE email = 'priya.nair@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'michael@example.com'), 'patient', 'Is it fine to have my flu shot if I have a mild cold?', 1, NOW() - INTERVAL 600 MINUTE),
((SELECT doctor_id FROM doctors WHERE email = 'priya.nair@vaxassist.demo'), (SELECT patient_id FROM patients WHERE email = 'michael@example.com'), 'doctor', 'A mild cold is usually fine, but if you have a fever we should move it. Please complete the pre-consultation form so I can check.', 0, NOW() - INTERVAL 420 MINUTE);
