DROP TABLE IF EXISTS `timetracker_migration_temp`.`days_temp`;

-- CREATE TABLE "days" -----------------------------------------
CREATE TABLE `timetracker_migration_temp`.`days_temp` ( 
	`id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`is_open` TinyInt( 4 ) NULL,
	`created_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`accounting_date` Date NULL,
	`payment_period_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`day_type_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`approved_by` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`user_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`approved_at` Date NULL,
	`closed_by` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`closed_at` DateTime NULL,
	`pinged_count` Int( 11 ) NULL DEFAULT 0,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;


-- CREATE INDEX "index_accounting_date" ------------------------
CREATE INDEX `index_accounting_date` USING BTREE ON `timetracker_migration_temp`.`days_temp`( `accounting_date` );
-- -------------------------------------------------------------

-- CREATE INDEX "index_payment_period_id" ----------------------
CREATE INDEX `index_payment_period_id` USING BTREE ON `timetracker_migration_temp`.`days_temp`( `payment_period_id` );
-- -------------------------------------------------------------

-- CREATE INDEX "index_user_id" --------------------------------
CREATE INDEX `index_user_id` USING BTREE ON `timetracker_migration_temp`.`days_temp`( `user_id` );

INSERT INTO `timetracker_migration_temp`.`days_temp` (
    `id`,
    `accounting_date`,
    `user_id`
)
(SELECT * FROM (
    SELECT
        UUID() id,
       `accounting_date`,
       `timetracker_migration_temp`.`time_entries`.`user_id` user_id
    FROM `timetracker_migration_temp`.`time_entries` 
    GROUP BY `accounting_date`, `user_id`
) AS X);

UPDATE `timetracker_migration_temp`.`days_temp` dt
JOIN  `@target_database@`.`payment_periods` pp 
ON dt.user_id=pp.user_id 
AND dt.accounting_date BETWEEN pp.start_date AND pp.end_date
SET dt.payment_period_id = pp.id;


-- DROP TABLE IF EXISTS `@target_database@`.`days`;


-- -------------------------------------------------------------
