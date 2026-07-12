-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Server version: 10.4.11-MariaDB
-- PHP Version: 7.2.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;


CREATE TABLE `doctors` (
  `did` int(11) NOT NULL,
  `email` varchar(50) NOT NULL,
  `doctorname` varchar(50) NOT NULL,
  `dept` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


INSERT INTO `doctors` (`did`, `email`, `doctorname`, `dept`) VALUES
(1, 'anees@gmail.com', 'anees', 'Cardiologists'),
(2, 'amrutha@gmail.com', 'amrutha bhatta', 'Dermatologists'),
(3, 'aadithyaa@gmail.com', 'aadithyaa', 'Anesthesiologists'),
(5, 'aneeqah@gmail.com', 'aneekha', 'corona');


CREATE TABLE `patients` (
  `pid` int(11) NOT NULL,
  `email` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `gender` varchar(50) NOT NULL,
  `slot` varchar(50) NOT NULL,
  `disease` varchar(50) NOT NULL,
  `time` time NOT NULL,
  `date` date NOT NULL,
  `dept` varchar(50) NOT NULL,
  `number` varchar(12) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `patients` (`pid`, `email`, `name`, `gender`, `slot`, `disease`, `time`, `date`, `dept`, `number`) VALUES
(2, 'anees1@gmail.com', 'anees1 rehman khan', 'Male1', 'evening1', 'cold1', '21:20:00', '2020-02-02', 'ortho11predict', '9874561110'),
(5, 'patient@gmail.com', 'patien', 'Male', 'morning', 'fevr', '18:06:00', '2020-11-18', 'Cardiologists', '9874563210'),
(7, 'patient@gmail.com', 'anees', 'Male', 'evening', 'cold', '22:18:00', '2020-11-05', 'Dermatologists', '9874563210'),
(8, 'patient@gmail.com', 'anees', 'Male', 'evening', 'cold', '22:18:00', '2020-11-05', 'Dermatologists', '9874563210'),
(9, 'aneesurrehman423@gmail.com', 'anees', 'Male', 'morning', 'cold', '17:27:00', '2020-11-26', 'Anesthesiologists', '9874563210'),
(10, 'anees@gmail.com', 'anees', 'Male', 'evening', 'fever', '16:25:00', '2020-12-09', 'Cardiologists', '9874589654'),
(15, 'khushi@gmail.com', 'khushi', 'Female', 'morning', 'corona', '20:42:00', '2021-01-23', 'Anesthesiologists', '9874563210'),
(16, 'khushi@gmail.com', 'khushi', 'Female', 'evening', 'fever', '15:46:00', '2021-01-31', 'Endocrinologists', '9874587496'),
(17, 'aneeqah@gmail.com', 'aneeqah', 'Female', 'evening', 'fever', '15:48:00', '2021-01-23', 'Endocrinologists', '9874563210');

DELIMITER $$
CREATE TRIGGER `BeforePatientInsert` BEFORE INSERT ON `patients` FOR EACH ROW
BEGIN
  DECLARE booking_count INT;
  DECLARE dept_exists INT;
  
  IF NEW.date < CURRENT_DATE() THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Appointment date cannot be in the past!';
  END IF;
  
  IF LENGTH(NEW.number) <> 10 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Phone number must be exactly 10 digits!';
  END IF;

  IF NEW.email NOT LIKE '%_@__%.__%' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid email address format!';
  END IF;
  
  SELECT COUNT(*) INTO dept_exists FROM `doctors` WHERE `dept` = NEW.dept;
  IF dept_exists = 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'No doctors are available for the selected department!';
  END IF;
  
  SELECT COUNT(*) INTO booking_count 
  FROM `patients` 
  WHERE `dept` = NEW.dept AND `date` = NEW.date AND `slot` = NEW.slot;
  
  IF booking_count >= 5 THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'This slot is fully booked for the selected department!';
  END IF;
END
$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER `BeforePatientUpdate` BEFORE UPDATE ON `patients` FOR EACH ROW
BEGIN
  DECLARE booking_count INT;
  DECLARE dept_exists INT;
  
  IF NEW.date < CURRENT_DATE() THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Appointment date cannot be in the past!';
  END IF;
  
  IF LENGTH(NEW.number) <> 10 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Phone number must be exactly 10 digits!';
  END IF;

  IF NEW.email NOT LIKE '%_@__%.__%' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid email address format!';
  END IF;
  
  SELECT COUNT(*) INTO dept_exists FROM `doctors` WHERE `dept` = NEW.dept;
  IF dept_exists = 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'No doctors are available for the selected department!';
  END IF;
  
  IF (NEW.dept <> OLD.dept OR NEW.date <> OLD.date OR NEW.slot <> OLD.slot) THEN
    SELECT COUNT(*) INTO booking_count 
    FROM `patients` 
    WHERE `dept` = NEW.dept AND `date` = NEW.date AND `slot` = NEW.slot;
    
    IF booking_count >= 5 THEN
      SIGNAL SQLSTATE '45000' 
      SET MESSAGE_TEXT = 'This slot is fully booked for the selected department!';
    END IF;
  END IF;
END
$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER `PatientDelete` BEFORE DELETE ON `patients` FOR EACH ROW 
BEGIN
  INSERT INTO trigr VALUES(null,OLD.pid,OLD.email,OLD.name,'PATIENT DELETED',NOW());
END
$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER `PatientUpdate` AFTER UPDATE ON `patients` FOR EACH ROW 
BEGIN
  INSERT INTO trigr VALUES(null,NEW.pid,NEW.email,NEW.name,'PATIENT UPDATED',NOW());
END
$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER `patientinsertion` AFTER INSERT ON `patients` FOR EACH ROW 
BEGIN
  INSERT INTO trigr VALUES(null,NEW.pid,NEW.email,NEW.name,'PATIENT INSERTED',NOW());
  
  INSERT INTO billing (pid, email, name, amount, status, timestamp)
  VALUES (NEW.pid, NEW.email, NEW.name, 100.00, 'Pending', NOW());
END
$$
DELIMITER ;



CREATE TABLE `test` (
  `id` int(11) NOT NULL,
  `name` varchar(20) NOT NULL,
  `email` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


INSERT INTO `test` (`id`, `name`, `email`) VALUES
(1, 'ANEES', 'ARK@GMAIL.COM'),
(2, 'test', 'test@gmail.com');



CREATE TABLE `trigr` (
  `tid` int(11) NOT NULL,
  `pid` int(11) NOT NULL,
  `email` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `action` varchar(50) NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


INSERT INTO `trigr` (`tid`, `pid`, `email`, `name`, `action`, `timestamp`) VALUES
(1, 12, 'anees@gmail.com', 'ANEES', 'PATIENT INSERTED', '2020-12-02 16:35:10'),
(2, 11, 'anees@gmail.com', 'anees', 'PATIENT INSERTED', '2020-12-02 16:37:34'),
(3, 10, 'anees@gmail.com', 'anees', 'PATIENT UPDATED', '2020-12-02 16:38:27'),
(4, 11, 'anees@gmail.com', 'anees', 'PATIENT UPDATED', '2020-12-02 16:38:33'),
(5, 12, 'anees@gmail.com', 'ANEES', 'Patient Deleted', '2020-12-02 16:40:40'),
(6, 11, 'anees@gmail.com', 'anees', 'PATIENT DELETED', '2020-12-02 16:41:10'),
(7, 13, 'testing@gmail.com', 'testing', 'PATIENT INSERTED', '2020-12-02 16:50:21'),
(8, 13, 'testing@gmail.com', 'testing', 'PATIENT UPDATED', '2020-12-02 16:50:32'),
(9, 13, 'testing@gmail.com', 'testing', 'PATIENT DELETED', '2020-12-02 16:50:57'),
(10, 14, 'aneeqah@gmail.com', 'aneeqah', 'PATIENT INSERTED', '2021-01-22 15:18:09'),
(11, 14, 'aneeqah@gmail.com', 'aneeqah', 'PATIENT UPDATED', '2021-01-22 15:18:29'),
(12, 14, 'aneeqah@gmail.com', 'aneeqah', 'PATIENT DELETED', '2021-01-22 15:41:48'),
(13, 15, 'khushi@gmail.com', 'khushi', 'PATIENT INSERTED', '2021-01-22 15:43:02'),
(14, 15, 'khushi@gmail.com', 'khushi', 'PATIENT UPDATED', '2021-01-22 15:43:11'),
(15, 16, 'khushi@gmail.com', 'khushi', 'PATIENT INSERTED', '2021-01-22 15:43:37'),
(16, 16, 'khushi@gmail.com', 'khushi', 'PATIENT UPDATED', '2021-01-22 15:43:49'),
(17, 17, 'aneeqah@gmail.com', 'aneeqah', 'PATIENT INSERTED', '2021-01-22 15:44:41'),
(18, 17, 'aneeqah@gmail.com', 'aneeqah', 'PATIENT UPDATED', '2021-01-22 15:44:52'),
(19, 17, 'aneeqah@gmail.com', 'aneeqah', 'PATIENT UPDATED', '2021-01-22 15:44:59');



CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `usertype` varchar(50) NOT NULL,
  `email` varchar(50) NOT NULL,
  `password` varchar(1000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


INSERT INTO `user` (`id`, `username`, `usertype`, `email`, `password`) VALUES
(13, 'anees', 'Doctor', 'anees@gmail.com', 'scrypt:32768:8:1$bdkyDRxdjd1kKWDp$6a4b67c1b2b09985e19656029304fb1500833e061cff362b79adcf6d2d2e95a5d8e2c2733dc0640cc82c343f0d3d5f49589564419f6f1ba76e9704fde8743f26'),
(14, 'aneeqah', 'Patient', 'aneeqah@gmail.com', 'scrypt:32768:8:1$bdkyDRxdjd1kKWDp$6a4b67c1b2b09985e19656029304fb1500833e061cff362b79adcf6d2d2e95a5d8e2c2733dc0640cc82c343f0d3d5f49589564419f6f1ba76e9704fde8743f26'),
(15, 'khushi', 'Patient', 'khushi@gmail.com', 'scrypt:32768:8:1$bdkyDRxdjd1kKWDp$6a4b67c1b2b09985e19656029304fb1500833e061cff362b79adcf6d2d2e95a5d8e2c2733dc0640cc82c343f0d3d5f49589564419f6f1ba76e9704fde8743f26'),
(16, 'amrutha bhatta', 'Doctor', 'amrutha@gmail.com', 'scrypt:32768:8:1$bdkyDRxdjd1kKWDp$6a4b67c1b2b09985e19656029304fb1500833e061cff362b79adcf6d2d2e95a5d8e2c2733dc0640cc82c343f0d3d5f49589564419f6f1ba76e9704fde8743f26'),
(17, 'aadithyaa', 'Doctor', 'aadithyaa@gmail.com', 'scrypt:32768:8:1$bdkyDRxdjd1kKWDp$6a4b67c1b2b09985e19656029304fb1500833e061cff362b79adcf6d2d2e95a5d8e2c2733dc0640cc82c343f0d3d5f49589564419f6f1ba76e9704fde8743f26'),
(18, 'patient', 'Patient', 'patient@gmail.com', 'scrypt:32768:8:1$bdkyDRxdjd1kKWDp$6a4b67c1b2b09985e19656029304fb1500833e061cff362b79adcf6d2d2e95a5d8e2c2733dc0640cc82c343f0d3d5f49589564419f6f1ba76e9704fde8743f26'),
(19, 'anees1 rehman khan', 'Patient', 'anees1@gmail.com', 'scrypt:32768:8:1$bdkyDRxdjd1kKWDp$6a4b67c1b2b09985e19656029304fb1500833e061cff362b79adcf6d2d2e95a5d8e2c2733dc0640cc82c343f0d3d5f49589564419f6f1ba76e9704fde8743f26'),
(20, 'aneesurrehman423', 'Patient', 'aneesurrehman423@gmail.com', 'scrypt:32768:8:1$bdkyDRxdjd1kKWDp$6a4b67c1b2b09985e19656029304fb1500833e061cff362b79adcf6d2d2e95a5d8e2c2733dc0640cc82c343f0d3d5f49589564419f6f1ba76e9704fde8743f26');


ALTER TABLE `doctors`
  ADD PRIMARY KEY (`did`);


ALTER TABLE `patients`
  ADD PRIMARY KEY (`pid`);


ALTER TABLE `test`
  ADD PRIMARY KEY (`id`);


ALTER TABLE `trigr`
  ADD PRIMARY KEY (`tid`);

ALTER TABLE `user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);


ALTER TABLE `doctors`
  MODIFY `did` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

ALTER TABLE `patients`
  MODIFY `pid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;


ALTER TABLE `test`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

ALTER TABLE `trigr`
  MODIFY `tid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;



CREATE TABLE `billing` (
  `bid` int(11) NOT NULL,
  `pid` int(11) NOT NULL,
  `email` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'Pending',
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `billing`
  ADD PRIMARY KEY (`bid`),
  ADD KEY `pid` (`pid`);

ALTER TABLE `billing`
  MODIFY `bid` int(11) NOT NULL AUTO_INCREMENT;


ALTER TABLE `doctors`
  ADD CONSTRAINT `fk_doctor_user` FOREIGN KEY (`email`) REFERENCES `user` (`email`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `patients`
  ADD CONSTRAINT `fk_patient_user` FOREIGN KEY (`email`) REFERENCES `user` (`email`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `billing`
  ADD CONSTRAINT `fk_billing_patient` FOREIGN KEY (`pid`) REFERENCES `patients` (`pid`) ON DELETE CASCADE;

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
