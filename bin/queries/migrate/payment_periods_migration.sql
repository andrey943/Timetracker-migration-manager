DROP TABLE IF EXISTS `@target_database@`.`payment_periods`;
-- -------------------------------------------------------------

-- CREATE TABLE "payment_periods" ------------------------------
CREATE TABLE `@target_database@`.`payment_periods` ( 
	`created_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`start_date` Date NULL,
	`end_date` Date NULL,
	`is_open` TinyInt( 4 ) NULL DEFAULT 1,
	`user_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;
-- -------------------------------------------------------------

-- CREATE INDEX "payment_periods_user_id_foreign" --------------
CREATE INDEX `payment_periods_user_id_foreign` USING BTREE ON `@target_database@`.`payment_periods`( `user_id` );
-- -------------------------------------------------------------

-- CREATE LINK "payment_periods_user_id_foreign" ---------------
ALTER TABLE `@target_database@`.`payment_periods`
	ADD CONSTRAINT `payment_periods_user_id_foreign` FOREIGN KEY ( `user_id` )
	REFERENCES `users`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;

-- CREATE INDEX "index_end_date" -------------------------------
CREATE INDEX `index_end_date` USING BTREE ON `@target_database@`.`payment_periods`( `end_date` );
-- -------------------------------------------------------------

-- CREATE INDEX "index_start_date" -----------------------------
CREATE INDEX `index_start_date` USING BTREE ON `@target_database@`.`payment_periods`( `start_date` );
-- -------------------------------------------------------------

INSERT INTO `@target_database@`.`payment_periods` ( 
        `id`,
	`start_date`,
	`end_date`,
	`is_open`,
	`user_id`
    )
(SELECT * FROM (
    SELECT 
        UUID() id,
        `@source_database@`.`payment_periods`.`start_date` start_date,
        `@source_database@`.`payment_periods`.`end_date` end_date,
        IF(`@source_database@`.`payment_periods`.`end_date` = '' OR `@source_database@`.`payment_periods`.`end_date` IS NULL, 1, 0) is_open,
        `timetracker_migration_temp`.`users`.`uuid` user_id
    FROM `@source_database@`.`payment_periods`
    LEFT JOIN `timetracker_migration_temp`.`users`
        ON `@source_database@`.`payment_periods`.`uid` = `timetracker_migration_temp`.`users`.`id`
) as x);