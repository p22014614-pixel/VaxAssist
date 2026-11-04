-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: vaxassist_db
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `appointments`
--

DROP TABLE IF EXISTS `appointments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
  `cancel_reason` varchar(300) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointments`
--

LOCK TABLES `appointments` WRITE;
/*!40000 ALTER TABLE `appointments` DISABLE KEYS */;
INSERT INTO `appointments` VALUES (1,1,1,NULL,NULL,'2026-10-18',NULL,'08:00 AM - 10:00 AM','Completed','Cardiology Routine Review & ECG',NULL,'2026-10-18 06:58:13'),(2,1,2,NULL,NULL,'2026-10-18',NULL,'10:00 AM - 12:00 PM','Scheduled','Influenza Vaccine Consultation',NULL,'2026-10-18 06:58:13'),(3,1,3,NULL,NULL,'2026-10-18',NULL,'01:00 PM - 03:00 PM','Scheduled','Orthopedic Joint Checkup',NULL,'2026-10-18 06:58:13'),(0,0,0,NULL,1,'2026-11-02','10:00:00','10:00 AM - 12:00 PM','Scheduled','Travelling to Ghana next month.',NULL,'2026-10-24 15:48:38'),(0,0,0,1,14,'2026-11-02','14:30:00','01:00 PM - 03:00 PM','Scheduled',NULL,NULL,'2026-10-24 15:48:38'),(0,0,0,NULL,17,'2026-11-16','09:30:00','08:00 AM - 10:00 AM','Scheduled',NULL,NULL,'2026-10-24 15:48:38'),(0,0,0,NULL,2,'2026-10-12','11:00:00','10:00 AM - 12:00 PM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,0,1,11,'2026-09-24','15:00:00','03:00 PM - 05:00 PM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,0,NULL,3,'2026-09-13','10:30:00','10:00 AM - 12:00 PM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,0,NULL,3,'2026-10-06','11:30:00','10:00 AM - 12:00 PM','Cancelled',NULL,'Change of plans.','2026-10-24 15:48:38'),(0,0,0,NULL,16,'2026-08-25','16:00:00','03:00 PM - 05:00 PM','Missed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,0,NULL,17,'2026-03-28','09:00:00','08:00 AM - 10:00 AM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,1,NULL,17,'2026-11-02','10:30:00','10:00 AM - 12:00 PM','Scheduled',NULL,NULL,'2026-10-24 15:48:38'),(0,0,1,2,14,'2026-08-25','14:00:00','01:00 PM - 03:00 PM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,2,NULL,1,'2026-11-02','09:00:00','08:00 AM - 10:00 AM','Scheduled','Trip to Kenya in six weeks.',NULL,'2026-10-24 15:48:38'),(0,0,3,NULL,16,'2026-10-26','15:30:00','03:00 PM - 05:00 PM','Scheduled',NULL,NULL,'2026-10-24 15:48:38'),(0,0,1,NULL,2,'2026-07-26','09:00:00','08:00 AM - 10:00 AM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,2,NULL,2,'2026-06-26','10:00:00','10:00 AM - 12:00 PM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,3,NULL,2,'2026-05-27','11:00:00','10:00 AM - 12:00 PM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,1,NULL,14,'2026-07-19','09:00:00','08:00 AM - 10:00 AM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,2,NULL,14,'2026-06-19','10:00:00','10:00 AM - 12:00 PM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,3,NULL,14,'2026-05-20','11:00:00','10:00 AM - 12:00 PM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,1,NULL,17,'2026-07-12','09:00:00','08:00 AM - 10:00 AM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,2,NULL,17,'2026-06-12','10:00:00','10:00 AM - 12:00 PM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,3,NULL,17,'2026-05-13','11:00:00','10:00 AM - 12:00 PM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,1,NULL,16,'2026-07-05','09:00:00','08:00 AM - 10:00 AM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,2,NULL,16,'2026-06-05','10:00:00','10:00 AM - 12:00 PM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,3,NULL,16,'2026-05-06','11:00:00','10:00 AM - 12:00 PM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,1,NULL,10,'2026-06-28','09:00:00','08:00 AM - 10:00 AM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,2,NULL,10,'2026-05-29','10:00:00','10:00 AM - 12:00 PM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,3,NULL,10,'2026-04-29','11:00:00','10:00 AM - 12:00 PM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,1,NULL,16,'2026-06-21','09:00:00','08:00 AM - 10:00 AM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,2,NULL,16,'2026-05-22','10:00:00','10:00 AM - 12:00 PM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,3,NULL,16,'2026-04-22','11:00:00','10:00 AM - 12:00 PM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,1,NULL,14,'2026-06-14','09:00:00','08:00 AM - 10:00 AM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,2,NULL,14,'2026-05-15','10:00:00','10:00 AM - 12:00 PM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,3,NULL,14,'2026-04-15','11:00:00','10:00 AM - 12:00 PM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,1,NULL,17,'2026-06-07','09:00:00','08:00 AM - 10:00 AM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,2,NULL,17,'2026-05-08','10:00:00','10:00 AM - 12:00 PM','Completed',NULL,NULL,'2026-10-24 15:48:38'),(0,0,3,NULL,17,'2026-04-08','11:00:00','10:00 AM - 12:00 PM','Completed',NULL,NULL,'2026-10-24 15:48:38');
/*!40000 ALTER TABLE `appointments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `child_schedule`
--

DROP TABLE IF EXISTS `child_schedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `child_schedule` (
  `schedule_id` int(11) NOT NULL AUTO_INCREMENT,
  `vaccine_id` int(11) NOT NULL,
  `age_months` smallint(6) NOT NULL COMMENT 'age when the dose is due',
  `dose_number` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT '0 = not tracked (e.g. yearly flu shot)',
  `dose_label` varchar(30) NOT NULL,
  `requirement` enum('Required','Recommended') NOT NULL,
  `reason` text DEFAULT NULL,
  PRIMARY KEY (`schedule_id`),
  KEY `idx_schedule_age` (`age_months`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `child_schedule`
--

LOCK TABLES `child_schedule` WRITE;
/*!40000 ALTER TABLE `child_schedule` DISABLE KEYS */;
INSERT INTO `child_schedule` VALUES (1,9,0,1,'Single dose','Required','Protects against severe forms of tuberculosis.'),(2,10,0,1,'Dose 1 of 3','Required','Protects the liver against hepatitis B infection.'),(3,10,1,2,'Dose 2 of 3','Required','Second dose of the hepatitis B course.'),(4,11,2,1,'Dose 1 of 4','Required','Covers diphtheria, tetanus, whooping cough, polio and Hib in one injection.'),(5,12,2,1,'Dose 1 of 4','Required','Protects against pneumonia, meningitis and ear infections.'),(6,13,2,1,'Dose 1 of 2','Recommended','Oral vaccine that prevents severe diarrhoea in babies.'),(7,11,3,2,'Dose 2 of 4','Required','Second dose of the five-in-one vaccine.'),(8,12,3,2,'Dose 2 of 4','Required','Second dose of the pneumococcal course.'),(9,13,3,2,'Dose 2 of 2','Recommended','Completes the rotavirus course.'),(10,11,5,3,'Dose 3 of 4','Required','Third dose of the five-in-one vaccine.'),(11,12,5,3,'Dose 3 of 4','Required','Third dose of the pneumococcal course.'),(12,10,6,3,'Dose 3 of 3','Required','Completes the hepatitis B course.'),(13,17,6,0,'Yearly','Recommended','Flu vaccine is advised every year from 6 months old.'),(14,14,9,1,'Dose 1 of 2','Required','Protects against measles, mumps and rubella.'),(15,12,12,4,'Booster','Required','Booster dose to keep protection strong.'),(16,14,12,2,'Dose 2 of 2','Required','Second dose gives long-lasting protection.'),(17,15,12,1,'Dose 1 of 2','Recommended','Protects against chickenpox and shingles later in life.'),(18,11,18,4,'Booster','Required','Booster dose of the five-in-one vaccine.'),(19,15,36,2,'Dose 2 of 2','Recommended','Second dose completes chickenpox protection.');
/*!40000 ALTER TABLE `child_schedule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `children`
--

DROP TABLE IF EXISTS `children`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `children` (
  `child_id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_id` int(11) NOT NULL COMMENT 'the parent',
  `first_name` varchar(50) NOT NULL,
  `dob` date NOT NULL,
  `gender` enum('Male','Female','Other') NOT NULL DEFAULT 'Male',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`child_id`),
  KEY `idx_children_patient` (`patient_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `children`
--

LOCK TABLES `children` WRITE;
/*!40000 ALTER TABLE `children` DISABLE KEYS */;
INSERT INTO `children` VALUES (1,0,'Aiden','2025-08-20','Male','2026-10-24 15:48:38'),(2,1,'Noah','2024-05-07','Male','2026-10-24 15:48:38');
/*!40000 ALTER TABLE `children` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `consultation_records`
--

DROP TABLE IF EXISTS `consultation_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `consultation_records`
--

LOCK TABLES `consultation_records` WRITE;
/*!40000 ALTER TABLE `consultation_records` DISABLE KEYS */;
/*!40000 ALTER TABLE `consultation_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `destination_vaccines`
--

DROP TABLE IF EXISTS `destination_vaccines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `destination_vaccines` (
  `destination_id` int(11) NOT NULL,
  `vaccine_id` int(11) NOT NULL,
  `requirement` enum('Required','Recommended') NOT NULL,
  `reason` text DEFAULT NULL,
  PRIMARY KEY (`destination_id`,`vaccine_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `destination_vaccines`
--

LOCK TABLES `destination_vaccines` WRITE;
/*!40000 ALTER TABLE `destination_vaccines` DISABLE KEYS */;
INSERT INTO `destination_vaccines` VALUES (1,14,'Recommended','Measles outbreaks happen worldwide. Make sure you have had two doses.'),(1,16,'Recommended','Keeps tetanus and diphtheria cover up to date (every 10 years).'),(1,17,'Recommended','Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),(2,1,'Recommended','Mosquito-borne and present in this region. One dose gives lifelong protection.'),(2,2,'Recommended','Spread through contaminated food and water, especially if you eat street food or stay with locals.'),(2,3,'Recommended','Spread through food and water. Advised for almost every destination outside Europe and North America.'),(2,4,'Recommended','Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),(2,17,'Recommended','Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),(3,2,'Recommended','Spread through contaminated food and water, especially if you eat street food or stay with locals.'),(3,3,'Recommended','Spread through food and water. Advised for almost every destination outside Europe and North America.'),(3,4,'Recommended','Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),(3,5,'Recommended','Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),(4,2,'Recommended','Spread through contaminated food and water, especially if you eat street food or stay with locals.'),(4,3,'Recommended','Spread through food and water. Advised for almost every destination outside Europe and North America.'),(4,5,'Recommended','Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),(4,14,'Recommended','Measles outbreaks happen worldwide. Make sure you have had two doses.'),(4,17,'Recommended','Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),(5,2,'Recommended','Spread through contaminated food and water, especially if you eat street food or stay with locals.'),(5,3,'Recommended','Spread through food and water. Advised for almost every destination outside Europe and North America.'),(5,8,'Recommended','Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),(5,16,'Recommended','Keeps tetanus and diphtheria cover up to date (every 10 years).'),(6,1,'Required','A yellow fever certificate is required to enter. One dose gives lifelong protection.'),(6,2,'Recommended','Spread through contaminated food and water, especially if you eat street food or stay with locals.'),(6,3,'Recommended','Spread through food and water. Advised for almost every destination outside Europe and North America.'),(6,4,'Recommended','Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),(6,6,'Recommended','Advised for the African meningitis belt, especially during the dry season.'),(6,8,'Recommended','Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),(7,2,'Recommended','Spread through contaminated food and water, especially if you eat street food or stay with locals.'),(7,3,'Recommended','Spread through food and water. Advised for almost every destination outside Europe and North America.'),(7,4,'Recommended','Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),(7,5,'Recommended','Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),(7,7,'Recommended','Mainly for aid workers or travellers to areas with active outbreaks.'),(7,8,'Recommended','Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),(8,2,'Recommended','Spread through contaminated food and water, especially if you eat street food or stay with locals.'),(8,3,'Recommended','Spread through food and water. Advised for almost every destination outside Europe and North America.'),(8,4,'Recommended','Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),(8,5,'Recommended','Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),(8,16,'Recommended','Keeps tetanus and diphtheria cover up to date (every 10 years).'),(9,3,'Recommended','Spread through food and water. Advised for almost every destination outside Europe and North America.'),(9,5,'Recommended','Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),(9,14,'Recommended','Measles outbreaks happen worldwide. Make sure you have had two doses.'),(9,17,'Recommended','Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),(10,1,'Recommended','Mosquito-borne and present in this region. One dose gives lifelong protection.'),(10,2,'Recommended','Spread through contaminated food and water, especially if you eat street food or stay with locals.'),(10,3,'Recommended','Spread through food and water. Advised for almost every destination outside Europe and North America.'),(10,4,'Recommended','Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),(10,6,'Recommended','Advised for the African meningitis belt, especially during the dry season.'),(10,8,'Recommended','Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),(11,2,'Recommended','Spread through contaminated food and water, especially if you eat street food or stay with locals.'),(11,3,'Recommended','Spread through food and water. Advised for almost every destination outside Europe and North America.'),(11,4,'Recommended','Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),(11,5,'Recommended','Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),(11,6,'Recommended','Advised for the African meningitis belt, especially during the dry season.'),(11,8,'Recommended','Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),(12,1,'Required','A yellow fever certificate is required to enter. One dose gives lifelong protection.'),(12,2,'Recommended','Spread through contaminated food and water, especially if you eat street food or stay with locals.'),(12,3,'Recommended','Spread through food and water. Advised for almost every destination outside Europe and North America.'),(12,6,'Recommended','Advised for the African meningitis belt, especially during the dry season.'),(12,7,'Recommended','Mainly for aid workers or travellers to areas with active outbreaks.'),(12,8,'Recommended','Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),(13,1,'Recommended','Mosquito-borne and present in this region. One dose gives lifelong protection.'),(13,2,'Recommended','Spread through contaminated food and water, especially if you eat street food or stay with locals.'),(13,3,'Recommended','Spread through food and water. Advised for almost every destination outside Europe and North America.'),(13,4,'Recommended','Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),(14,2,'Recommended','Spread through contaminated food and water, especially if you eat street food or stay with locals.'),(14,3,'Recommended','Spread through food and water. Advised for almost every destination outside Europe and North America.'),(14,4,'Recommended','Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),(14,5,'Recommended','Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),(14,7,'Recommended','Mainly for aid workers or travellers to areas with active outbreaks.'),(15,2,'Recommended','Spread through contaminated food and water, especially if you eat street food or stay with locals.'),(15,3,'Recommended','Spread through food and water. Advised for almost every destination outside Europe and North America.'),(15,6,'Required','Proof of vaccination is required for Hajj and Umrah visas.'),(15,8,'Recommended','Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),(15,17,'Recommended','Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),(16,3,'Recommended','Spread through food and water. Advised for almost every destination outside Europe and North America.'),(16,16,'Recommended','Keeps tetanus and diphtheria cover up to date (every 10 years).'),(17,2,'Recommended','Spread through contaminated food and water, especially if you eat street food or stay with locals.'),(17,3,'Recommended','Spread through food and water. Advised for almost every destination outside Europe and North America.'),(17,4,'Recommended','Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),(17,16,'Recommended','Keeps tetanus and diphtheria cover up to date (every 10 years).'),(18,3,'Recommended','Spread through food and water. Advised for almost every destination outside Europe and North America.'),(18,14,'Recommended','Measles outbreaks happen worldwide. Make sure you have had two doses.'),(18,17,'Recommended','Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),(19,1,'Recommended','Mosquito-borne and present in this region. One dose gives lifelong protection.'),(19,2,'Recommended','Spread through contaminated food and water, especially if you eat street food or stay with locals.'),(19,3,'Recommended','Spread through food and water. Advised for almost every destination outside Europe and North America.'),(19,4,'Recommended','Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),(19,6,'Recommended','Advised for the African meningitis belt, especially during the dry season.'),(19,8,'Recommended','Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),(20,2,'Recommended','Spread through contaminated food and water, especially if you eat street food or stay with locals.'),(20,3,'Recommended','Spread through food and water. Advised for almost every destination outside Europe and North America.'),(20,4,'Recommended','Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),(20,5,'Recommended','Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),(20,16,'Recommended','Keeps tetanus and diphtheria cover up to date (every 10 years).'),(21,1,'Required','A yellow fever certificate is required to enter. One dose gives lifelong protection.'),(21,2,'Recommended','Spread through contaminated food and water, especially if you eat street food or stay with locals.'),(21,3,'Recommended','Spread through food and water. Advised for almost every destination outside Europe and North America.'),(21,4,'Recommended','Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),(21,6,'Recommended','Advised for the African meningitis belt, especially during the dry season.'),(21,8,'Recommended','Advised if you have not had a booster as an adult and are visiting a region where polio is still reported.'),(22,14,'Recommended','Measles outbreaks happen worldwide. Make sure you have had two doses.'),(22,16,'Recommended','Keeps tetanus and diphtheria cover up to date (every 10 years).'),(22,17,'Recommended','Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),(23,14,'Recommended','Measles outbreaks happen worldwide. Make sure you have had two doses.'),(23,16,'Recommended','Keeps tetanus and diphtheria cover up to date (every 10 years).'),(23,17,'Recommended','Flu circulates all year in the tropics and in winter elsewhere. Useful before long flights.'),(24,2,'Recommended','Spread through contaminated food and water, especially if you eat street food or stay with locals.'),(24,3,'Recommended','Spread through food and water. Advised for almost every destination outside Europe and North America.'),(24,4,'Recommended','Worth considering if you will be around dogs, bats or monkeys, or far from medical care.'),(24,5,'Recommended','Mosquito-borne. Advised for stays over a month or time spent in rural and farming areas.'),(24,16,'Recommended','Keeps tetanus and diphtheria cover up to date (every 10 years).');
/*!40000 ALTER TABLE `destination_vaccines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `destinations`
--

DROP TABLE IF EXISTS `destinations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `destinations` (
  `destination_id` int(11) NOT NULL AUTO_INCREMENT,
  `country_code` char(2) NOT NULL,
  `country` varchar(100) NOT NULL,
  `region` varchar(50) NOT NULL,
  PRIMARY KEY (`destination_id`),
  UNIQUE KEY `uq_country_code` (`country_code`),
  UNIQUE KEY `uq_country` (`country`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `destinations`
--

LOCK TABLES `destinations` WRITE;
/*!40000 ALTER TABLE `destinations` DISABLE KEYS */;
INSERT INTO `destinations` VALUES (1,'AU','Australia','Oceania'),(2,'BR','Brazil','South America'),(3,'KH','Cambodia','Asia'),(4,'CN','China','Asia'),(5,'EG','Egypt','Middle East'),(6,'GH','Ghana','Africa'),(7,'IN','India','Asia'),(8,'ID','Indonesia','Asia'),(9,'JP','Japan','Asia'),(10,'KE','Kenya','Africa'),(11,'NP','Nepal','Asia'),(12,'NG','Nigeria','Africa'),(13,'PE','Peru','South America'),(14,'PH','Philippines','Asia'),(15,'SA','Saudi Arabia','Middle East'),(16,'SG','Singapore','Asia'),(17,'ZA','South Africa','Africa'),(18,'KR','South Korea','Asia'),(19,'TZ','Tanzania','Africa'),(20,'TH','Thailand','Asia'),(21,'UG','Uganda','Africa'),(22,'GB','United Kingdom','Europe'),(23,'US','United States','North America'),(24,'VN','Vietnam','Asia');
/*!40000 ALTER TABLE `destinations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctor_availability`
--

DROP TABLE IF EXISTS `doctor_availability`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `doctor_availability` (
  `doctor_id` int(11) NOT NULL,
  `weekday` tinyint(3) unsigned NOT NULL COMMENT '1 = Monday ... 5 = Friday',
  PRIMARY KEY (`doctor_id`,`weekday`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctor_availability`
--

LOCK TABLES `doctor_availability` WRITE;
/*!40000 ALTER TABLE `doctor_availability` DISABLE KEYS */;
INSERT INTO `doctor_availability` VALUES (0,1),(0,2),(0,3),(0,4),(0,5);
/*!40000 ALTER TABLE `doctor_availability` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctor_notification_cursors`
--

DROP TABLE IF EXISTS `doctor_notification_cursors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `doctor_notification_cursors` (
  `doctor_id` int(11) NOT NULL,
  `last_seen_at` datetime DEFAULT NULL,
  PRIMARY KEY (`doctor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctor_notification_cursors`
--

LOCK TABLES `doctor_notification_cursors` WRITE;
/*!40000 ALTER TABLE `doctor_notification_cursors` DISABLE KEYS */;
INSERT INTO `doctor_notification_cursors` VALUES (1,'2026-10-31 14:49:27');
/*!40000 ALTER TABLE `doctor_notification_cursors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctor_patient_links`
--

DROP TABLE IF EXISTS `doctor_patient_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `doctor_patient_links` (
  `doctor_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`doctor_id`,`patient_id`),
  KEY `idx_doctor_patient_links_patient` (`patient_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctor_patient_links`
--

LOCK TABLES `doctor_patient_links` WRITE;
/*!40000 ALTER TABLE `doctor_patient_links` DISABLE KEYS */;
/*!40000 ALTER TABLE `doctor_patient_links` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctors`
--

DROP TABLE IF EXISTS `doctors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
  `years_experience` tinyint(3) unsigned DEFAULT NULL,
  `languages` varchar(150) DEFAULT NULL,
  `keywords` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctors`
--

LOCK TABLES `doctors` WRITE;
/*!40000 ALTER TABLE `doctors` DISABLE KEYS */;
INSERT INTO `doctors` VALUES (1,'Alex','Taylor','try1@gmail.com','0129998888','1985-05-12','$2y$10$Wbao0n/7NbEDtp2HJOEhie3ch63L8C4Gr/.THsbiZkmzmE3nOwmdm','Cardiology & Orthopedic Medicine','Room 304','2026-10-18 06:58:13',NULL,NULL,'',NULL,'',''),(0,'Aisha','Rahman','aisha.rahman@vaxassist.demo','+60 3-0000 1000','1985-01-01','!','Travel Medicine','Room 101','2026-10-24 15:48:38',NULL,NULL,NULL,NULL,NULL,NULL),(0,'Daniel','Lim','daniel.lim@vaxassist.demo','+60 3-0000 1001','1985-01-01','!','Paediatrics','Room 102','2026-10-24 15:48:38',NULL,NULL,NULL,NULL,NULL,NULL),(0,'Priya','Nair','priya.nair@vaxassist.demo','+60 3-0000 1002','1985-01-01','!','General Practice','Room 103','2026-10-24 15:48:38',NULL,NULL,NULL,NULL,NULL,NULL),(0,'Ahmad','Farid','ahmad.farid@vaxassist.demo','+60 3-0000 1003','1985-01-01','!','Internal Medicine','Room 104','2026-10-24 15:48:38',NULL,NULL,NULL,NULL,NULL,NULL),(0,'Mei','Ling Tan','mei.ling.tan@vaxassist.demo','+60 3-0000 1004','1985-01-01','!','Infectious Diseases','Room 105','2026-10-24 15:48:38',NULL,NULL,NULL,NULL,NULL,NULL),(0,'Rajesh','Kumar','rajesh.kumar@vaxassist.demo','+60 3-0000 1005','1985-01-01','!','Preventive Medicine','Room 106','2026-10-24 15:48:38',NULL,NULL,NULL,NULL,NULL,NULL),(0,'Siti','Aminah','siti.aminah@vaxassist.demo','+60 3-0000 1006','1985-01-01','!','Paediatrics','Room 107','2026-10-24 15:48:38',NULL,NULL,NULL,NULL,NULL,NULL),(0,'Jason','Wong','jason.wong@vaxassist.demo','+60 3-0000 1007','1985-01-01','!','General Practice','Room 108','2026-10-24 15:48:38',NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `doctors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_requests`
--

DROP TABLE IF EXISTS `leave_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `leave_requests` (
  `leave_id` int(11) NOT NULL,
  `doctor_id` int(11) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `reason` text NOT NULL,
  `status` enum('Pending','Approved','Rejected') DEFAULT 'Pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_requests`
--

LOCK TABLES `leave_requests` WRITE;
/*!40000 ALTER TABLE `leave_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `leave_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `messages` (
  `message_id` int(11) NOT NULL,
  `doctor_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `sender_type` enum('doctor','patient') NOT NULL,
  `message_text` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
INSERT INTO `messages` VALUES (1,1,2,'patient','Hello Dr. Alex, I received my flu vaccine yesterday. My arm feels slightly warm and sore. Is this normal?',1,'2026-10-18 06:58:13'),(2,1,2,'doctor','Hi Sarah, yes, mild soreness and warmth at the injection site are common post-vaccine reactions.',1,'2026-10-18 06:58:13'),(3,1,2,'doctor','test 1',0,'2026-10-18 07:48:43'),(0,0,0,'patient','Hi Dr. Rahman, I\'m travelling to Ghana next month. Besides yellow fever, is there anything else I should have?',1,'2026-10-22 15:28:38'),(0,0,0,'doctor','Hello! Typhoid and hepatitis A are both advised for Ghana, and we should talk about malaria tablets. Bring your itinerary to your appointment and we will go through it.',1,'2026-10-22 15:48:38'),(0,0,0,'patient','Thank you, I will bring it along.',1,'2026-10-22 15:58:38'),(0,0,0,'doctor','Hi, this is a reminder that Aiden\'s MMR appointment is coming up. Please let us know if he has a fever on the day.',0,'2026-10-24 15:13:38'),(0,0,1,'patient','Is it fine to have my flu shot if I have a mild cold?',1,'2026-10-24 05:48:38'),(0,0,1,'doctor','A mild cold is usually fine, but if you have a fever we should move it. Please complete the pre-consultation form so I can check.',0,'2026-10-24 08:48:38');
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_preferences`
--

DROP TABLE IF EXISTS `notification_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notification_preferences` (
  `patient_id` int(11) NOT NULL,
  `email_reminders` tinyint(1) NOT NULL DEFAULT 1,
  `sms_reminders` tinyint(1) NOT NULL DEFAULT 1,
  `booster_alerts` tinyint(1) NOT NULL DEFAULT 1,
  `clinic_news` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`patient_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_preferences`
--

LOCK TABLES `notification_preferences` WRITE;
/*!40000 ALTER TABLE `notification_preferences` DISABLE KEYS */;
INSERT INTO `notification_preferences` VALUES (0,1,1,1,1),(1,1,1,1,1),(2,1,1,1,1),(3,1,1,1,1);
/*!40000 ALTER TABLE `notification_preferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifications` (
  `notification_id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_id` int(11) NOT NULL,
  `doctor_id` int(11) DEFAULT NULL,
  `appointment_id` int(11) DEFAULT NULL,
  `type` enum('Appointment','Reminder','Booster','Late','Announcement') NOT NULL,
  `title` varchar(150) NOT NULL,
  `body` text DEFAULT NULL,
  `action_url` varchar(200) DEFAULT NULL,
  `action_label` varchar(50) DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`notification_id`),
  KEY `idx_notif_patient_read` (`patient_id`,`is_read`),
  KEY `idx_notif_doctor_unread` (`doctor_id`,`is_read`),
  KEY `idx_notif_appointment` (`appointment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,0,NULL,NULL,'Late','Doctor running late','Dr. Aisha Rahman is running about 15 minutes behind. Your Yellow Fever appointment is still on, with a slightly later start.','appointments.html','View appointment',0,'2026-10-24 15:36:39'),(2,0,NULL,NULL,'Reminder','Appointment tomorrow','Reminder: Yellow Fever vaccine with Dr. Aisha Rahman at 10:00 AM. Please bring your ID and travel details.','appointments.html','View appointment',0,'2026-10-24 12:48:39'),(3,0,NULL,NULL,'Booster','Aiden\'s pneumococcal booster is overdue','Aiden is due for his Pneumococcal (PCV) booster. Book a visit to keep his schedule on track.','booking.html?vaccine=Pneumococcal%20(PCV)','Book now',0,'2026-10-23 19:48:39'),(4,0,NULL,NULL,'Appointment','Booking confirmed','Your MMR appointment for Aiden with Dr. Daniel Lim has been confirmed.','appointments.html','View appointment',1,'2026-10-23 11:48:39'),(5,0,NULL,NULL,'Booster','Hepatitis A second dose coming up','Your second Hepatitis A dose is due in about 40 days. You can book a slot any time before then.','vaccinations.html','See my records',0,'2026-10-21 15:48:39'),(6,0,NULL,NULL,'Announcement','Discounted flu booster slots','Selected influenza booster slots this month are available at a reduced price while stocks last.','booking.html?vaccine=Influenza','Book a slot',1,'2026-10-19 15:48:39'),(7,0,NULL,NULL,'Appointment','Appointment rescheduled','Your Typhoid appointment was moved to a new time at your request.','appointments.html?tab=history','View history',1,'2026-10-08 15:48:39'),(8,0,NULL,NULL,'Announcement','Welcome to VaxAssist','Thanks for joining. Complete your health profile so your doctor has what they need before each vaccine.','profile.html?tab=health','Open profile',1,'2026-09-14 15:48:39'),(9,1,NULL,NULL,'Reminder','Influenza booking confirmed','Your influenza appointment with Dr. Priya Nair is booked. Please complete the pre-consultation form beforehand.','precheck.html?vaccine=Influenza','Fill in the form',0,'2026-10-24 14:18:39'),(10,1,NULL,NULL,'Booster','Noah\'s DTaP-IPV-Hib dose 2 is overdue','Noah is due for the next dose in his DTaP-IPV-Hib course. Book a visit to catch up.','booking.html?vaccine=DTaP-IPV-Hib','Book now',0,'2026-10-22 13:48:39'),(11,1,NULL,NULL,'Announcement','Welcome to VaxAssist','Thanks for joining. Complete your health profile so your doctor has what they need before each vaccine.','profile.html?tab=health','Open profile',1,'2026-09-26 21:08:39'),(12,2,NULL,NULL,'Reminder','Yellow Fever appointment booked','Your Yellow Fever appointment is booked. Bring your passport and travel details.','appointments.html','View appointment',0,'2026-10-24 14:48:39'),(13,2,NULL,NULL,'Booster','Hepatitis A second dose coming up','Your second Hepatitis A dose is due in about five months.','vaccinations.html','See my records',1,'2026-10-21 04:28:39'),(14,3,NULL,NULL,'Announcement','Welcome to VaxAssist','Thanks for joining. Complete your health profile so your doctor has what they need before each vaccine.','profile.html?tab=health','Open profile',0,'2026-10-24 12:28:39'),(15,1,1,1,'Booster','Next vaccine dose recorded','Influenza dose 1 was recorded for Michael Wong. Next dose due 2026-12-01.','appointments.html','View appointment',0,'2026-11-03 02:23:16');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_resets`
--

DROP TABLE IF EXISTS `password_resets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `password_resets` (
  `reset_id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_id` int(11) NOT NULL,
  `token_hash` char(64) NOT NULL COMMENT 'SHA-256 of the emailed token; the token itself is never stored',
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`reset_id`),
  UNIQUE KEY `uq_reset_token` (`token_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_resets`
--

LOCK TABLES `password_resets` WRITE;
/*!40000 ALTER TABLE `password_resets` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_resets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patient_health_items`
--

DROP TABLE IF EXISTS `patient_health_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `patient_health_items` (
  `item_id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_id` int(11) NOT NULL,
  `item_type` enum('Allergy','Condition','Medication') NOT NULL,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`item_id`),
  UNIQUE KEY `uq_health_item` (`patient_id`,`item_type`,`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patient_health_items`
--

LOCK TABLES `patient_health_items` WRITE;
/*!40000 ALTER TABLE `patient_health_items` DISABLE KEYS */;
INSERT INTO `patient_health_items` VALUES (2,0,'Allergy','Egg'),(1,0,'Allergy','Penicillin'),(3,0,'Condition','Asthma'),(4,0,'Medication','Salbutamol inhaler'),(5,1,'Allergy','Latex'),(6,2,'Condition','Hay fever');
/*!40000 ALTER TABLE `patient_health_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patients`
--

DROP TABLE IF EXISTS `patients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `patients` (
  `patient_id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `ic_passport` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `gender` enum('Male','Female','Other') NOT NULL DEFAULT 'Male',
  `blood_type` varchar(5) DEFAULT 'O+',
  `allergies` text DEFAULT 'Penicillin',
  `address` text DEFAULT NULL,
  `emergency_contact_name` varchar(100) DEFAULT NULL,
  `emergency_contact_phone` varchar(20) DEFAULT NULL,
  `height_cm` smallint(6) DEFAULT NULL,
  `weight_kg` decimal(5,1) DEFAULT NULL,
  `no_known_allergies` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patients`
--

LOCK TABLES `patients` WRITE;
/*!40000 ALTER TABLE `patients` DISABLE KEYS */;
INSERT INTO `patients` VALUES (1,'Michael Wong','800820-07-5531','michael@example.com','$2y$10$kYVmuR.B4vEXGw6L6i8CGuN0TzuT9zmWe2YpWYo8SrPLdecU6Uswm','0191112222','1980-08-20','Male','O+','Penicillin',NULL,NULL,NULL,NULL,NULL,0,'2026-10-18 06:58:13'),(2,'Sarah Jenkins','920315-08-6622','sarah@example.com','$2y$10$6vGcJSEjmZ6ObZ60i3UHNe7Z/NOHebH50mKDTXE1v1YpMV/HO1Jb2','0183334444','1992-03-15','Female','A+','None',NULL,NULL,NULL,NULL,NULL,0,'2026-10-18 06:58:13'),(3,'Ahmad Razak','881105-10-7711','ahmad@example.com','$2y$10$oDqglPVErvmxxp6R2b4wJOQLbsS2de9SMSifjAwb2wXVhEaPTfr32','0175556666','1988-11-05','Male','B+','Aspirin',NULL,NULL,NULL,NULL,NULL,0,'2026-10-18 06:58:13'),(0,'Demo Patient',NULL,'demo@example.com','$2y$10$nVyjH6mh7qwLVmsX1rVc4eibjDKCNBMCeyiiW48s0Lx.Aw8iOMGyi','+60 12-345 6789','1998-05-14','Female','O+',NULL,NULL,NULL,NULL,165,58.0,0,'2026-10-24 15:48:38');
/*!40000 ALTER TABLE `patients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_items`
--

DROP TABLE IF EXISTS `payment_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_items` (
  `item_id` int(11) NOT NULL AUTO_INCREMENT,
  `payment_id` int(11) NOT NULL,
  `label` varchar(150) NOT NULL,
  `amount` decimal(8,2) NOT NULL,
  PRIMARY KEY (`item_id`),
  KEY `idx_item_payment` (`payment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_items`
--

LOCK TABLES `payment_items` WRITE;
/*!40000 ALTER TABLE `payment_items` DISABLE KEYS */;
INSERT INTO `payment_items` VALUES (1,1,'Typhoid vaccine',95.00),(2,1,'Consultation fee',40.00),(3,2,'Hepatitis A vaccine (dose 1)',120.00),(4,2,'Consultation fee',40.00),(5,3,'DTaP-IPV-Hib (dose 3)',180.00),(6,3,'Consultation fee',40.00),(7,4,'Influenza vaccine',70.00),(8,4,'Consultation fee',40.00),(9,5,'Yellow Fever vaccine',130.00),(10,5,'Consultation fee',40.00),(11,6,'Influenza vaccine',70.00),(12,6,'Consultation fee',40.00),(13,7,'Booking deposit (refunded)',20.00),(14,8,'Influenza vaccine',70.00),(15,8,'Consultation fee',40.00),(16,9,'Yellow Fever vaccine',130.00),(17,9,'Consultation fee',40.00);
/*!40000 ALTER TABLE `payment_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payments` (
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
  KEY `idx_pay_patient_status` (`patient_id`,`status`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,0,0,'VA-2026-0001','Paid','Credit card',0.00,'2026-10-12 00:00:00','2026-10-12 10:00:00'),(2,0,0,'VA-2026-0002','Paid','Insurance + e-wallet',100.00,'2026-09-13 00:00:00','2026-09-13 10:00:00'),(3,0,0,'VA-2026-0003','Paid','E-wallet',0.00,'2026-09-24 00:00:00','2026-09-24 10:00:00'),(4,0,0,'VA-2026-0004','Paid','Credit card',0.00,'2026-03-28 00:00:00','2026-03-28 10:00:00'),(5,0,0,'VA-2026-0005','Pending',NULL,0.00,'2026-10-24 15:48:38',NULL),(6,0,0,'VA-2026-0006','Pending',NULL,0.00,'2026-10-24 15:48:38',NULL),(7,0,0,'VA-2026-0007','Refunded','Credit card',0.00,'2026-10-06 00:00:00','2026-10-06 10:00:00'),(8,1,0,'VA-2026-0008','Pending',NULL,0.00,'2026-10-24 15:48:38',NULL),(9,2,0,'VA-2026-0009','Paid','Online banking',0.00,'2026-10-23 00:00:00','2026-10-23 10:00:00');
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `precheck_forms`
--

DROP TABLE IF EXISTS `precheck_forms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `precheck_forms` (
  `form_id` int(11) NOT NULL AUTO_INCREMENT,
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
  `submitted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`form_id`),
  KEY `idx_precheck_patient` (`patient_id`),
  KEY `idx_precheck_appointment` (`appointment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `precheck_forms`
--

LOCK TABLES `precheck_forms` WRITE;
/*!40000 ALTER TABLE `precheck_forms` DISABLE KEYS */;
/*!40000 ALTER TABLE `precheck_forms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reviews` (
  `review_id` int(11) NOT NULL AUTO_INCREMENT,
  `appointment_id` int(11) NOT NULL COMMENT 'one review per visit; the doctor comes from the appointment',
  `patient_id` int(11) NOT NULL,
  `rating` tinyint(3) unsigned NOT NULL,
  `comment` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`review_id`),
  UNIQUE KEY `uq_review_appointment` (`appointment_id`),
  KEY `idx_review_patient` (`patient_id`),
  CONSTRAINT `chk_review_rating` CHECK (`rating` between 1 and 5)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vaccination_records`
--

DROP TABLE IF EXISTS `vaccination_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vaccination_records` (
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
  KEY `idx_vr_batch` (`batch_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vaccination_records`
--

LOCK TABLES `vaccination_records` WRITE;
/*!40000 ALTER TABLE `vaccination_records` DISABLE KEYS */;
INSERT INTO `vaccination_records` VALUES (1,0,NULL,2,1,0,NULL,1,'2026-10-12',NULL,'Booster needed after 3 years if still travelling.'),(2,0,NULL,3,2,0,NULL,1,'2026-09-13','2026-12-03','Second dose 6 to 12 months after the first.'),(3,0,NULL,17,3,0,NULL,1,'2026-03-28','2027-03-28',NULL),(4,0,NULL,16,4,0,NULL,1,'2023-10-20','2033-10-17','Repeat every 10 years.'),(5,0,1,9,5,0,NULL,1,'2025-08-20',NULL,NULL),(6,0,1,10,6,0,NULL,3,'2026-02-16',NULL,'Course complete.'),(7,0,1,13,7,0,NULL,2,'2025-12-23',NULL,'Course complete.'),(8,0,1,12,8,0,NULL,2,'2025-12-28','2026-10-14','Booster dose at 12 months.'),(9,0,1,11,9,0,NULL,3,'2026-09-24','2027-02-06','Booster due at 18 months.'),(10,1,2,9,12,0,NULL,1,'2024-05-27',NULL,NULL),(11,1,2,10,10,0,NULL,1,'2024-05-27',NULL,NULL),(12,1,2,10,10,0,NULL,2,'2024-06-26',NULL,NULL),(13,1,2,11,11,0,NULL,1,'2024-07-26','2024-11-23','Dose 2 was due about two months later.'),(14,2,NULL,3,13,0,NULL,1,'2026-10-04','2027-04-02','Second dose 6 months after the first.'),(15,2,NULL,2,14,0,NULL,1,'2026-10-04',NULL,NULL),(16,1,NULL,17,3,1,1,1,'2026-11-03','2026-12-01','testing');
/*!40000 ALTER TABLE `vaccination_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vaccine_batches`
--

DROP TABLE IF EXISTS `vaccine_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vaccine_batches` (
  `batch_id` int(11) NOT NULL AUTO_INCREMENT,
  `vaccine_id` int(11) NOT NULL,
  `batch_number` varchar(50) NOT NULL,
  `manufacturer` varchar(100) DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `quantity_in_stock` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`batch_id`),
  UNIQUE KEY `uq_batch_number` (`batch_number`),
  KEY `idx_batch_expiry` (`expiry_date`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vaccine_batches`
--

LOCK TABLES `vaccine_batches` WRITE;
/*!40000 ALTER TABLE `vaccine_batches` DISABLE KEYS */;
INSERT INTO `vaccine_batches` VALUES (1,2,'TY-22914B','Demo Pharma','2028-04-24',100),(2,3,'HA-80731C','Demo Pharma','2028-04-24',100),(3,17,'FLU-5519A','Demo Pharma','2028-04-24',99),(4,16,'TD-30276D','Demo Pharma','2028-04-24',100),(5,9,'BCG-1102','Demo Pharma','2028-04-24',100),(6,10,'HB-77410','Demo Pharma','2028-04-24',100),(7,13,'RV-4408','Demo Pharma','2028-04-24',100),(8,12,'PCV-9912','Demo Pharma','2028-04-24',100),(9,11,'DTP-6063','Demo Pharma','2028-04-24',100),(10,10,'HB-5521','Demo Pharma','2028-04-24',100),(11,11,'DTP-5110','Demo Pharma','2028-04-24',100),(12,9,'BCG-0991','Demo Pharma','2028-04-24',100),(13,3,'HA-9902','Demo Pharma','2028-04-24',100),(14,2,'TY-30011','Demo Pharma','2028-04-24',100);
/*!40000 ALTER TABLE `vaccine_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vaccines`
--

DROP TABLE IF EXISTS `vaccines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vaccines` (
  `vaccine_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `category` enum('Travel','Childhood','Booster','Consultation') NOT NULL,
  `total_doses` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `price` decimal(8,2) NOT NULL DEFAULT 0.00 COMMENT 'demo price in RM',
  `lead_days` smallint(6) DEFAULT NULL COMMENT 'travel vaccines: ideal days before departure',
  PRIMARY KEY (`vaccine_id`),
  UNIQUE KEY `uq_vaccine_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vaccines`
--

LOCK TABLES `vaccines` WRITE;
/*!40000 ALTER TABLE `vaccines` DISABLE KEYS */;
INSERT INTO `vaccines` VALUES (1,'Yellow Fever','Travel',1,130.00,10),(2,'Typhoid','Travel',1,95.00,14),(3,'Hepatitis A','Travel',2,120.00,14),(4,'Rabies','Travel',3,160.00,28),(5,'Japanese Encephalitis','Travel',2,220.00,28),(6,'Meningococcal ACWY','Travel',1,210.00,10),(7,'Cholera','Travel',2,110.00,14),(8,'Polio (IPV)','Travel',1,85.00,28),(9,'BCG','Childhood',1,40.00,NULL),(10,'Hepatitis B','Childhood',3,60.00,NULL),(11,'DTaP-IPV-Hib','Childhood',4,180.00,NULL),(12,'Pneumococcal (PCV)','Childhood',4,230.00,NULL),(13,'Rotavirus','Childhood',2,150.00,NULL),(14,'MMR','Childhood',2,75.00,28),(15,'Varicella','Childhood',2,130.00,NULL),(16,'Td Booster','Booster',1,55.00,14),(17,'Influenza','Booster',1,70.00,14),(18,'Vaccine consultation','Consultation',1,40.00,NULL);
/*!40000 ALTER TABLE `vaccines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'vaxassist_db'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-03 15:41:10
