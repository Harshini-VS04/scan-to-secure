-- =====================================================================
-- SCAN TO SECURE: AI/ML-Powered Secure Academic Certificate Platform
-- MySQL Relational Database DDL Schema
-- =====================================================================

CREATE DATABASE IF NOT EXISTS `scantosecure` 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE `scantosecure`;

-- 1. Users Table
CREATE TABLE IF NOT EXISTS `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `email` VARCHAR(255) NOT NULL UNIQUE,
    `password_hash` VARCHAR(255) NOT NULL,
    `full_name` VARCHAR(255) NOT NULL,
    `role` ENUM('student', 'professor', 'admin') NOT NULL DEFAULT 'student',
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_users_email` (`email`),
    INDEX `idx_users_role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Departments Table
CREATE TABLE IF NOT EXISTS `departments` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(150) NOT NULL UNIQUE,
    `code` VARCHAR(20) NOT NULL UNIQUE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_dept_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Professors Table
CREATE TABLE IF NOT EXISTS `professors` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL UNIQUE,
    `employee_id` VARCHAR(100) NOT NULL UNIQUE,
    `department_id` INT NULL,
    `designation` VARCHAR(100) NOT NULL DEFAULT 'Assistant Professor',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_professors_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_professors_dept` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
    INDEX `idx_professors_employee_id` (`employee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Classes Table (Class Folders)
CREATE TABLE IF NOT EXISTS `classes` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(150) NOT NULL,
    `department_id` INT NOT NULL,
    `professor_id` INT NULL,
    `academic_year` VARCHAR(20) NOT NULL DEFAULT '2024-2025',
    `semester` INT NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_classes_dept` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_classes_prof` FOREIGN KEY (`professor_id`) REFERENCES `professors` (`id`) ON DELETE SET NULL,
    INDEX `idx_classes_professor_id` (`professor_id`),
    INDEX `idx_classes_department_id` (`department_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Students Table
CREATE TABLE IF NOT EXISTS `students` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL UNIQUE,
    `roll_number` VARCHAR(100) NOT NULL UNIQUE,
    `department_id` INT NULL,
    `class_id` INT NULL,
    `year_of_study` INT NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_students_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_students_dept` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_students_class` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE SET NULL,
    INDEX `idx_students_roll_number` (`roll_number`),
    INDEX `idx_students_class_id` (`class_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Certificates Table
CREATE TABLE IF NOT EXISTS `certificates` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `certificate_id` VARCHAR(64) NOT NULL UNIQUE,
    `student_id` INT NOT NULL,
    `class_id` INT NULL,
    `title` VARCHAR(255) NOT NULL,
    `certificate_type` VARCHAR(100) NOT NULL DEFAULT 'Other',
    `issuing_organization` VARCHAR(255) NULL,
    `student_name` VARCHAR(255) NULL,
    `issue_date` VARCHAR(100) NULL,
    `file_name` VARCHAR(255) NOT NULL,
    `file_path` VARCHAR(500) NOT NULL,
    `file_hash` VARCHAR(64) NOT NULL,
    `file_size` INT NOT NULL,
    `mime_type` VARCHAR(100) NOT NULL,
    `verification_status` ENUM('pending', 'verified', 'rejected') NOT NULL DEFAULT 'pending',
    `rejection_reason` VARCHAR(500) NULL,
    `verified_by_id` INT NULL,
    `verified_at` DATETIME NULL,
    `upload_timestamp` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `is_deleted` BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT `fk_certs_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_certs_class` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_certs_verifier` FOREIGN KEY (`verified_by_id`) REFERENCES `professors` (`id`) ON DELETE SET NULL,
    INDEX `idx_certs_cert_id` (`certificate_id`),
    INDEX `idx_certs_hash` (`file_hash`),
    INDEX `idx_certs_status` (`verification_status`),
    INDEX `idx_certs_student` (`student_id`),
    INDEX `idx_certs_deleted` (`is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. Certificate Metadata (AI / OCR Extracted details)
CREATE TABLE IF NOT EXISTS `certificate_metadata` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `certificate_id` INT NOT NULL UNIQUE,
    `extracted_text` LONGTEXT NULL,
    `ocr_confidence` FLOAT NOT NULL DEFAULT 0.0,
    `classification_confidence` FLOAT NOT NULL DEFAULT 0.0,
    `ocr_engine` VARCHAR(50) NOT NULL DEFAULT 'OpenCV+Tesseract',
    `extracted_fields_json` JSON NULL,
    `similarity_score` FLOAT NOT NULL DEFAULT 0.0,
    `duplicate_of_id` INT NULL,
    `is_duplicate_flag` BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT `fk_meta_cert` FOREIGN KEY (`certificate_id`) REFERENCES `certificates` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_meta_dup_cert` FOREIGN KEY (`duplicate_of_id`) REFERENCES `certificates` (`id`) ON DELETE SET NULL,
    INDEX `idx_meta_cert` (`certificate_id`),
    INDEX `idx_meta_dup` (`duplicate_of_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Activity / Security Audit Logs
CREATE TABLE IF NOT EXISTS `activity_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NULL,
    `action` VARCHAR(100) NOT NULL,
    `resource_type` VARCHAR(100) NULL,
    `resource_id` VARCHAR(100) NULL,
    `ip_address` VARCHAR(100) NULL,
    `user_agent` VARCHAR(255) NULL,
    `details_json` JSON NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_audit_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
    INDEX `idx_audit_user` (`user_id`),
    INDEX `idx_audit_action` (`action`),
    INDEX `idx_audit_time` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. Refresh Tokens / Sessions Table
CREATE TABLE IF NOT EXISTS `refresh_tokens` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `token_hash` VARCHAR(255) NOT NULL UNIQUE,
    `expires_at` DATETIME NOT NULL,
    `revoked` BOOLEAN NOT NULL DEFAULT FALSE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_tokens_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    INDEX `idx_tokens_user` (`user_id`),
    INDEX `idx_tokens_hash` (`token_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
