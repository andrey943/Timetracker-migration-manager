
DROP TABLE IF EXISTS `timetracker_downgrade_migration_temp`.`users`;

CREATE TABLE `timetracker_downgrade_migration_temp`.`users` ( 
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`name` VarChar( 200 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`email` VarChar( 200 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`password` VarChar( 200 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`created` Timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	`modified` Timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	`last_visit` Timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	`role` Enum( 'developer', 'client' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`status` Enum( 'active', 'hidden' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'active',
	`uuid` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB
AUTO_INCREMENT = 500;

INSERT INTO `timetracker_downgrade_migration_temp`.`users` SELECT * FROM `@source_database@`.`users_temp`;

CREATE TABLE `@target_database@`.`users` (
	`id` Int( 11 ) AUTO_INCREMENT NOT NULL,
	`name` VarChar( 200 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`email` VarChar( 200 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`password` VarChar( 200 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`created` Timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	`modified` Timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	`last_visit` Timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	`role` Enum( 'developer', 'client' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`status` Enum( 'active', 'hidden' ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'active',
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;
-- -------------------------------------------------------------

-- CREATE INDEX "role" -----------------------------------------
CREATE INDEX `role` USING BTREE ON `@target_database@`.`users`( `role` );
-- -------------------------------------------------------------

INSERT INTO `@target_database@`.`users` SELECT * FROM `@source_live@`.`users`;