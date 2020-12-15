
DROP TABLE IF EXISTS `timetracker_migration_temp`.`projects`;

CREATE TABLE `timetracker_migration_temp`.`projects` ( 
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

INSERT INTO `timetracker_migration_temp`.`projects` SELECT * , UUID() uuid FROM `@source_database@`.`projects`;

UPDATE `timetracker_migration_temp`.`projects` SET created = NULL WHERE CAST(created AS CHAR(20)) = '0000-00-00 00:00:00';
UPDATE `timetracker_migration_temp`.`projects` SET modified = NULL WHERE CAST(modified AS CHAR(20)) = '0000-00-00 00:00:00';

DROP TABLE IF EXISTS `@target_database@`.`projects`;

CREATE TABLE `@target_database@`.`projects` ( 
	`id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`name` VarChar( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`created_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`is_active` TinyInt( 4 ) NULL DEFAULT 1,
	CONSTRAINT `unq_projects_id` UNIQUE( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;

INSERT INTO `@target_database@`.`projects` (
    `id`,
    `name`,
    `created_at`,
    `updated_at`,
    `is_active`
) 
(SELECT * FROM (
    SELECT uuid id, 
    name, 
    created created_at, 
    modified updated_at,
    IF (status = 'active', 1 , 0) is_active
    FROM `timetracker_migration_temp`.`projects` where 1
) AS X);