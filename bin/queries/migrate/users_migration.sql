
DROP TABLE IF EXISTS `timetracker_migration_temp`.`users`;

CREATE TABLE `timetracker_migration_temp`.`users` ( 
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

INSERT INTO `timetracker_migration_temp`.`users` SELECT * , UUID() uuid FROM `@source_database@`.`users`;

UPDATE `timetracker_migration_temp`.`users` SET last_visit = NULL WHERE CAST(last_visit AS CHAR(20)) = '0000-00-00 00:00:00';
UPDATE `timetracker_migration_temp`.`users` SET created = NULL WHERE CAST(created AS CHAR(20)) = '0000-00-00 00:00:00';
UPDATE `timetracker_migration_temp`.`users` SET modified = NULL WHERE CAST(modified AS CHAR(20)) = '0000-00-00 00:00:00';

CREATE TABLE `@target_database@`.`users` (
	`id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`name` VarChar( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`email` VarChar( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`password` VarChar( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`created_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`last_visit` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`is_admin` TinyInt( 4 ) NULL DEFAULT 0,
	`remember_token` VarChar( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`email_verified_at` Timestamp NULL,
	`is_active` TinyInt( 255 ) NOT NULL DEFAULT 1,
	`user_type_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`first_name` VarChar( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`last_name` VarChar( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`company_name` VarChar( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`login` VarChar( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`auto_close` TinyInt( 4 ) NULL DEFAULT 0,
	`is_pm` TinyInt( 4 ) NULL DEFAULT 0,
	`is_short_day_allowed` TinyInt( 4 ) NULL DEFAULT 0,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;

INSERT INTO `@target_database@`.`users` ( 
        `id`,
        `name`,
        `login`,
        `email`,
        `password`,
        `created_at`,
        `updated_at`,
        `last_visit`,
        `is_active`,
        `user_type_id`,
        `auto_close`
    )
(SELECT * FROM (
    SELECT uuid id, 
    name,
    email login,
    email,
    password, 
    created created_at, 
    modified updated_at,
    last_visit,
    IF (`timetracker_migration_temp`.`users`.`status`='active', 1, 0) is_active, 
    IF (`timetracker_migration_temp`.`users`.`role`='client', 3, 2) user_type_id,
    IF (`@source_database@`.`dev_preferences`.`auto_close_period`='yes', 1, 0) auto_close
    FROM `timetracker_migration_temp`.`users` 
    LEFT JOIN `@source_database@`.`dev_preferences`
        ON `timetracker_migration_temp`.`users`.`id`=`@source_database@`.`dev_preferences`.`uid` 
    WHERE 1
) as x);


CREATE TABLE `timetracker_migration_temp`.`splited_user_names` ( 
	`id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`last_name` VarChar( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`first_name` VarChar( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`company_name` VarChar( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;

INSERT INTO `timetracker_migration_temp`.`splited_user_names`
SELECT id,
IF (user_type_id = 2, SUBSTRING_INDEX(SUBSTRING_INDEX(name, ' ', 1), ' ', -1), '') AS last_name,
IF (user_type_id = 2, TRIM( SUBSTR(name, LOCATE(' ', name)) ), '') AS first_name,
IF (user_type_id = 3, name, '') AS company_name
FROM `@target_database@`.`users`;

UPDATE `@target_database@`.`users` u 
JOIN `timetracker_migration_temp`.`splited_user_names` sun ON u.id = sun.id
SET u.first_name = sun.first_name,
u.last_name = sun.last_name,
u.company_name = sun.company_name;

CREATE TABLE `@target_database@`.`user_settings` ( 
	`id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`created_at` DateTime NULL,
	`updated_at` Date NULL,
	`field` VarChar( 100 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`value` Text CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`user_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;

CREATE INDEX `user_settings_user_id_foreign` USING BTREE ON `@target_database@`.`user_settings`( `user_id` );

ALTER TABLE `@target_database@`.`user_settings`
	ADD CONSTRAINT `user_settings_user_id_foreign` FOREIGN KEY ( `user_id` )
	REFERENCES `users`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;

