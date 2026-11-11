-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 10, 2026 at 01:51 PM
-- Server version: 10.11.16-MariaDB
-- PHP Version: 8.5.12

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
  `child_id` int(11) DEFAULT NULL,
  `vaccine_id` int(11) DEFAULT NULL,
  `appointment_date` date NOT NULL,
  `appointment_time` time DEFAULT NULL,
  `time_slot` enum('08:00 AM - 10:00 AM','10:00 AM - 12:00 PM','01:00 PM - 03:00 PM','03:00 PM - 05:00 PM') NOT NULL,
  `status` enum('Scheduled','Completed','Cancelled','Missed') DEFAULT 'Scheduled',
  `symptoms_notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `cancel_reason` varchar(300) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `appointments`
--

INSERT INTO `appointments` (`appointment_id`, `doctor_id`, `patient_id`, `child_id`, `vaccine_id`, `appointment_date`, `appointment_time`, `time_slot`, `status`, `symptoms_notes`, `created_at`, `cancel_reason`) VALUES
(1, 1, 1, NULL, NULL, '2026-10-18', NULL, '08:00 AM - 10:00 AM', 'Completed', 'Cardiology Routine Review & ECG', '2026-10-18 06:58:13', NULL),
(2, 1, 2, NULL, NULL, '2026-10-18', NULL, '10:00 AM - 12:00 PM', 'Scheduled', 'Influenza Vaccine Consultation', '2026-10-18 06:58:13', NULL),
(3, 1, 3, NULL, NULL, '2026-10-18', NULL, '01:00 PM - 03:00 PM', 'Completed', 'Orthopedic Joint Checkup', '2026-10-18 06:58:13', NULL),
(4, 2, 4, NULL, 1, '2026-11-16', '10:00:00', '10:00 AM - 12:00 PM', 'Scheduled', 'Travelling to Ghana next month.', '2026-11-10 08:31:38', NULL),
(5, 3, 4, 1, 14, '2026-11-23', '14:30:00', '01:00 PM - 03:00 PM', 'Scheduled', NULL, '2026-11-10 08:31:38', NULL),
(6, 4, 4, NULL, 17, '2026-11-30', '09:30:00', '08:00 AM - 10:00 AM', 'Scheduled', NULL, '2026-11-10 08:31:38', NULL),
(7, 2, 4, NULL, 2, '2026-10-29', '11:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(8, 8, 4, 1, 11, '2026-10-11', '15:00:00', '03:00 PM - 05:00 PM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(9, 9, 4, NULL, 3, '2026-09-30', '10:30:00', '10:00 AM - 12:00 PM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(10, 9, 4, NULL, 3, '2026-10-23', '11:30:00', '10:00 AM - 12:00 PM', 'Cancelled', NULL, '2026-11-10 08:31:38', 'Change of plans.'),
(11, 4, 4, NULL, 16, '2026-09-11', '16:00:00', '03:00 PM - 05:00 PM', 'Missed', NULL, '2026-11-10 08:31:38', NULL),
(12, 4, 4, NULL, 17, '2026-04-14', '09:00:00', '08:00 AM - 10:00 AM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(13, 4, 1, NULL, 17, '2026-11-16', '10:30:00', '10:00 AM - 12:00 PM', 'Scheduled', NULL, '2026-11-10 08:31:38', NULL),
(14, 3, 1, 2, 14, '2026-09-11', '14:00:00', '01:00 PM - 03:00 PM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(15, 2, 2, NULL, 1, '2026-11-23', '09:00:00', '08:00 AM - 10:00 AM', 'Scheduled', 'Trip to Kenya in six weeks.', '2026-11-10 08:31:38', NULL),
(16, 9, 3, NULL, 16, '2026-11-16', '15:30:00', '03:00 PM - 05:00 PM', 'Scheduled', NULL, '2026-11-10 08:31:38', NULL),
(17, 2, 1, NULL, 2, '2026-08-12', '09:00:00', '08:00 AM - 10:00 AM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(18, 2, 2, NULL, 2, '2026-07-13', '10:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(19, 2, 3, NULL, 2, '2026-06-13', '11:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(20, 3, 1, NULL, 14, '2026-08-05', '09:00:00', '08:00 AM - 10:00 AM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(21, 3, 2, NULL, 14, '2026-07-06', '10:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(22, 3, 3, NULL, 14, '2026-06-06', '11:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(23, 4, 1, NULL, 17, '2026-07-29', '09:00:00', '08:00 AM - 10:00 AM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(24, 4, 2, NULL, 17, '2026-06-29', '10:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(25, 4, 3, NULL, 17, '2026-05-30', '11:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(26, 5, 1, NULL, 16, '2026-07-22', '09:00:00', '08:00 AM - 10:00 AM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(27, 5, 2, NULL, 16, '2026-06-22', '10:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(28, 5, 3, NULL, 16, '2026-05-23', '11:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(29, 6, 1, NULL, 10, '2026-07-15', '09:00:00', '08:00 AM - 10:00 AM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(30, 6, 2, NULL, 10, '2026-06-15', '10:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(31, 6, 3, NULL, 10, '2026-05-16', '11:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(32, 7, 1, NULL, 16, '2026-07-08', '09:00:00', '08:00 AM - 10:00 AM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(33, 7, 2, NULL, 16, '2026-06-08', '10:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(34, 7, 3, NULL, 16, '2026-05-09', '11:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(35, 8, 1, NULL, 14, '2026-07-01', '09:00:00', '08:00 AM - 10:00 AM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(36, 8, 2, NULL, 14, '2026-06-01', '10:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(37, 8, 3, NULL, 14, '2026-05-02', '11:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(38, 9, 1, NULL, 17, '2026-06-24', '09:00:00', '08:00 AM - 10:00 AM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(39, 9, 2, NULL, 17, '2026-05-25', '10:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(40, 9, 3, NULL, 17, '2026-04-25', '11:00:00', '10:00 AM - 12:00 PM', 'Completed', NULL, '2026-11-10 08:31:38', NULL),
(41, 1, 1, NULL, 1, '2026-11-11', '10:00:00', '10:00 AM - 12:00 PM', 'Cancelled', NULL, '2026-11-10 09:01:32', NULL),
(42, 1, 1, NULL, 1, '2026-11-26', '10:00:00', '10:00 AM - 12:00 PM', 'Cancelled', NULL, '2026-11-10 09:10:26', NULL),
(43, 1, 1, NULL, 4, '2026-11-11', '14:00:00', '01:00 PM - 03:00 PM', 'Cancelled', NULL, '2026-11-10 10:04:31', NULL),
(44, 1, 1, NULL, 16, '2026-11-12', '10:00:00', '10:00 AM - 12:00 PM', 'Scheduled', NULL, '2026-11-10 12:28:53', NULL),
(45, 1, 1, NULL, 12, '2026-11-13', '10:00:00', '10:00 AM - 12:00 PM', 'Scheduled', NULL, '2026-11-10 12:33:27', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `children`
--

CREATE TABLE `children` (
  `child_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL COMMENT 'the parent',
  `first_name` varchar(50) NOT NULL,
  `dob` date NOT NULL,
  `gender` enum('Male','Female','Other') NOT NULL DEFAULT 'Male',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `children`
--

INSERT INTO `children` (`child_id`, `patient_id`, `first_name`, `dob`, `gender`, `created_at`) VALUES
(1, 4, 'Aiden', '2025-09-06', 'Male', '2026-11-10 08:31:38'),
(2, 1, 'Noah', '2024-05-24', 'Male', '2026-11-10 08:31:38');

-- --------------------------------------------------------

--
-- Table structure for table `child_schedule`
--

CREATE TABLE `child_schedule` (
  `schedule_id` int(11) NOT NULL,
  `vaccine_id` int(11) NOT NULL,
  `age_months` smallint(6) NOT NULL COMMENT 'age when the dose is due',
  `dose_number` tinyint(3) UNSIGNED NOT NULL DEFAULT 0 COMMENT '0 = not tracked (e.g. yearly flu shot)',
  `dose_label` varchar(30) NOT NULL,
  `requirement` enum('Required','Recommended') NOT NULL,
  `reason` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `child_schedule`
--

INSERT INTO `child_schedule` (`schedule_id`, `vaccine_id`, `age_months`, `dose_number`, `dose_label`, `requirement`, `reason`) VALUES
(1, 9, 0, 1, 'Single dose', 'Required', 'Protects against severe forms of tuberculosis.'),
(2, 10, 0, 1, 'Dose 1 of 3', 'Required', 'Protects the liver against hepatitis B infection.'),
(3, 10, 1, 2, 'Dose 2 of 3', 'Required', 'Second dose of the hepatitis B course.'),
(4, 11, 2, 1, 'Dose 1 of 4', 'Required', 'Covers diphtheria, tetanus, whooping cough, polio and Hib in one injection.'),
(5, 12, 2, 1, 'Dose 1 of 4', 'Required', 'Protects against pneumonia, meningitis and ear infections.'),
(6, 13, 2, 1, 'Dose 1 of 2', 'Recommended', 'Oral vaccine that prevents severe diarrhoea in babies.'),
(7, 11, 3, 2, 'Dose 2 of 4', 'Required', 'Second dose of the five-in-one vaccine.'),
(8, 12, 3, 2, 'Dose 2 of 4', 'Required', 'Second dose of the pneumococcal course.'),
(9, 13, 3, 2, 'Dose 2 of 2', 'Recommended', 'Completes the rotavirus course.'),
(10, 11, 5, 3, 'Dose 3 of 4', 'Required', 'Third dose of the five-in-one vaccine.'),
(11, 12, 5, 3, 'Dose 3 of 4', 'Required', 'Third dose of the pneumococcal course.'),
(12, 10, 6, 3, 'Dose 3 of 3', 'Required', 'Completes the hepatitis B course.'),
(13, 17, 6, 0, 'Yearly', 'Recommended', 'Flu vaccine is advised every year from 6 months old.'),
(14, 14, 9, 1, 'Dose 1 of 2', 'Required', 'Protects against measles, mumps and rubella.'),
(15, 12, 12, 4, 'Booster', 'Required', 'Booster dose to keep protection strong.'),
(16, 14, 12, 2, 'Dose 2 of 2', 'Required', 'Second dose gives long-lasting protection.'),
(17, 15, 12, 1, 'Dose 1 of 2', 'Recommended', 'Protects against chickenpox and shingles later in life.'),
(18, 11, 18, 4, 'Booster', 'Required', 'Booster dose of the five-in-one vaccine.'),
(19, 15, 36, 2, 'Dose 2 of 2', 'Recommended', 'Second dose completes chickenpox protection.');

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

--
-- Dumping data for table `consultation_records`
--

INSERT INTO `consultation_records` (`record_id`, `doctor_id`, `patient_id`, `subjective_notes`, `objective_notes`, `assessment`, `plan`, `created_at`) VALUES
(1, 1, 1, 'try', 'try', 'try', 'try', '2026-11-10 08:51:24');

-- --------------------------------------------------------

--
-- Table structure for table `contact_messages`
--

CREATE TABLE `contact_messages` (
  `message_id` int(11) NOT NULL,
  `patient_id` int(11) DEFAULT NULL COMMENT 'set when the sender was logged in',
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `subject` varchar(100) NOT NULL,
  `message` varchar(1000) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `status` enum('New','Read','Replied') NOT NULL DEFAULT 'New',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `destinations`
--

CREATE TABLE `destinations` (
  `destination_id` int(11) NOT NULL,
  `country_code` char(2) NOT NULL,
  `country` varchar(100) NOT NULL,
  `region` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `destinations`
--

INSERT INTO `destinations` (`destination_id`, `country_code`, `country`, `region`) VALUES
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

-- --------------------------------------------------------

--
-- Table structure for table `destination_vaccines`
--

CREATE TABLE `destination_vaccines` (
  `destination_id` int(11) NOT NULL,
  `vaccine_id` int(11) NOT NULL,
  `requirement` enum('Required','Recommended') NOT NULL,
  `reason` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `destination_vaccines`
--

INSERT INTO `destination_vaccines` (`destination_id`, `vaccine_id`, `requirement`, `reason`) VALUES
(1, 14, 'Recommended', 'Measles outbreaks happen worldwide. Make sure you have had two doses.'),
(1, 16, 'Recommended', 'Keeps tetanus and diphtheria cover up to date (every 10 years).'),
(1, 17, 'Recommended', 'Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),
(2, 1, 'Recommended', 'Mosquito-borne and present in this region. One dose gives lifelong protection.'),
(2, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(2, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(2, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(2, 17, 'Recommended', 'Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),
(3, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(3, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(3, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(3, 5, 'Recommended', 'Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),
(4, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(4, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(4, 5, 'Recommended', 'Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),
(4, 14, 'Recommended', 'Measles outbreaks happen worldwide. Make sure you have had two doses.'),
(4, 17, 'Recommended', 'Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),
(5, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(5, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(5, 8, 'Recommended', 'Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),
(5, 16, 'Recommended', 'Keeps tetanus and diphtheria cover up to date (every 10 years).'),
(6, 1, 'Required', 'A yellow fever certificate is required to enter. One dose gives lifelong protection.'),
(6, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(6, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(6, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(6, 6, 'Recommended', 'Advised for the African meningitis belt, especially during the dry season.'),
(6, 8, 'Recommended', 'Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),
(7, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(7, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(7, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(7, 5, 'Recommended', 'Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),
(7, 7, 'Recommended', 'Mainly for aid workers or travellers to areas with active outbreaks.'),
(7, 8, 'Recommended', 'Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),
(8, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(8, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(8, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(8, 5, 'Recommended', 'Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),
(8, 16, 'Recommended', 'Keeps tetanus and diphtheria cover up to date (every 10 years).'),
(9, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(9, 5, 'Recommended', 'Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),
(9, 14, 'Recommended', 'Measles outbreaks happen worldwide. Make sure you have had two doses.'),
(9, 17, 'Recommended', 'Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),
(10, 1, 'Recommended', 'Mosquito-borne and present in this region. One dose gives lifelong protection.'),
(10, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(10, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(10, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(10, 6, 'Recommended', 'Advised for the African meningitis belt, especially during the dry season.'),
(10, 8, 'Recommended', 'Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),
(11, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(11, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(11, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(11, 5, 'Recommended', 'Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),
(11, 6, 'Recommended', 'Advised for the African meningitis belt, especially during the dry season.'),
(11, 8, 'Recommended', 'Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),
(12, 1, 'Required', 'A yellow fever certificate is required to enter. One dose gives lifelong protection.'),
(12, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(12, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(12, 6, 'Recommended', 'Advised for the African meningitis belt, especially during the dry season.'),
(12, 7, 'Recommended', 'Mainly for aid workers or travellers to areas with active outbreaks.'),
(12, 8, 'Recommended', 'Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),
(13, 1, 'Recommended', 'Mosquito-borne and present in this region. One dose gives lifelong protection.'),
(13, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(13, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(13, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(14, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(14, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(14, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(14, 5, 'Recommended', 'Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),
(14, 7, 'Recommended', 'Mainly for aid workers or travellers to areas with active outbreaks.'),
(15, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(15, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(15, 6, 'Required', 'Proof of vaccination is required for Hajj and Umrah visas.'),
(15, 8, 'Recommended', 'Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),
(15, 17, 'Recommended', 'Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),
(16, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(16, 16, 'Recommended', 'Keeps tetanus and diphtheria cover up to date (every 10 years).'),
(17, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(17, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(17, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(17, 16, 'Recommended', 'Keeps tetanus and diphtheria cover up to date (every 10 years).'),
(18, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(18, 14, 'Recommended', 'Measles outbreaks happen worldwide. Make sure you have had two doses.'),
(18, 17, 'Recommended', 'Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),
(19, 1, 'Recommended', 'Mosquito-borne and present in this region. One dose gives lifelong protection.'),
(19, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(19, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(19, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(19, 6, 'Recommended', 'Advised for the African meningitis belt, especially during the dry season.'),
(19, 8, 'Recommended', 'Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),
(20, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(20, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(20, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(20, 5, 'Recommended', 'Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),
(20, 16, 'Recommended', 'Keeps tetanus and diphtheria cover up to date (every 10 years).'),
(21, 1, 'Required', 'A yellow fever certificate is required to enter. One dose gives lifelong protection.'),
(21, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(21, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(21, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(21, 6, 'Recommended', 'Advised for the African meningitis belt, especially during the dry season.'),
(21, 8, 'Recommended', 'Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),
(22, 14, 'Recommended', 'Measles outbreaks happen worldwide. Make sure you have had two doses.'),
(22, 16, 'Recommended', 'Keeps tetanus and diphtheria cover up to date (every 10 years).'),
(22, 17, 'Recommended', 'Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),
(23, 14, 'Recommended', 'Measles outbreaks happen worldwide. Make sure you have had two doses.'),
(23, 16, 'Recommended', 'Keeps tetanus and diphtheria cover up to date (every 10 years).'),
(23, 17, 'Recommended', 'Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),
(24, 2, 'Recommended', 'Spread through contaminated food and water, especially if you eat street food or stay with locals.'),
(24, 3, 'Recommended', 'Spread through food and water. Advised for almost every destination outside Europe and North America.'),
(24, 4, 'Recommended', 'Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),
(24, 5, 'Recommended', 'Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),
(24, 16, 'Recommended', 'Keeps tetanus and diphtheria cover up to date (every 10 years).');

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
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `profile_photo` mediumblob DEFAULT NULL,
  `profile_photo_mime` varchar(50) DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `years_experience` tinyint(3) UNSIGNED DEFAULT NULL,
  `languages` varchar(150) DEFAULT NULL,
  `keywords` text DEFAULT NULL COMMENT 'comma-separated search words for the Doctors page'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `doctors`
--

INSERT INTO `doctors` (`doctor_id`, `first_name`, `last_name`, `email`, `phone`, `dob`, `password_hash`, `specialization`, `consultation_room`, `created_at`, `profile_photo`, `profile_photo_mime`, `bio`, `years_experience`, `languages`, `keywords`) VALUES
(1, 'Alex', 'Taylor', 'try1@gmail.com', '0129998888', '1985-05-12', '$2y$10$Wbao0n/7NbEDtp2HJOEhie3ch63L8C4Gr/.THsbiZkmzmE3nOwmdm', 'Cardiology & Orthopedic Medicine', 'Room 304', '2026-10-18 06:58:13', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 'Aisha', 'Rahman', 'aisha.rahman@vaxassist.demo', '+60 3-0000 1000', '1985-01-01', '$2y$10$t/.s0bFo0JG0UrDJTeq0ZexfzsPzxDPWruYUeYx.QwvL6Z3c7H42G', 'Travel Medicine', 'Room 101', '2026-11-10 08:31:38', NULL, NULL, 'Advises travellers on vaccines, malaria prevention and health planning for overseas trips.', 12, 'English, Malay', 'travel, yellow fever, typhoid, hepatitis a, rabies, malaria'),
(3, 'Daniel', 'Lim', 'daniel.lim@vaxassist.demo', '+60 3-0000 1001', '1985-01-01', '$2y$10$hjUMz9rSrMLj8f5caEALaeRdg3ZOyLDMlkRpr/bYMJd2b3GTbbuzy', 'Paediatrics', 'Room 102', '2026-11-10 08:31:38', NULL, NULL, 'Looks after babies and children, including growth checks and the childhood vaccination schedule.', 9, 'English, Mandarin', 'child, baby, fever, mmr, booster, rotavirus, bcg'),
(4, 'Priya', 'Nair', 'priya.nair@vaxassist.demo', '+60 3-0000 1002', '1985-01-01', '$2y$10$sQR1sK4CIstfazX/0yzobuX3oEdMsXDMs.jhLpfEuUY2KPV0a.9IG', 'General Practice', 'Room 103', '2026-11-10 08:31:38', NULL, NULL, 'Family doctor for everyday health concerns, check-ups and vaccine advice for all ages.', 15, 'English, Tamil, Malay', 'cough, cold, fever, flu, influenza, check-up, vaccine, tetanus'),
(5, 'Ahmad', 'Farid', 'ahmad.farid@vaxassist.demo', '+60 3-0000 1003', '1985-01-01', '$2y$10$IMYyEdfLn.kk0wr5KictBOXHTERIwdKBgGsN35BmDspRgWA0ZoJy2', 'Internal Medicine', 'Room 104', '2026-11-10 08:31:38', NULL, NULL, 'Manages long-term conditions such as diabetes, blood pressure and liver health.', 18, 'English, Malay', 'diabetes, blood pressure, hepatitis b, liver, fatigue'),
(6, 'Mei', 'Ling Tan', 'mei.ling.tan@vaxassist.demo', '+60 3-0000 1004', '1985-01-01', '$2y$10$x3Hki7b7hX/3oGnN3XmqzeqFGqTwdCwNYhKzi/ZL1R6GB87FJeJaG', 'Infectious Diseases', 'Room 105', '2026-11-10 08:31:38', NULL, NULL, 'Treats infections and advises on vaccine-preventable diseases, outbreaks and post-exposure care.', 8, 'English, Mandarin', 'infection, hepatitis b, rabies, post-exposure, measles, dengue, allergy, vaccine reaction'),
(7, 'Rajesh', 'Kumar', 'rajesh.kumar@vaxassist.demo', '+60 3-0000 1005', '1985-01-01', '$2y$10$phHF2/12zpdDfwQxOrXuQOp2HhcjscR8iVta9ksTmPuJ8m96k./XS', 'Preventive Medicine', 'Room 106', '2026-11-10 08:31:38', NULL, NULL, 'Plans adult immunisation, health screening and workplace or community vaccination programmes.', 14, 'English, Hindi', 'adult vaccine, screening, influenza, tetanus, workplace, pneumococcal, booster'),
(8, 'Siti', 'Aminah', 'siti.aminah@vaxassist.demo', '+60 3-0000 1006', '1985-01-01', '$2y$10$dIGmjQ9fUboJfWk5c5mm3uSRnPdEe7ZUhPmcrEbjulPaC4TV3nV3u', 'Paediatrics', 'Room 107', '2026-11-10 08:31:38', NULL, NULL, 'Child health and development, with a special interest in newborn care and immunisation.', 6, 'English, Malay', 'newborn, baby, child, hepatitis b, dtap, pneumococcal, vaccine'),
(9, 'Jason', 'Wong', 'jason.wong@vaxassist.demo', '+60 3-0000 1007', '1985-01-01', '$2y$10$cdBGWJl3DkAXRepUW4Djq.s47EI5LHykBoLOApQjlTXO7MJqt3N2e', 'General Practice', 'Room 108', '2026-11-10 08:31:38', NULL, NULL, 'Walk-in friendly family doctor offering vaccinations, travel health letters and minor procedures.', 10, 'English, Mandarin, Cantonese', 'vaccine, travel, typhoid, hepatitis a, cough, fever, headache');

-- --------------------------------------------------------

--
-- Table structure for table `doctor_availability`
--

CREATE TABLE `doctor_availability` (
  `doctor_id` int(11) NOT NULL,
  `weekday` tinyint(3) UNSIGNED NOT NULL COMMENT '1 = Monday ... 5 = Friday'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `doctor_availability`
--

INSERT INTO `doctor_availability` (`doctor_id`, `weekday`) VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(2, 1),
(2, 3),
(2, 5),
(3, 1),
(3, 2),
(3, 4),
(4, 1),
(4, 2),
(4, 3),
(4, 4),
(4, 5),
(5, 2),
(5, 3),
(5, 5),
(6, 2),
(6, 4),
(7, 1),
(7, 3),
(8, 3),
(8, 4),
(8, 5),
(9, 1),
(9, 2),
(9, 3),
(9, 4),
(9, 5);

-- --------------------------------------------------------

--
-- Table structure for table `doctor_notification_cursors`
--

CREATE TABLE `doctor_notification_cursors` (
  `doctor_id` int(11) NOT NULL,
  `last_seen_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `doctor_notification_cursors`
--

INSERT INTO `doctor_notification_cursors` (`doctor_id`, `last_seen_at`) VALUES
(1, '2026-11-10 20:41:16');

-- --------------------------------------------------------

--
-- Table structure for table `doctor_password_resets`
--

CREATE TABLE `doctor_password_resets` (
  `reset_id` int(11) NOT NULL,
  `doctor_id` int(11) NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `doctor_patient_links`
--

CREATE TABLE `doctor_patient_links` (
  `doctor_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
(1, 1, 2, 'patient', 'Hello Dr. Alex, I received my flu vaccine yesterday. My arm feels slightly warm and sore. Is this normal?', 1, '2026-10-18 06:58:13'),
(2, 1, 2, 'doctor', 'Hi Sarah, yes, mild soreness and warmth at the injection site are common post-vaccine reactions.', 1, '2026-10-18 06:58:13'),
(3, 1, 2, 'doctor', 'test 1', 0, '2026-10-18 07:48:43'),
(4, 2, 4, 'patient', 'Hi Dr. Rahman, I\'m travelling to Ghana next month. Besides yellow fever, is there anything else I should have?', 1, '2026-11-08 08:11:38'),
(5, 2, 4, 'doctor', 'Hello! Typhoid and hepatitis A are both advised for Ghana, and we should talk about malaria tablets. Bring your itinerary to your appointment and we will go through it.', 1, '2026-11-08 08:31:38'),
(6, 2, 4, 'patient', 'Thank you, I will bring it along.', 1, '2026-11-08 08:41:38'),
(7, 3, 4, 'doctor', 'Hi, this is a reminder that Aiden\'s MMR appointment is coming up. Please let us know if he has a fever on the day.', 0, '2026-11-10 07:56:38'),
(8, 4, 1, 'patient', 'Is it fine to have my flu shot if I have a mild cold?', 1, '2026-11-09 22:31:38'),
(9, 4, 1, 'doctor', 'A mild cold is usually fine, but if you have a fever we should move it. Please complete the pre-consultation form so I can check.', 1, '2026-11-10 01:31:38');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `notification_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `recipient_type` enum('patient','doctor') NOT NULL DEFAULT 'patient',
  `doctor_id` int(11) DEFAULT NULL,
  `appointment_id` int(11) DEFAULT NULL,
  `type` enum('Appointment','Reminder','Booster','Late','Announcement','Precheck','Message','Vaccination') NOT NULL,
  `title` varchar(150) NOT NULL,
  `body` text DEFAULT NULL,
  `action_url` varchar(200) DEFAULT NULL,
  `action_label` varchar(50) DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`notification_id`, `patient_id`, `recipient_type`, `doctor_id`, `appointment_id`, `type`, `title`, `body`, `action_url`, `action_label`, `is_read`, `created_at`) VALUES
(1, 4, 'patient', NULL, NULL, 'Late', 'Doctor running late', 'Dr. Aisha Rahman is running about 15 minutes behind. Your Yellow Fever appointment is still on, with a slightly later start.', 'appointments.html', 'View appointment', 0, '2026-11-10 08:19:38'),
(2, 4, 'patient', NULL, NULL, 'Reminder', 'Appointment tomorrow', 'Reminder: Yellow Fever vaccine with Dr. Aisha Rahman at 10:00 AM. Please bring your ID and travel details.', 'appointments.html', 'View appointment', 0, '2026-11-10 05:31:38'),
(3, 4, 'patient', NULL, NULL, 'Booster', 'Aiden\'s pneumococcal booster is overdue', 'Aiden is due for his Pneumococcal (PCV) booster. Book a visit to keep his schedule on track.', 'booking.html?vaccine=Pneumococcal%20(PCV)', 'Book now', 0, '2026-11-09 12:31:38'),
(4, 4, 'patient', NULL, NULL, 'Appointment', 'Booking confirmed', 'Your MMR appointment for Aiden with Dr. Daniel Lim has been confirmed.', 'appointments.html', 'View appointment', 1, '2026-11-09 04:31:38'),
(5, 4, 'patient', NULL, NULL, 'Booster', 'Hepatitis A second dose coming up', 'Your second Hepatitis A dose is due in about 40 days. You can book a slot any time before then.', 'vaccinations.html', 'See my records', 0, '2026-11-07 08:31:38'),
(6, 4, 'patient', NULL, NULL, 'Announcement', 'Discounted flu booster slots', 'Selected influenza booster slots this month are available at a reduced price while stocks last.', 'booking.html?vaccine=Influenza', 'Book a slot', 1, '2026-11-05 08:31:38'),
(7, 4, 'patient', NULL, NULL, 'Appointment', 'Appointment rescheduled', 'Your Typhoid appointment was moved to a new time at your request.', 'appointments.html?tab=history', 'View history', 1, '2026-10-25 08:31:38'),
(8, 4, 'patient', NULL, NULL, 'Announcement', 'Welcome to VaxAssist', 'Thanks for joining. Complete your health profile so your doctor has what they need before each vaccine.', 'profile.html?tab=health', 'Open profile', 1, '2026-10-01 08:31:38'),
(9, 1, 'patient', NULL, NULL, 'Reminder', 'Influenza booking confirmed', 'Your influenza appointment with Dr. Priya Nair is booked. Please complete the pre-consultation form beforehand.', 'precheck.html?vaccine=Influenza', 'Fill in the form', 0, '2026-11-10 07:01:38'),
(10, 1, 'patient', NULL, NULL, 'Booster', 'Noah\'s DTaP-IPV-Hib dose 2 is overdue', 'Noah is due for the next dose in his DTaP-IPV-Hib course. Book a visit to catch up.', 'booking.html?vaccine=DTaP-IPV-Hib', 'Book now', 0, '2026-11-08 06:31:38'),
(11, 1, 'patient', NULL, NULL, 'Announcement', 'Welcome to VaxAssist', 'Thanks for joining. Complete your health profile so your doctor has what they need before each vaccine.', 'profile.html?tab=health', 'Open profile', 1, '2026-10-13 13:51:38'),
(12, 2, 'patient', NULL, NULL, 'Reminder', 'Yellow Fever appointment booked', 'Your Yellow Fever appointment is booked. Bring your passport and travel details.', 'appointments.html', 'View appointment', 0, '2026-11-10 07:31:38'),
(13, 2, 'patient', NULL, NULL, 'Booster', 'Hepatitis A second dose coming up', 'Your second Hepatitis A dose is due in about five months.', 'vaccinations.html', 'See my records', 1, '2026-11-06 21:11:38'),
(14, 3, 'patient', NULL, NULL, 'Announcement', 'Welcome to VaxAssist', 'Thanks for joining. Complete your health profile so your doctor has what they need before each vaccine.', 'profile.html?tab=health', 'Open profile', 0, '2026-11-10 05:11:38'),
(15, 1, 'patient', 1, 1, 'Booster', 'Next vaccine dose recorded', 'BCG dose 1 was recorded for Michael Wong. Next dose due 2026-11-26.', 'appointments.html', 'View appointment', 1, '2026-11-10 08:51:57'),
(16, 1, 'patient', NULL, NULL, 'Appointment', 'Booking confirmed', 'Your Yellow Fever appointment on 11 Nov 2026 at 10:00 has been confirmed.', 'appointments.html', 'View appointment', 0, '2026-11-10 09:01:32'),
(17, 3, 'patient', 1, 3, 'Booster', 'Next vaccine dose recorded', 'Td Booster dose 1 was recorded for Ahmad Razak. Next dose due 2026-11-13.', 'appointments.html', 'View appointment', 0, '2026-11-10 09:05:58'),
(18, 1, 'patient', NULL, NULL, 'Appointment', 'Booking confirmed', 'Your Yellow Fever appointment on 26 Nov 2026 at 10:00 has been confirmed.', 'appointments.html', 'View appointment', 0, '2026-11-10 09:10:26'),
(19, 1, 'patient', NULL, NULL, 'Appointment', 'Appointment cancelled', 'Your appointment has been cancelled.', 'appointments.html?tab=history', 'View history', 0, '2026-11-10 09:20:50'),
(20, 1, 'patient', NULL, NULL, 'Appointment', 'Booking confirmed', 'Your Rabies appointment on 13 Nov 2026 at 10:00 has been confirmed.', 'appointments.html', 'View appointment', 0, '2026-11-10 10:04:31'),
(21, 1, 'patient', NULL, NULL, 'Appointment', 'Appointment rescheduled', 'Your appointment was moved to 16 Nov 2026 at 10:00.', 'appointments.html', 'View appointment', 0, '2026-11-10 10:08:15'),
(22, 1, 'patient', NULL, NULL, 'Appointment', 'Appointment rescheduled', 'Your appointment was moved to 11 Nov 2026 at 14:00.', 'appointments.html', 'View appointment', 0, '2026-11-10 10:09:11'),
(23, 1, 'patient', NULL, NULL, 'Appointment', 'Appointment cancelled', 'Your appointment has been cancelled.', 'appointments.html?tab=history', 'View history', 0, '2026-11-10 10:09:58'),
(24, 1, 'patient', NULL, NULL, 'Appointment', 'Appointment cancelled', 'Your appointment has been cancelled.', 'appointments.html?tab=history', 'View history', 0, '2026-11-10 10:10:00'),
(25, 1, 'patient', NULL, NULL, 'Appointment', 'Booking confirmed', 'Your Td Booster appointment on 12 Nov 2026 at 10:00 has been confirmed.', 'appointments.html', 'View appointment', 0, '2026-11-10 12:28:53'),
(26, 1, 'patient', NULL, NULL, 'Appointment', 'Booking confirmed', 'Your Pneumococcal (PCV) appointment on 13 Nov 2026 at 10:00 has been confirmed.', 'appointments.html', 'View appointment', 0, '2026-11-10 12:33:27');

-- --------------------------------------------------------

--
-- Table structure for table `notification_preferences`
--

CREATE TABLE `notification_preferences` (
  `patient_id` int(11) NOT NULL,
  `email_reminders` tinyint(1) NOT NULL DEFAULT 1,
  `sms_reminders` tinyint(1) NOT NULL DEFAULT 1,
  `booster_alerts` tinyint(1) NOT NULL DEFAULT 1,
  `clinic_news` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notification_preferences`
--

INSERT INTO `notification_preferences` (`patient_id`, `email_reminders`, `sms_reminders`, `booster_alerts`, `clinic_news`) VALUES
(1, 1, 1, 1, 1),
(2, 1, 1, 1, 1),
(3, 1, 1, 1, 1),
(4, 1, 1, 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

CREATE TABLE `password_resets` (
  `reset_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `token_hash` char(64) NOT NULL COMMENT 'SHA-256 of the emailed token; the token itself is never stored',
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `patients`
--

CREATE TABLE `patients` (
  `patient_id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `ic_passport` varchar(50) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `gender` enum('Male','Female','Other') NOT NULL DEFAULT 'Male',
  `blood_type` varchar(5) DEFAULT 'O+',
  `allergies` text DEFAULT 'Penicillin',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `address` text DEFAULT NULL,
  `emergency_contact_name` varchar(100) DEFAULT NULL,
  `emergency_contact_phone` varchar(20) DEFAULT NULL,
  `height_cm` smallint(6) DEFAULT NULL,
  `weight_kg` decimal(5,1) DEFAULT NULL,
  `no_known_allergies` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `patients`
--

INSERT INTO `patients` (`patient_id`, `full_name`, `email`, `password_hash`, `ic_passport`, `phone`, `dob`, `gender`, `blood_type`, `allergies`, `created_at`, `address`, `emergency_contact_name`, `emergency_contact_phone`, `height_cm`, `weight_kg`, `no_known_allergies`) VALUES
(1, 'Michael Wong', 'michael@example.com', '$2y$12$mCfdrPeY4FvBFKd5p38pKeC3YSQhBC.jl0ig1IXb4hpZGeLAPu2fS', '800820-07-5531', '0191112222', '1980-08-20', 'Male', 'O+', 'Penicillin', '2026-10-18 06:58:13', NULL, NULL, NULL, NULL, NULL, 0),
(2, 'Sarah Jenkins', 'sarah@example.com', '$2y$10$6vGcJSEjmZ6ObZ60i3UHNe7Z/NOHebH50mKDTXE1v1YpMV/HO1Jb2', '920315-08-6622', '0183334444', '1992-03-15', 'Female', 'A+', 'None', '2026-10-18 06:58:13', NULL, NULL, NULL, NULL, NULL, 0),
(3, 'Ahmad Razak', 'ahmad@example.com', '$2y$10$oDqglPVErvmxxp6R2b4wJOQLbsS2de9SMSifjAwb2wXVhEaPTfr32', '881105-10-7711', '0175556666', '1988-11-05', 'Male', 'B+', 'Aspirin', '2026-10-18 06:58:13', NULL, NULL, NULL, NULL, NULL, 0),
(4, 'Demo Patient', 'demo@example.com', '$2y$10$nVyjH6mh7qwLVmsX1rVc4eibjDKCNBMCeyiiW48s0Lx.Aw8iOMGyi', NULL, '+60 12-345 6789', '1998-05-14', 'Female', 'O+', NULL, '2026-11-10 08:31:38', NULL, NULL, NULL, 165, 58.0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `patient_health_items`
--

CREATE TABLE `patient_health_items` (
  `item_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `item_type` enum('Allergy','Condition','Medication') NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `patient_health_items`
--

INSERT INTO `patient_health_items` (`item_id`, `patient_id`, `item_type`, `name`) VALUES
(5, 1, 'Allergy', 'Latex'),
(6, 2, 'Condition', 'Hay fever'),
(2, 4, 'Allergy', 'Egg'),
(1, 4, 'Allergy', 'Penicillin'),
(3, 4, 'Condition', 'Asthma'),
(4, 4, 'Medication', 'Salbutamol inhaler');

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `payment_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `appointment_id` int(11) DEFAULT NULL,
  `receipt_no` varchar(20) NOT NULL,
  `status` enum('Paid','Pending','Refunded') NOT NULL DEFAULT 'Pending',
  `method` varchar(30) DEFAULT NULL,
  `insurance_covered` decimal(8,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `paid_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`payment_id`, `patient_id`, `appointment_id`, `receipt_no`, `status`, `method`, `insurance_covered`, `created_at`, `paid_at`) VALUES
(1, 4, 7, 'VA-2026-0001', 'Paid', 'Credit card', 0.00, '2026-10-29 00:00:00', '2026-10-29 10:00:00'),
(2, 4, 9, 'VA-2026-0002', 'Paid', 'Insurance + e-wallet', 100.00, '2026-09-30 00:00:00', '2026-09-30 10:00:00'),
(3, 4, 8, 'VA-2026-0003', 'Paid', 'E-wallet', 0.00, '2026-10-11 00:00:00', '2026-10-11 10:00:00'),
(4, 4, 12, 'VA-2026-0004', 'Paid', 'Credit card', 0.00, '2026-04-14 00:00:00', '2026-04-14 10:00:00'),
(5, 4, 4, 'VA-2026-0005', 'Pending', NULL, 0.00, '2026-11-10 08:31:38', NULL),
(6, 4, 6, 'VA-2026-0006', 'Pending', NULL, 0.00, '2026-11-10 08:31:38', NULL),
(7, 4, 10, 'VA-2026-0007', 'Refunded', 'Credit card', 0.00, '2026-10-23 00:00:00', '2026-10-23 10:00:00'),
(8, 1, 13, 'VA-2026-0008', 'Pending', NULL, 0.00, '2026-11-10 08:31:38', NULL),
(9, 2, 15, 'VA-2026-0009', 'Paid', 'Online banking', 0.00, '2026-11-09 00:00:00', '2026-11-09 10:00:00'),
(13, 1, 44, 'VA-2026-0013', 'Pending', NULL, 0.00, '2026-11-10 12:28:53', NULL),
(14, 1, 45, 'VA-2026-0014', 'Pending', NULL, 0.00, '2026-11-10 12:33:27', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `payment_items`
--

CREATE TABLE `payment_items` (
  `item_id` int(11) NOT NULL,
  `payment_id` int(11) NOT NULL,
  `label` varchar(150) NOT NULL,
  `amount` decimal(8,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payment_items`
--

INSERT INTO `payment_items` (`item_id`, `payment_id`, `label`, `amount`) VALUES
(1, 1, 'Typhoid vaccine', 95.00),
(2, 1, 'Consultation fee', 40.00),
(3, 2, 'Hepatitis A vaccine (dose 1)', 120.00),
(4, 2, 'Consultation fee', 40.00),
(5, 3, 'DTaP-IPV-Hib (dose 3)', 180.00),
(6, 3, 'Consultation fee', 40.00),
(7, 4, 'Influenza vaccine', 70.00),
(8, 4, 'Consultation fee', 40.00),
(9, 5, 'Yellow Fever vaccine', 130.00),
(10, 5, 'Consultation fee', 40.00),
(11, 6, 'Influenza vaccine', 70.00),
(12, 6, 'Consultation fee', 40.00),
(13, 7, 'Booking deposit (refunded)', 20.00),
(14, 8, 'Influenza vaccine', 70.00),
(15, 8, 'Consultation fee', 40.00),
(16, 9, 'Yellow Fever vaccine', 130.00),
(17, 9, 'Consultation fee', 40.00),
(24, 13, 'Td Booster', 55.00),
(25, 13, 'Consultation fee', 40.00),
(26, 14, 'Pneumococcal (PCV)', 230.00),
(27, 14, 'Consultation fee', 40.00);

-- --------------------------------------------------------

--
-- Table structure for table `precheck_forms`
--

CREATE TABLE `precheck_forms` (
  `form_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `appointment_id` int(11) DEFAULT NULL,
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
  `submitted_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `precheck_forms`
--

INSERT INTO `precheck_forms` (`form_id`, `patient_id`, `appointment_id`, `child_id`, `vaccine_id`, `has_fever`, `severe_reaction`, `weak_immune_system`, `pregnant_or_breastfeeding`, `recent_vaccine`, `bleeding_disorder`, `allergies`, `medications`, `notes`, `submitted_at`) VALUES
(1, 1, 41, NULL, 1, 1, 1, 1, 1, 1, 1, 'try', NULL, NULL, '2026-11-10 09:02:07'),
(2, 1, 45, NULL, 12, 0, 1, 0, 1, 0, 1, NULL, NULL, NULL, '2026-11-10 12:33:16');

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `review_id` int(11) NOT NULL,
  `appointment_id` int(11) NOT NULL COMMENT 'one review per visit; the doctor comes from the appointment',
  `patient_id` int(11) NOT NULL,
  `rating` tinyint(3) UNSIGNED NOT NULL,
  `comment` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ;

--
-- Dumping data for table `reviews`
--

INSERT INTO `reviews` (`review_id`, `appointment_id`, `patient_id`, `rating`, `comment`, `created_at`) VALUES
(1, 17, 1, 5, 'Very gentle and clear.', '2026-11-10 08:31:38'),
(2, 18, 2, 5, 'Explained everything well.', '2026-11-10 08:31:38'),
(3, 19, 3, 5, 'Quick and friendly.', '2026-11-10 08:31:38'),
(4, 20, 1, 5, 'Explained everything well.', '2026-11-10 08:31:38'),
(5, 21, 2, 5, 'Quick and friendly.', '2026-11-10 08:31:38'),
(6, 22, 3, 4, 'Felt looked after.', '2026-11-10 08:31:38'),
(7, 23, 1, 5, 'Quick and friendly.', '2026-11-10 08:31:38'),
(8, 24, 2, 4, 'Felt looked after.', '2026-11-10 08:31:38'),
(9, 25, 3, 5, 'Good advice, short wait.', '2026-11-10 08:31:38'),
(10, 26, 1, 5, 'Felt looked after.', '2026-11-10 08:31:38'),
(11, 27, 2, 4, 'Good advice, short wait.', '2026-11-10 08:31:38'),
(12, 28, 3, 4, NULL, '2026-11-10 08:31:38'),
(13, 29, 1, 4, 'Good advice, short wait.', '2026-11-10 08:31:38'),
(14, 30, 2, 5, NULL, '2026-11-10 08:31:38'),
(15, 31, 3, 5, 'Very gentle and clear.', '2026-11-10 08:31:38'),
(16, 32, 1, 5, NULL, '2026-11-10 08:31:38'),
(17, 33, 2, 5, 'Very gentle and clear.', '2026-11-10 08:31:38'),
(18, 34, 3, 4, 'Explained everything well.', '2026-11-10 08:31:38'),
(19, 35, 1, 4, 'Very gentle and clear.', '2026-11-10 08:31:38'),
(20, 36, 2, 5, 'Explained everything well.', '2026-11-10 08:31:38'),
(21, 37, 3, 4, 'Quick and friendly.', '2026-11-10 08:31:38'),
(22, 38, 1, 5, 'Explained everything well.', '2026-11-10 08:31:38'),
(23, 39, 2, 5, 'Quick and friendly.', '2026-11-10 08:31:38'),
(24, 40, 3, 5, 'Felt looked after.', '2026-11-10 08:31:38'),
(25, 12, 4, 5, 'Quick and painless.', '2026-11-10 08:31:38');

-- --------------------------------------------------------

--
-- Table structure for table `staff`
--

CREATE TABLE `staff` (
  `id` int(10) UNSIGNED NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `role` enum('Administrator','Doctor','Nurse','Receptionist') NOT NULL,
  `department` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `staff`
--

INSERT INTO `staff` (`id`, `first_name`, `last_name`, `email`, `phone`, `role`, `department`, `created_at`, `updated_at`) VALUES
(2, 'Jason', '', 'jason001@gmail.com', '011-222-3344', 'Administrator', 'Vaccination', '2026-10-18 20:11:08', '2026-10-18 20:11:08'),
(3, 'Alex', '', 'alextan2001@gmail.com', '012- 567- 0962', 'Doctor', 'X-Ray', '2026-10-18 20:18:29', '2026-10-18 20:18:29'),
(5, 'Alex', '', 'test1@gmail.com', '011-222-3344', 'Doctor', 'Vaccination', '2026-10-19 18:45:52', '2026-10-19 18:45:52');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(30) NOT NULL,
  `dob` date NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `terms_accepted` tinyint(1) NOT NULL DEFAULT 0,
  `role` varchar(30) NOT NULL DEFAULT 'Administrator'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `first_name`, `last_name`, `email`, `phone`, `dob`, `password_hash`, `created_at`, `terms_accepted`, `role`) VALUES
(5, 'Chng', 'Zhe Han', 'hanzhechng001@gmail.com', '011 111 1111', '2020-03-11', '$2y$10$rBiSluongP1x.OYBfB4eqOxZZyZa0nTriUvIk4qGrpA3MOkO.L8zC', '2026-10-13 21:57:51', 1, 'Administrator'),
(9, 'Victor', 'Lai', 'victor1996@gmail.com', '016-558-9572', '1996-02-22', '$2y$10$w94kZXHg.tK7/NIyYmLsOOqhSlxHo9rpVjVAs7vBbzIEbg/G71YJu', '2026-10-25 21:04:19', 1, 'Administrator');

-- --------------------------------------------------------

--
-- Table structure for table `vaccination_records`
--

CREATE TABLE `vaccination_records` (
  `record_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL COMMENT 'the account owner (the parent, for a child)',
  `child_id` int(11) DEFAULT NULL COMMENT 'NULL = the patient themself',
  `vaccine_id` int(11) NOT NULL,
  `batch_id` int(11) DEFAULT NULL,
  `doctor_id` int(11) DEFAULT NULL,
  `appointment_id` int(11) DEFAULT NULL,
  `dose_number` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `date_given` date NOT NULL,
  `next_dose_date` date DEFAULT NULL,
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `vaccination_records`
--

INSERT INTO `vaccination_records` (`record_id`, `patient_id`, `child_id`, `vaccine_id`, `batch_id`, `doctor_id`, `appointment_id`, `dose_number`, `date_given`, `next_dose_date`, `notes`) VALUES
(1, 4, NULL, 2, 1, 2, NULL, 1, '2026-10-29', NULL, 'Booster needed after 3 years if still travelling.'),
(2, 4, NULL, 3, 2, 9, NULL, 1, '2026-09-30', '2026-12-20', 'Second dose 6 to 12 months after the first.'),
(3, 4, NULL, 17, 3, 4, NULL, 1, '2026-04-14', '2027-04-14', NULL),
(4, 4, NULL, 16, 4, 4, NULL, 1, '2023-11-06', '2033-11-03', 'Repeat every 10 years.'),
(5, 4, 1, 9, 5, 8, NULL, 1, '2025-09-06', NULL, NULL),
(6, 4, 1, 10, 6, 3, NULL, 3, '2026-03-05', NULL, 'Course complete.'),
(7, 4, 1, 13, 7, 3, NULL, 2, '2026-01-09', NULL, 'Course complete.'),
(8, 4, 1, 12, 8, 3, NULL, 2, '2026-01-14', '2026-10-31', 'Booster dose at 12 months.'),
(9, 4, 1, 11, 9, 8, NULL, 3, '2026-10-11', '2027-02-23', 'Booster due at 18 months.'),
(10, 1, 2, 9, 12, 8, NULL, 1, '2024-06-13', NULL, NULL),
(11, 1, 2, 10, 10, 8, NULL, 1, '2024-06-13', NULL, NULL),
(12, 1, 2, 10, 10, 3, NULL, 2, '2024-07-13', NULL, NULL),
(13, 1, 2, 11, 11, 3, NULL, 1, '2024-08-12', '2024-12-10', 'Dose 2 was due about two months later.'),
(14, 2, NULL, 3, 13, 2, NULL, 1, '2026-10-21', '2027-04-19', 'Second dose 6 months after the first.'),
(15, 2, NULL, 2, 14, 2, NULL, 1, '2026-10-21', NULL, NULL),
(16, 1, NULL, 9, 12, 1, 1, 1, '2026-11-10', '2026-11-26', 'try'),
(17, 3, NULL, 16, 4, 1, 3, 1, '2026-11-10', '2026-11-13', '');

-- --------------------------------------------------------

--
-- Table structure for table `vaccines`
--

CREATE TABLE `vaccines` (
  `vaccine_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `category` enum('Travel','Childhood','Booster','Consultation') NOT NULL,
  `total_doses` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `price` decimal(8,2) NOT NULL DEFAULT 0.00 COMMENT 'demo price in RM',
  `lead_days` smallint(6) DEFAULT NULL COMMENT 'travel vaccines: ideal days before departure'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `vaccines`
--

INSERT INTO `vaccines` (`vaccine_id`, `name`, `category`, `total_doses`, `price`, `lead_days`) VALUES
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

-- --------------------------------------------------------

--
-- Table structure for table `vaccine_batches`
--

CREATE TABLE `vaccine_batches` (
  `batch_id` int(11) NOT NULL,
  `vaccine_id` int(11) NOT NULL,
  `batch_number` varchar(50) NOT NULL,
  `manufacturer` varchar(100) DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `quantity_in_stock` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `vaccine_batches`
--

INSERT INTO `vaccine_batches` (`batch_id`, `vaccine_id`, `batch_number`, `manufacturer`, `expiry_date`, `quantity_in_stock`) VALUES
(1, 2, 'TY-22914B', 'Demo Pharma', '2028-05-10', 100),
(2, 3, 'HA-80731C', 'Demo Pharma', '2028-05-10', 100),
(3, 17, 'FLU-5519A', 'Demo Pharma', '2028-05-10', 100),
(4, 16, 'TD-30276D', 'Demo Pharma', '2028-05-10', 99),
(5, 9, 'BCG-1102', 'Demo Pharma', '2028-05-10', 100),
(6, 10, 'HB-77410', 'Demo Pharma', '2028-05-10', 100),
(7, 13, 'RV-4408', 'Demo Pharma', '2028-05-10', 100),
(8, 12, 'PCV-9912', 'Demo Pharma', '2028-05-10', 100),
(9, 11, 'DTP-6063', 'Demo Pharma', '2028-05-10', 100),
(10, 10, 'HB-5521', 'Demo Pharma', '2028-05-10', 100),
(11, 11, 'DTP-5110', 'Demo Pharma', '2028-05-10', 100),
(12, 9, 'BCG-0991', 'Demo Pharma', '2028-05-10', 99),
(13, 3, 'HA-9902', 'Demo Pharma', '2028-05-10', 100),
(14, 2, 'TY-30011', 'Demo Pharma', '2028-05-10', 100);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `appointments`
--
ALTER TABLE `appointments`
  ADD PRIMARY KEY (`appointment_id`),
  ADD KEY `doctor_id` (`doctor_id`),
  ADD KEY `patient_id` (`patient_id`),
  ADD KEY `idx_appt_child` (`child_id`),
  ADD KEY `idx_appt_vaccine` (`vaccine_id`),
  ADD KEY `idx_appt_doctor_date` (`doctor_id`,`appointment_date`);

--
-- Indexes for table `children`
--
ALTER TABLE `children`
  ADD PRIMARY KEY (`child_id`),
  ADD KEY `idx_children_patient` (`patient_id`);

--
-- Indexes for table `child_schedule`
--
ALTER TABLE `child_schedule`
  ADD PRIMARY KEY (`schedule_id`),
  ADD KEY `idx_schedule_age` (`age_months`),
  ADD KEY `fk_schedule_vaccine` (`vaccine_id`);

--
-- Indexes for table `consultation_records`
--
ALTER TABLE `consultation_records`
  ADD PRIMARY KEY (`record_id`),
  ADD KEY `doctor_id` (`doctor_id`),
  ADD KEY `patient_id` (`patient_id`);

--
-- Indexes for table `contact_messages`
--
ALTER TABLE `contact_messages`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `idx_contact_ip_time` (`ip_address`,`created_at`),
  ADD KEY `fk_contact_patient` (`patient_id`);

--
-- Indexes for table `destinations`
--
ALTER TABLE `destinations`
  ADD PRIMARY KEY (`destination_id`),
  ADD UNIQUE KEY `uq_country_code` (`country_code`),
  ADD UNIQUE KEY `uq_country` (`country`);

--
-- Indexes for table `destination_vaccines`
--
ALTER TABLE `destination_vaccines`
  ADD PRIMARY KEY (`destination_id`,`vaccine_id`),
  ADD KEY `fk_dv_vaccine` (`vaccine_id`);

--
-- Indexes for table `doctors`
--
ALTER TABLE `doctors`
  ADD PRIMARY KEY (`doctor_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `doctor_availability`
--
ALTER TABLE `doctor_availability`
  ADD PRIMARY KEY (`doctor_id`,`weekday`);

--
-- Indexes for table `doctor_notification_cursors`
--
ALTER TABLE `doctor_notification_cursors`
  ADD PRIMARY KEY (`doctor_id`);

--
-- Indexes for table `doctor_password_resets`
--
ALTER TABLE `doctor_password_resets`
  ADD PRIMARY KEY (`reset_id`),
  ADD UNIQUE KEY `token_hash` (`token_hash`),
  ADD KEY `idx_doctor_reset` (`doctor_id`,`used`);

--
-- Indexes for table `doctor_patient_links`
--
ALTER TABLE `doctor_patient_links`
  ADD PRIMARY KEY (`doctor_id`,`patient_id`),
  ADD KEY `idx_doctor_patient_links_patient` (`patient_id`);

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
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`notification_id`),
  ADD KEY `idx_notif_patient_read` (`patient_id`,`is_read`),
  ADD KEY `idx_notif_doctor_unread` (`doctor_id`,`is_read`),
  ADD KEY `idx_notif_appointment` (`appointment_id`),
  ADD KEY `idx_notif_doctor_recipient_unread` (`doctor_id`,`recipient_type`,`is_read`);

--
-- Indexes for table `notification_preferences`
--
ALTER TABLE `notification_preferences`
  ADD PRIMARY KEY (`patient_id`);

--
-- Indexes for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD PRIMARY KEY (`reset_id`),
  ADD UNIQUE KEY `uq_reset_token` (`token_hash`),
  ADD KEY `fk_reset_patient` (`patient_id`);

--
-- Indexes for table `patients`
--
ALTER TABLE `patients`
  ADD PRIMARY KEY (`patient_id`),
  ADD UNIQUE KEY `ic_passport` (`ic_passport`),
  ADD UNIQUE KEY `uq_patients_email` (`email`);

--
-- Indexes for table `patient_health_items`
--
ALTER TABLE `patient_health_items`
  ADD PRIMARY KEY (`item_id`),
  ADD UNIQUE KEY `uq_health_item` (`patient_id`,`item_type`,`name`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`payment_id`),
  ADD UNIQUE KEY `uq_receipt_no` (`receipt_no`),
  ADD KEY `idx_pay_patient_status` (`patient_id`,`status`),
  ADD KEY `fk_pay_appointment` (`appointment_id`);

--
-- Indexes for table `payment_items`
--
ALTER TABLE `payment_items`
  ADD PRIMARY KEY (`item_id`),
  ADD KEY `idx_item_payment` (`payment_id`);

--
-- Indexes for table `precheck_forms`
--
ALTER TABLE `precheck_forms`
  ADD PRIMARY KEY (`form_id`),
  ADD KEY `idx_precheck_patient` (`patient_id`),
  ADD KEY `fk_precheck_child` (`child_id`),
  ADD KEY `fk_precheck_vaccine` (`vaccine_id`),
  ADD KEY `idx_precheck_appointment` (`appointment_id`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`review_id`),
  ADD UNIQUE KEY `uq_review_appointment` (`appointment_id`),
  ADD KEY `idx_review_patient` (`patient_id`);

--
-- Indexes for table `staff`
--
ALTER TABLE `staff`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `vaccination_records`
--
ALTER TABLE `vaccination_records`
  ADD PRIMARY KEY (`record_id`),
  ADD KEY `idx_vr_patient` (`patient_id`),
  ADD KEY `idx_vr_child` (`child_id`),
  ADD KEY `idx_vr_vaccine` (`vaccine_id`),
  ADD KEY `idx_vr_batch` (`batch_id`),
  ADD KEY `fk_vr_doctor` (`doctor_id`),
  ADD KEY `fk_vr_appointment` (`appointment_id`);

--
-- Indexes for table `vaccines`
--
ALTER TABLE `vaccines`
  ADD PRIMARY KEY (`vaccine_id`),
  ADD UNIQUE KEY `uq_vaccine_name` (`name`);

--
-- Indexes for table `vaccine_batches`
--
ALTER TABLE `vaccine_batches`
  ADD PRIMARY KEY (`batch_id`),
  ADD UNIQUE KEY `uq_batch_number` (`batch_number`),
  ADD KEY `idx_batch_expiry` (`expiry_date`),
  ADD KEY `fk_batch_vaccine` (`vaccine_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `appointments`
--
ALTER TABLE `appointments`
  MODIFY `appointment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;

--
-- AUTO_INCREMENT for table `children`
--
ALTER TABLE `children`
  MODIFY `child_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `child_schedule`
--
ALTER TABLE `child_schedule`
  MODIFY `schedule_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `consultation_records`
--
ALTER TABLE `consultation_records`
  MODIFY `record_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `contact_messages`
--
ALTER TABLE `contact_messages`
  MODIFY `message_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `destinations`
--
ALTER TABLE `destinations`
  MODIFY `destination_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `doctors`
--
ALTER TABLE `doctors`
  MODIFY `doctor_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `doctor_password_resets`
--
ALTER TABLE `doctor_password_resets`
  MODIFY `reset_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `leave_requests`
--
ALTER TABLE `leave_requests`
  MODIFY `leave_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `message_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `notification_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `password_resets`
--
ALTER TABLE `password_resets`
  MODIFY `reset_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `patients`
--
ALTER TABLE `patients`
  MODIFY `patient_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `patient_health_items`
--
ALTER TABLE `patient_health_items`
  MODIFY `item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `payment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `payment_items`
--
ALTER TABLE `payment_items`
  MODIFY `item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `precheck_forms`
--
ALTER TABLE `precheck_forms`
  MODIFY `form_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `review_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `staff`
--
ALTER TABLE `staff`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `vaccination_records`
--
ALTER TABLE `vaccination_records`
  MODIFY `record_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `vaccines`
--
ALTER TABLE `vaccines`
  MODIFY `vaccine_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `vaccine_batches`
--
ALTER TABLE `vaccine_batches`
  MODIFY `batch_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `appointments`
--
ALTER TABLE `appointments`
  ADD CONSTRAINT `appointments_ibfk_1` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `appointments_ibfk_2` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_appt_child` FOREIGN KEY (`child_id`) REFERENCES `children` (`child_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_appt_vaccine` FOREIGN KEY (`vaccine_id`) REFERENCES `vaccines` (`vaccine_id`) ON DELETE SET NULL;

--
-- Constraints for table `children`
--
ALTER TABLE `children`
  ADD CONSTRAINT `fk_children_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE;

--
-- Constraints for table `child_schedule`
--
ALTER TABLE `child_schedule`
  ADD CONSTRAINT `fk_schedule_vaccine` FOREIGN KEY (`vaccine_id`) REFERENCES `vaccines` (`vaccine_id`) ON DELETE CASCADE;

--
-- Constraints for table `consultation_records`
--
ALTER TABLE `consultation_records`
  ADD CONSTRAINT `consultation_records_ibfk_1` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `consultation_records_ibfk_2` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE;

--
-- Constraints for table `contact_messages`
--
ALTER TABLE `contact_messages`
  ADD CONSTRAINT `fk_contact_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE SET NULL;

--
-- Constraints for table `destination_vaccines`
--
ALTER TABLE `destination_vaccines`
  ADD CONSTRAINT `fk_dv_destination` FOREIGN KEY (`destination_id`) REFERENCES `destinations` (`destination_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_dv_vaccine` FOREIGN KEY (`vaccine_id`) REFERENCES `vaccines` (`vaccine_id`) ON DELETE CASCADE;

--
-- Constraints for table `doctor_availability`
--
ALTER TABLE `doctor_availability`
  ADD CONSTRAINT `fk_avail_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE CASCADE;

--
-- Constraints for table `doctor_notification_cursors`
--
ALTER TABLE `doctor_notification_cursors`
  ADD CONSTRAINT `fk_doctor_cursor_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE CASCADE;

--
-- Constraints for table `doctor_password_resets`
--
ALTER TABLE `doctor_password_resets`
  ADD CONSTRAINT `fk_doctor_reset_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE CASCADE;

--
-- Constraints for table `doctor_patient_links`
--
ALTER TABLE `doctor_patient_links`
  ADD CONSTRAINT `fk_dpl_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_dpl_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE;

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

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `fk_notif_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`appointment_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_notif_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_notif_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE;

--
-- Constraints for table `notification_preferences`
--
ALTER TABLE `notification_preferences`
  ADD CONSTRAINT `fk_pref_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE;

--
-- Constraints for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD CONSTRAINT `fk_reset_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE;

--
-- Constraints for table `patient_health_items`
--
ALTER TABLE `patient_health_items`
  ADD CONSTRAINT `fk_health_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE;

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `fk_pay_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`appointment_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_pay_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE;

--
-- Constraints for table `payment_items`
--
ALTER TABLE `payment_items`
  ADD CONSTRAINT `fk_item_payment` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`payment_id`) ON DELETE CASCADE;

--
-- Constraints for table `precheck_forms`
--
ALTER TABLE `precheck_forms`
  ADD CONSTRAINT `fk_precheck_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`appointment_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_precheck_child` FOREIGN KEY (`child_id`) REFERENCES `children` (`child_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_precheck_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_precheck_vaccine` FOREIGN KEY (`vaccine_id`) REFERENCES `vaccines` (`vaccine_id`) ON DELETE SET NULL;

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `fk_review_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`appointment_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_review_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE;

--
-- Constraints for table `vaccination_records`
--
ALTER TABLE `vaccination_records`
  ADD CONSTRAINT `fk_vr_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`appointment_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_vr_batch` FOREIGN KEY (`batch_id`) REFERENCES `vaccine_batches` (`batch_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_vr_child` FOREIGN KEY (`child_id`) REFERENCES `children` (`child_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_vr_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_vr_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_vr_vaccine` FOREIGN KEY (`vaccine_id`) REFERENCES `vaccines` (`vaccine_id`);

--
-- Constraints for table `vaccine_batches`
--
ALTER TABLE `vaccine_batches`
  ADD CONSTRAINT `fk_batch_vaccine` FOREIGN KEY (`vaccine_id`) REFERENCES `vaccines` (`vaccine_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
