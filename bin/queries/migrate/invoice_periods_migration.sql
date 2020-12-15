DROP TABLE IF EXISTS `@target_database@`.`invoice_periods`;
-- -------------------------------------------------------------
-- CREATE TABLE "invoice_periods" ------------------------------
CREATE TABLE `@target_database@`.`invoice_periods` ( 
	`id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`created_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`start_date` Date NULL,
	`end_date` Date NULL,
	`is_open` TinyInt( 4 ) NULL DEFAULT 1,
	`user_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;
-- -------------------------------------------------------------

-- CREATE INDEX "invoice_periods_user_id_foreign" --------------
CREATE INDEX `invoice_periods_user_id_foreign` USING BTREE ON `@target_database@`.`invoice_periods`( `user_id` );
-- -------------------------------------------------------------

-- CREATE LINK "invoice_periods_user_id_foreign" ---------------
ALTER TABLE `@target_database@`.`invoice_periods`
	ADD CONSTRAINT `invoice_periods_user_id_foreign` FOREIGN KEY ( `user_id` )
	REFERENCES `users`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------

INSERT INTO `@target_database@`.`invoice_periods` ( 
        `id`,
	`start_date`,
	`end_date`,
	`is_open`,
	`user_id`
    )
(SELECT * FROM (
    SELECT 
        UUID() id,
        `@source_database@`.`invoice_periods`.`start_date` start_date,
        `@source_database@`.`invoice_periods`.`end_date` end_date,
        IF(`@source_database@`.`invoice_periods`.`end_date` = '' OR `@source_database@`.`invoice_periods`.`end_date` IS NULL, 0, 1) is_open,
        `timetracker_migration_temp`.`users`.`uuid` user_id
    FROM `@source_database@`.`invoice_periods`
    LEFT JOIN `timetracker_migration_temp`.`users`
        ON `@source_database@`.`invoice_periods`.`uid` = `timetracker_migration_temp`.`users`.`id`
) as x);