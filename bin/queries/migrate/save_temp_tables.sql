-- CREATE TABLE "users" ----------------------------------------
CREATE TABLE `@target_database@`.`users_temp` ( 
	`id` Int( 11 ) NOT NULL,
	`name` VarChar( 200 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`email` VarChar( 200 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`password` VarChar( 200 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`created` Timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	`modified` Timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	`last_visit` Timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	`role` Enum( 'developer', 'client' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`status` Enum( 'active', 'hidden' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'active',
	`uuid` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;
-- -------------------------------------------------------------

-- CREATE INDEX "index_uuid3" ----------------------------------
CREATE INDEX `index_uuid3` USING BTREE ON `@target_database@`.`users_temp`( `uuid` );
-- -------------------------------------------------------------

INSERT INTO `@target_database@`.`users_temp` SELECT * FROM `timetracker_migration_temp`.`users`;

-- CREATE TABLE "projects" -------------------------------------
CREATE TABLE `@target_database@`.`projects_temp` ( 
	`id` Int( 11 ) NOT NULL,
	`name` VarChar( 200 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`created` Timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	`modified` Timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	`status` Enum( 'active', 'hidden' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'active',
	`uuid` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;
-- -------------------------------------------------------------

-- CREATE INDEX "index_uuid1" ----------------------------------
CREATE INDEX `index_uuid1` USING BTREE ON `@target_database@`.`projects_temp`( `uuid` );
-- -------------------------------------------------------------

INSERT INTO `@target_database@`.`projects_temp` SELECT * FROM `timetracker_migration_temp`.`projects`;

-- CREATE TABLE "time_entries" ---------------------------------
CREATE TABLE `@target_database@`.`time_entries_temp` ( 
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

-- CREATE INDEX "index_uuid" -----------------------------------
CREATE INDEX `index_uuid` USING BTREE ON `@target_database@`.`time_entries_temp`( `uuid` );
-- -------------------------------------------------------------

INSERT INTO `@target_database@`.`time_entries_temp` SELECT * FROM `timetracker_migration_temp`.`time_entries`;

-- CREATE TABLE "hour_types_temp" ------------------------------
CREATE TABLE `@target_database@`.`hour_types_temp` ( 
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`uuid` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`name` VarChar( 200 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`created_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`status` Enum( 'active', 'hidden' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'active',
	`overtime` Enum( 'no', 'yes' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'yes',
	`predefined` Enum( 'no', 'yes' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'no',
	`order` Int( 11 ) NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;

-- CREATE INDEX "index_uuid2" ----------------------------------
CREATE INDEX `index_uuid2` USING BTREE ON `@target_database@`.`hour_types_temp`( `uuid` );
-- -------------------------------------------------------------

INSERT INTO `@target_database@`.`hour_types_temp` SELECT * FROM `timetracker_migration_temp`.`hour_types_temp`;