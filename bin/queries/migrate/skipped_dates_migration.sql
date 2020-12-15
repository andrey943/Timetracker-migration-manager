DROP TABLE IF EXISTS `@target_database@`.`skipped_dates`;

DROP TABLE IF EXISTS `timetracker_migration_temp`.`confirmed_dates`;

-- CREATE TABLE "confirmed_dates" ------------------------------
CREATE TABLE `timetracker_migration_temp`.`confirmed_dates` ( 
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`created` Timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`date` Date NOT NULL,
	`did` Int( 11 ) NULL,
	`area` Enum( 'admin', 'developer' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`day_status_id` Int( 11 ) NULL,
	`pings` Int( 11 ) NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = latin1
COLLATE = latin1_swedish_ci
ENGINE = InnoDB;
-- -------------------------------------------------------------

-- CREATE INDEX "date" -----------------------------------------
CREATE INDEX `date` USING BTREE ON `timetracker_migration_temp`.`confirmed_dates`( `date` );
-- -------------------------------------------------------------

-- CREATE INDEX "day_status_id" --------------------------------
CREATE INDEX `day_status_id` USING BTREE ON `timetracker_migration_temp`.`confirmed_dates`( `day_status_id` );
-- -------------------------------------------------------------

-- CREATE INDEX "did" ------------------------------------------
CREATE INDEX `did` USING BTREE ON `timetracker_migration_temp`.`confirmed_dates`( `did` );

INSERT INTO `timetracker_migration_temp`.`confirmed_dates` ( 
    `id`,
    `created`,
    `date`,
    `did`,
    `area`,
    `day_status_id`,
    `pings`
)
(SELECT * FROM (
    SELECT 
        `id`,
        `created`,
        `date`,
        `did`,
        `area`,
        `day_status_id`,
        `pings`
    FROM `@source_database@`.`confirmed_dates`
    WHERE `@source_database@`.`confirmed_dates`.`did` IS NULL
) AS x);
-- -------------------------------------------------------------

-- CREATE TABLE "skipped_dates" --------------------------------
CREATE TABLE `@target_database@`.`skipped_dates` ( 
	`id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`created_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`date` Date NULL,
	`skipped_by` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;
-- ---------------------

INSERT INTO `@target_database@`.`skipped_dates` ( `id`, `date`, `skipped_by`) 
(SELECT * FROM (
    SELECT 
        UUID() `id`,
        `date`,
        '1' `skipped_by`
    FROM `timetracker_migration_temp`.`confirmed_dates`
    WHERE 1
) AS x);