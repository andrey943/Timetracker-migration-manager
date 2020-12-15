
DROP TABLE IF EXISTS `timetracker_downgrade_migration_temp`.`hour_types`;

-- CREATE TABLE "hour_types" -------------------------------------
CREATE TABLE `timetracker_downgrade_migration_temp`.`hour_types` (
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`uuid` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`name` VarChar( 200 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`created` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`modified` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`status` Enum( 'active', 'hidden' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'active',
	`overtime` Enum( 'no', 'yes' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'yes',
	`predefined` Enum( 'no', 'yes' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'no',
	`order` Int( 11 ) NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;
-- -------------------------------------------------------------

-- CREATE INDEX "order" ----------------------------------------
CREATE INDEX `order` USING BTREE ON `timetracker_downgrade_migration_temp`.`hour_types`( `order` );
-- -------------------------------------------------------------

INSERT INTO `timetracker_downgrade_migration_temp`.`hour_types` SELECT * FROM `@source_database@`.`hour_types_temp`;

-- CREATE TABLE "hour_types" -------------------------------------
CREATE TABLE `@target_database@`.`hour_types` (
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`name` VarChar( 200 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`created` Timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	`modified` Timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	`status` Enum( 'active', 'hidden' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'active',
	`overtime` Enum( 'no', 'yes' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'yes',
	`predefined` Enum( 'no', 'yes' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'no',
	`order` Int( 11 ) NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;
-- -------------------------------------------------------------

-- CREATE INDEX "order" ----------------------------------------
CREATE INDEX `order` USING BTREE ON `@target_database@`.`hour_types`( `order` );
-- -------------------------------------------------------------

INSERT INTO `@target_database@`.`hour_types` SELECT * FROM `@source_live@`.`hour_types`;