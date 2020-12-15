DROP TABLE IF EXISTS `@target_database@`.`user_types` CASCADE;

CREATE TABLE `@target_database@`.`user_types` ( 
	`id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`type_name` VarChar( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`created_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DateTime NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`type_key` VarChar( 100 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;

INSERT INTO `@target_database@`.`user_types`(`id`,`type_name`,`created_at`,`updated_at`,`type_key`) VALUES 
( '1', 'Project Manager', '2020-01-20 17:43:24', '2020-01-20 17:43:24', 'project_manager' ),
( '2', 'Developer', '2020-01-20 17:41:20', '2020-01-20 17:41:20', 'developer' ),
( '3', 'Client', '2020-01-20 17:40:24', '2020-01-20 17:40:24', 'client' ),
( '4', 'Admin', '2020-02-06 12:56:18', '2020-02-06 12:56:18', 'admin' );

-- DROP TABLE IF EXISTS `@target_database@`.`hour_types` CASCADE;

-- CREATE TABLE `@target_database@`.`hour_types` ( 
-- 	`id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
-- 	`name` VarChar( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
-- 	`item_order` Int( 11 ) NULL,
-- 	`updated_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
-- 	`created_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
-- 	`is_overtime` TinyInt( 4 ) NULL DEFAULT 0,
-- 	`is_active` TinyInt( 4 ) NULL DEFAULT 1,
-- 	PRIMARY KEY ( `id` ) )
-- CHARACTER SET = utf8
-- COLLATE = utf8_general_ci
-- ENGINE = InnoDB;
-- 
-- INSERT INTO `@target_database@`.`hour_types`(`id`,`name`,`item_order`,`updated_at`,`created_at`, `is_overtime`, `is_active`) VALUES 
-- ( 'cd22d93e-7915-11ea-acb8-c86000d11873', 'Overtime', '1', '2020-04-08 00:21:53', '2020-04-08 00:21:53', '1', '1' ),
-- ( 'd50383c8-7915-11ea-acb8-c86000d11873', 'Extra', '2', '2020-04-08 00:22:06', '2020-04-08 00:22:06', '1', '1' ),
-- ( 'e08edb07-7915-11ea-acb8-c86000d11873', 'Covered', '3', '2020-04-08 00:22:25', '2020-04-08 00:22:25', '0', '1' ),
-- ( 'e7f1bd4f-7915-11ea-acb8-c86000d11873', 'Fake', '4', '2020-04-08 00:22:38', '2020-04-08 00:22:38', '0', '1' );

DROP TABLE IF EXISTS `@target_database@`.`day_types` CASCADE;

CREATE TABLE `@target_database@`.`day_types` ( 
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`type` VarChar( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`title` VarChar( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`order` Int( 11 ) NULL,
	`is_active` TinyInt( 4 ) NULL DEFAULT 1,
	`updated_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`created_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`description` Text CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`is_fixed` TinyInt( 4 ) NULL DEFAULT 0,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;

INSERT INTO `@target_database@`.`day_types`(`id`,`type`,`title`,`order`,`is_active`,`updated_at`,`created_at`,`description`,`is_fixed`) VALUES 
( '1', 'ok', 'OK', '0', '1', '2020-05-20 20:30:29', '2020-04-27 20:11:30', 'OK', '1' ),
( '2', 'vacation', 'Vacation', '3', '1', '2020-05-20 20:32:21', '2020-04-27 20:11:30', '', '1' ),
( '3', 'sick', 'Sick', '1', '1', '2020-05-20 20:32:21', '2020-04-27 20:11:30', NULL, '1' ),
( '4', 'not_paid', 'Not paid', '2', '1', '2020-05-20 20:32:21', '2020-04-27 20:11:30', NULL, '0' ),
( '5', 'underloaded', 'Underloaded', '4', '1', '2020-05-20 20:30:18', '2020-04-27 20:11:30', NULL, '1' ),
( '6', 'feel_bad', 'Feel bad', '5', '1', '2020-05-20 20:30:18', '2020-04-27 20:11:30', NULL, '0' ),
( '7', 'anoter_day', 'Anoter Day', '6', '1', '2020-05-20 20:30:18', '2020-04-27 20:11:30', NULL, '0' ),
( '8', 'extra_holiday', 'Extra holiday', '7', '1', '2020-05-20 20:30:18', '2020-04-27 20:11:30', NULL, '0' ),
( '9', 'seminar', 'Seminar', '8', '0', '2020-07-14 10:05:23', '2020-04-27 20:11:30', NULL, '0' ),
( '10', 'weekend', 'Weekend', '9', '1', '2020-07-14 10:05:29', '2020-04-27 20:11:30', NULL, '0' );

-- CREATE TABLE "history_items" --------------------------------
CREATE TABLE `@target_database@`.`history_items` ( 
	`id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`model` VarChar( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`model_id` Char( 100 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`control` VarChar( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`user_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`last_visit` Timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	`created_at` Timestamp NULL,
	`updated_at` Timestamp NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;
-- -------------------------------------------------------------

-- CREATE TABLE "password_resets" ------------------------------
CREATE TABLE `@target_database@`.`password_resets` ( 
	`email` VarChar( 255 ) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
	`token` VarChar( 255 ) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
	`created_at` Timestamp NULL )
CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
ENGINE = InnoDB;