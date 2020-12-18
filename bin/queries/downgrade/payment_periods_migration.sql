
DROP TABLE IF EXISTS `timetracker_downgrade_migration_temp`.`payment_periods`;

-- CREATE TABLE "payment_periods" ------------------------------
CREATE TABLE `timetracker_downgrade_migration_temp`.`payment_periods` ( 
	`id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`created_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`user_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`start_date` Date NOT NULL,
	`end_date` Date NOT NULL,
	`uid` Int( 11 ) NOT NULL,
	`is_last_closed` Enum( 'no', 'yes' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'no',
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;
-- -------------------------------------------------------------

-- CREATE INDEX "uid" ------------------------------------------
CREATE INDEX `uid` USING BTREE ON `timetracker_downgrade_migration_temp`.`payment_periods`( `uid` );
-- -------------------------------------------------------------

-- CREATE INDEX "index_created_at" -----------------------------
CREATE INDEX `index_created_at` USING BTREE ON `timetracker_downgrade_migration_temp`.`payment_periods`( `created_at` );
-- -------------------------------------------------------------

-- CREATE INDEX "index_user_id" --------------------------------
CREATE INDEX `index_user_id` USING BTREE ON `timetracker_downgrade_migration_temp`.`payment_periods`( `user_id` );
-- -------------------------------------------------------------

-- CREATE TABLE "payment_periods" ------------------------------
CREATE TABLE `@target_database@`.`payment_periods` ( 
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`start_date` Date NOT NULL,
	`end_date` Date NOT NULL,
	`uid` Int( 11 ) NOT NULL,
	`is_last_closed` Enum( 'no', 'yes' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'no',
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;
-- -------------------------------------------------------------

-- CREATE INDEX "end_date" -------------------------------------
CREATE INDEX `end_date` USING BTREE ON `@target_database@`.`payment_periods`( `end_date` );
-- -------------------------------------------------------------

-- CREATE INDEX "start_date" -----------------------------------
CREATE INDEX `start_date` USING BTREE ON `@target_database@`.`payment_periods`( `start_date` );

-- CREATE INDEX "uid" ------------------------------------------
CREATE INDEX `uid` USING BTREE ON `@target_database@`.`payment_periods`( `uid` );
-- -------------------------------------------------------------

-- CREATE LINK "payment_periods_ibfk_1" ------------------------
ALTER TABLE `@target_database@`.`payment_periods`
	ADD CONSTRAINT `payment_periods_ibfk_1` FOREIGN KEY ( `uid` )
	REFERENCES `@target_database@`.`users`( `id` )
	ON DELETE Cascade
	ON UPDATE Cascade;
-- -------------------------------------------------------------

