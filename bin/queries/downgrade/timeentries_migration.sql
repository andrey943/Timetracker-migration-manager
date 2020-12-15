
DROP TABLE IF EXISTS `timetracker_downgrade_migration_temp`.`time_entries`;

-- CREATE TABLE "time_entries" ---------------------------------
CREATE TABLE `timetracker_downgrade_migration_temp`.`time_entries` ( 
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`uuid` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`day_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`created` Timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	`modified` Timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`accounting_date` Date NOT NULL,
	`developer_id` Int( 11 ) NOT NULL,
	`user_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`did_alias` Int( 11 ) NULL,
	`alias_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`pid` Int( 11 ) NOT NULL,
	`project_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
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

-- -------------------------------------------------------------

INSERT INTO `timetracker_downgrade_migration_temp`.`time_entries` SELECT * FROM `@source_database@`.`time_entries_temp`;

-- CREATE TABLE "time_entries" ---------------------------------
CREATE TABLE `@target_database@`.`time_entries` ( 
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`created` Timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	`modified` Timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`developer_id` Int( 11 ) NOT NULL,
	`did_alias` Int( 11 ) NULL,
	`project_id` Int( 11 ) NOT NULL,
	`description` Text CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`time` Float( 12, 2 ) NOT NULL DEFAULT 0,
	`hour_type_id` Int( 11 ) NOT NULL,
	`dev_status` Enum( 'new', 'approved' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'new',
	`adm_status` Enum( 'new', 'approved' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'new',
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;
-- -------------------------------------------------------------

-- CREATE INDEX "created" --------------------------------------
CREATE INDEX `created` USING BTREE ON `@target_database@`.`time_entries`( `created` );
-- -------------------------------------------------------------

-- CREATE INDEX "developer_id" ---------------------------------
CREATE INDEX `developer_id` USING BTREE ON `@target_database@`.`time_entries`( `developer_id` );
-- -------------------------------------------------------------

-- CREATE INDEX "hour_type_id" ---------------------------------
CREATE INDEX `hour_type_id` USING BTREE ON `@target_database@`.`time_entries`( `hour_type_id` );
-- -------------------------------------------------------------

-- CREATE INDEX "project_id" -----------------------------------
CREATE INDEX `project_id` USING BTREE ON `@target_database@`.`time_entries`( `project_id` );
-- -------------------------------------------------------------

-- CREATE LINK "fk_time_entries_2" -----------------------------
ALTER TABLE `@target_database@`.`time_entries`
	ADD CONSTRAINT `fk_time_entries_2` FOREIGN KEY ( `project_id` )
	REFERENCES `@target_database@`.`projects`( `id` )
	ON DELETE CASCADE
	ON UPDATE CASCADE;
-- -------------------------------------------------------------

-- CREATE LINK "fk_time_entries_3" -----------------------------
ALTER TABLE `@target_database@`.`time_entries`
	ADD CONSTRAINT `fk_time_entries_3` FOREIGN KEY ( `hour_type_id` )
	REFERENCES `@target_database@`.`hour_types`( `id` )
	ON DELETE CASCADE
	ON UPDATE CASCADE;
-- -------------------------------------------------------------

-- CREATE LINK "time_entries_ibfk_1" ---------------------------
ALTER TABLE `@target_database@`.`time_entries`
	ADD CONSTRAINT `time_entries_ibfk_1` FOREIGN KEY ( `developer_id` )
	REFERENCES `@target_database@`.`users`( `id` )
	ON DELETE CASCADE
	ON UPDATE CASCADE;
-- -------------------------------------------------------------

-- -------------------------------------------------------------

INSERT INTO `@target_database@`.`time_entries` SELECT * FROM `@source_live@`.`time_entries`;