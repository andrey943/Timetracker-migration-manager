DROP TABLE IF EXISTS `timetracker_migration_temp`.`time_entries`;

-- CREATE TABLE "time_entries" ---------------------------------
CREATE TABLE `timetracker_migration_temp`.`time_entries` ( 
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
        `uuid` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
-- 	`created` Timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
-- 	`modified` Timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP DEFAULT '0000-00-00 00:00:00',
	`day_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`created` Timestamp NOT NULL,
	`modified` Timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
        `accounting_date` Date NOT NULL,
	`developer_id` Int( 11 ) NOT NULL,
        `user_id`  Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`did_alias` Int( 11 ) NULL,
        `alias_id`  Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`pid` Int( 11 ) NOT NULL,
        `project_id`  Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`description` Text CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`time` Float( 12, 0 ) NOT NULL DEFAULT 0,
	`hour_type_id` Int( 11 ) NOT NULL,
	`dev_status` Enum( 'new', 'approved' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'new',
	`adm_status` Enum( 'new', 'approved' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'new',
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;
-- -------------------------------------------------------------

INSERT INTO `timetracker_migration_temp`.`time_entries` ( 
    `id`,
    `uuid`,
    `created`,
    `modified`,
    `accounting_date`,
    `developer_id`,
    `user_id`,
    `did_alias`,
    `alias_id`,
    `pid`,
    `project_id`,
    `description`,
    `time`,
    `hour_type_id`,
    `dev_status`,
    `adm_status`
)
(SELECT * FROM (
    SELECT 
    `@source_database@`.`time_entries`.`id`,
    UUID() uuid,
    IF(`@source_database@`.`time_entries`.`created` LIKE '0000-00-00%', CURRENT_TIMESTAMP(), TIMESTAMP(`@source_database@`.`time_entries`.`created`)) created,
    IF(`@source_database@`.`time_entries`.`modified` LIKE '0000-00-00%', CURRENT_TIMESTAMP(), TIMESTAMP(`@source_database@`.`time_entries`.`modified`)) modified,
    DATE(`@source_database@`.`time_entries`.`created`) accounting_date,
    `@source_database@`.`time_entries`.`developer_id`,
    `developers`.`uuid` user_id,
    `@source_database@`.`time_entries`.`did_alias`,
    `aliases`.`uuid` alias_id,
    `@source_database@`.`time_entries`.`project_id` pid,
    `timetracker_migration_temp`.`projects`.`uuid` project_id,
    `@source_database@`.`time_entries`.`description`,
    `@source_database@`.`time_entries`.`time`*3600 time,
    `@source_database@`.`time_entries`.`hour_type_id`,
    `@source_database@`.`time_entries`.`dev_status`,
    `@source_database@`.`time_entries`.`adm_status`
    FROM `@source_database@`.`time_entries`
    LEFT JOIN `timetracker_migration_temp`.`users` as developers
    ON `@source_database@`.`time_entries`.`developer_id` = `developers`.`id`
    LEFT JOIN `timetracker_migration_temp`.`users` as aliases
    ON `@source_database@`.`time_entries`.`did_alias` = `aliases`.`id`
    LEFT JOIN `timetracker_migration_temp`.`projects`
    ON `@source_database@`.`time_entries`.`project_id` = `timetracker_migration_temp`.`projects`.`id`
) AS X);

DROP TABLE IF EXISTS `@target_database@`.`time_entries`;

DROP TABLE IF EXISTS `@target_database@`.`days`;

-- CREATE TABLE "days" -----------------------------------------
CREATE TABLE `@target_database@`.`days` ( 
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
-- -------------------------------------------------------------

-- CREATE INDEX "user_id" --------------------------------------
CREATE INDEX `user_id` USING BTREE ON `@target_database@`.`days`( `user_id` );
-- -------------------------------------------------------------

-- CREATE LINK "days_user_id_foreign" --------------------------
ALTER TABLE `@target_database@`.`days`
	ADD CONSTRAINT `days_user_id_foreign` FOREIGN KEY ( `user_id` )
	REFERENCES `users`( `id` )
	ON DELETE CASCADE
	ON UPDATE NO ACTION;


-- CREATE TABLE "time_entries" ---------------------------------
CREATE TABLE `@target_database@`.`time_entries` ( 
	`id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`created_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`time_spent` Float( 12, 2 ) NULL DEFAULT 0.00,
	`user_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`project_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`hour_type_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`approved_by` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`day_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`alias_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`description` LongText CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
        `client_id_alt` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;
-- -------------------------------------------------------------

-- CREATE INDEX "index_created_at" -----------------------------
CREATE INDEX `index_created_at` USING BTREE ON `@target_database@`.`time_entries`( `created_at` );
-- -------------------------------------------------------------

-- CREATE INDEX "time_entries_day_id_foreign" ------------------
CREATE INDEX `time_entries_day_id_foreign` USING BTREE ON `@target_database@`.`time_entries`( `day_id` );
-- -------------------------------------------------------------

-- CREATE INDEX "time_entries_project_id_foreign" --------------
CREATE INDEX `time_entries_project_id_foreign` USING BTREE ON `@target_database@`.`time_entries`( `project_id` );
-- -------------------------------------------------------------

-- CREATE INDEX "time_entries_user_id_foreign" -----------------
CREATE INDEX `time_entries_user_id_foreign` USING BTREE ON `@target_database@`.`time_entries`( `user_id` );
-- -------------------------------------------------------------

-- CREATE LINK "time_entries_day_id_foreign" -------------------
ALTER TABLE `@target_database@`.`time_entries`
	ADD CONSTRAINT `time_entries_day_id_foreign` FOREIGN KEY ( `day_id` )
	REFERENCES `days`( `id` )
	ON DELETE CASCADE
	ON UPDATE NO ACTION;
-- -------------------------------------------------------------

-- CREATE LINK "time_entries_project_id_foreign" ---------------
ALTER TABLE `@target_database@`.`time_entries`
	ADD CONSTRAINT `time_entries_project_id_foreign` FOREIGN KEY ( `project_id` )
	REFERENCES `projects`( `id` )
	ON DELETE CASCADE
	ON UPDATE NO ACTION;
-- -------------------------------------------------------------

-- CREATE LINK "time_entries_user_id_foreign" ------------------
ALTER TABLE `@target_database@`.`time_entries`
	ADD CONSTRAINT `time_entries_user_id_foreign` FOREIGN KEY ( `user_id` )
	REFERENCES `users`( `id` )
	ON DELETE CASCADE
	ON UPDATE NO ACTION;
-- -------------------------------------------------------------

-- INSERT INTO `timetracker_migration_temp`.`time_entries`------

INSERT INTO `@target_database@`.`time_entries` ( 
	`id`,
	`created_at`,
	`updated_at`,
	`time_spent`,
	`user_id`,
	`project_id`,
	`alias_id`,
	`description`
)
(SELECT * FROM (
    SELECT 
    `timetracker_migration_temp`.`time_entries`.`uuid` id,
    IF(`timetracker_migration_temp`.`time_entries`.`created` LIKE '0000-00-00%', CURRENT_TIMESTAMP(), TIMESTAMP(`timetracker_migration_temp`.`time_entries`.`created`)) created_at,
    IF(`timetracker_migration_temp`.`time_entries`.`modified` LIKE '0000-00-00%', CURRENT_TIMESTAMP(), TIMESTAMP(`timetracker_migration_temp`.`time_entries`.`modified`)) updated_at,
    `timetracker_migration_temp`.`time_entries`.`time` time_spent,
    `timetracker_migration_temp`.`time_entries`.`user_id`,
    `timetracker_migration_temp`.`time_entries`.`project_id`,
    `timetracker_migration_temp`.`time_entries`.`alias_id`,
    `timetracker_migration_temp`.`time_entries`.`description`
    FROM `timetracker_migration_temp`.`time_entries`
) AS X);


-- CROP EXTRA SECONDS -----------------------------------------
UPDATE `@target_database@`.`time_entries` SET `@target_database@`.`time_entries`.`time_spent` = 3600 * ROUND(`@target_database@`.`time_entries`.`time_spent` / 3600, 2);
-- -------------------------------------------------------------


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

INSERT INTO `@target_database@`.`days`
(
`id`,
`created_at`,
`updated_at`,
`accounting_date`,
`payment_period_id`,
`day_type_id`,
`approved_by`,
`is_open`,
`user_id`
)
SELECT 
    `timetracker_migration_temp`.`days_temp`.`id`, 
    UTC_TIMESTAMP() created_at,
    UTC_TIMESTAMP() updated_at,
    `timetracker_migration_temp`.`days_temp`.`accounting_date`,
    IF (`timetracker_migration_temp`.`days_temp`.`payment_period_id` != '' AND `timetracker_migration_temp`.`days_temp`.`payment_period_id` IS NOT NULL, `timetracker_migration_temp`.`days_temp`.`payment_period_id`, NULL) payment_period_id,
    IF (`timetracker_migration_temp`.`days_temp`.`payment_period_id` != '' AND `timetracker_migration_temp`.`days_temp`.`payment_period_id` IS NOT NULL, 1, '') day_type_id,
    IF (`timetracker_migration_temp`.`days_temp`.`payment_period_id` != '', "1", NULL) approved_by,
--     IF (payment_period_id != '' AND payment_period_id IS NOT NULL, 0, 1) is_open,
    IF ((`timetracker_migration_temp`.`days_temp`.`payment_period_id` != '' AND `timetracker_migration_temp`.`days_temp`.`payment_period_id` IS NOT NULL) OR `@source_database@`.`confirmed_dates`.`id` IS NOT NULL, 0, 1) is_open,
    `user_id`
FROM `timetracker_migration_temp`.`days_temp`
JOIN `timetracker_migration_temp`.`users` 
    ON `timetracker_migration_temp`.`days_temp`.`user_id` = `timetracker_migration_temp`.`users`.`uuid`
LEFT JOIN `@source_database@`.`confirmed_dates`
    ON `timetracker_migration_temp`.`users`.`id`=`@source_database@`.`confirmed_dates`.`did`
    AND `@source_database@`.`confirmed_dates`.`date`=`timetracker_migration_temp`.`days_temp`.`accounting_date`
GROUP BY `timetracker_migration_temp`.`days_temp`.`accounting_date`, `timetracker_migration_temp`.`days_temp`.`user_id`;
-- -------------------------------------------------------------
UPDATE `timetracker_migration_temp`.`time_entries`  te
JOIN  `timetracker_migration_temp`.`days_temp` dt ON te.user_id=dt.user_id 
AND te.accounting_date=dt.accounting_date
SET te.day_id = dt.id;

UPDATE `@target_database@`.`time_entries`  te
JOIN  `timetracker_migration_temp`.`time_entries` tet ON te.id=tet.uuid 
SET te.day_id = tet.day_id;