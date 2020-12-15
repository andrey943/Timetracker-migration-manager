
DROP TABLE IF EXISTS `timetracker_downgrade_migration_temp`.`projects`;

-- CREATE TABLE "projects" -------------------------------------
CREATE TABLE `timetracker_downgrade_migration_temp`.`projects` (
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`name` VarChar( 200 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`created` Timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	`modified` Timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	`status` Enum( 'active', 'hidden' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'active',
	`uuid` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB
AUTO_INCREMENT = 1500;
-- -------------------------------------------------------------

INSERT INTO `timetracker_downgrade_migration_temp`.`projects` SELECT * FROM `@source_database@`.`projects_temp`;


-- CREATE TABLE "projects" -------------------------------------
CREATE TABLE `@target_database@`.`projects` ( 
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`name` VarChar( 200 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`created` Timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	`modified` Timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	`status` Enum( 'active', 'hidden' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'active',
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;
-- -------------------------------------------------------------

INSERT INTO `@target_database@`.`projects` SELECT * FROM `@source_live@`.`projects`;