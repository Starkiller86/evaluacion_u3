-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 29, 2025 at 09:28 PM
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
-- Database: `paquexpress_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `deliveries`
--

CREATE TABLE `deliveries` (
  `id` int(11) NOT NULL,
  `destination_address` varchar(255) NOT NULL,
  `recipient` varchar(255) DEFAULT NULL,
  `assigned_to` int(11) DEFAULT NULL,
  `delivered` tinyint(1) DEFAULT 0,
  `delivered_at` datetime DEFAULT NULL,
  `lat` double DEFAULT NULL,
  `lon` double DEFAULT NULL,
  `photo_path` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `deliveries`
--

INSERT INTO `deliveries` (`id`, `destination_address`, `recipient`, `assigned_to`, `delivered`, `delivered_at`, `lat`, `lon`, `photo_path`, `notes`) VALUES
(1, 'Av. Reforma 123, CDMX', 'Juan Perez', 1, 1, '2025-11-29 19:15:10', 20.5402666, -100.45066, 'uploads\\20251129191510_scaled_112979f5-5eb2-4e4f-abb5-f3f557bf417d5738028373671265402.jpg', 'Entregada en recepción'),
(2, 'Ramos Millan 29, CDMX', 'Jose Harfuch', 1, 0, NULL, NULL, NULL, NULL, NULL),
(3, 'Av. Paseo de la pir?mide del pueblito 491 int 31, Corregidora, Qro.', 'Erika Salinas', 1, 0, NULL, NULL, NULL, NULL, NULL),
(4, 'Paseo de la piramide del pueblito 491, Corregidora, Qro.', 'Erika Salinas', 1, 1, '2025-11-29 19:54:52', 20.540513, -100.4506779, 'uploads\\20251129195452_scaled_8dc3595f-4c0f-4dae-9343-0e562f1672ff8695749321723069836.jpg', 'Entregado a un residente');

-- --------------------------------------------------------

--
-- Table structure for table `photos`
--

CREATE TABLE `photos` (
  `id` int(11) NOT NULL,
  `delivery_id` int(11) DEFAULT NULL,
  `path` varchar(255) DEFAULT NULL,
  `uploaded_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `photos`
--

INSERT INTO `photos` (`id`, `delivery_id`, `path`, `uploaded_at`) VALUES
(1, 1, 'uploads\\20251129181008_scaled_c009f1e4-53fb-4573-9bc4-7c726032d7c93477250456940458024.jpg', '2025-11-29 18:10:08'),
(2, 1, 'uploads\\20251129181016_scaled_c009f1e4-53fb-4573-9bc4-7c726032d7c93477250456940458024.jpg', '2025-11-29 18:10:16'),
(3, 1, 'uploads\\20251129181837_scaled_11d18ad7-0024-4b51-aedd-7253775a1d775985890354021883003.jpg', '2025-11-29 18:18:37'),
(4, 1, 'uploads\\20251129191510_scaled_112979f5-5eb2-4e4f-abb5-f3f557bf417d5738028373671265402.jpg', '2025-11-29 19:15:10'),
(5, 4, 'uploads\\20251129194333_scaled_10d417cb-8c18-42f0-97a3-65a1c9b9d2d1129540251047697963.jpg', '2025-11-29 19:43:33'),
(6, 4, 'uploads\\20251129195452_scaled_8dc3595f-4c0f-4dae-9343-0e562f1672ff8695749321723069836.jpg', '2025-11-29 19:54:52');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(80) NOT NULL,
  `hashed_password` varchar(255) NOT NULL,
  `full_name` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `hashed_password`, `full_name`, `created_at`) VALUES
(1, 'agente1', '$2b$12$aAenqIwb4Yqc1FQnNLgnJ.CBUwDVyOrJ5A8CYErJkQsmMcHQ.1UAq', 'Agente Uno', '2025-11-29 17:54:19');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `deliveries`
--
ALTER TABLE `deliveries`
  ADD PRIMARY KEY (`id`),
  ADD KEY `assigned_to` (`assigned_to`);

--
-- Indexes for table `photos`
--
ALTER TABLE `photos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `delivery_id` (`delivery_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `deliveries`
--
ALTER TABLE `deliveries`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `photos`
--
ALTER TABLE `photos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `deliveries`
--
ALTER TABLE `deliveries`
  ADD CONSTRAINT `deliveries_ibfk_1` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `photos`
--
ALTER TABLE `photos`
  ADD CONSTRAINT `photos_ibfk_1` FOREIGN KEY (`delivery_id`) REFERENCES `deliveries` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
