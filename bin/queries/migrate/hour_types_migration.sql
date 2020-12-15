DROP TABLE IF EXISTS `timetracker_migration_temp`.`hour_types_temp`;

-- CREATE TABLE "hour_types" -----------------------------------
CREATE TABLE `timetracker_migration_temp`.`hour_types_temp` ( 
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
-- -------------------------------------------------------------

-- CREATE INDEX "order" ----------------------------------------
CREATE INDEX `order` USING BTREE ON `timetracker_migration_temp`.`hour_types_temp`( `order` );

INSERT INTO `timetracker_migration_temp`.`hour_types_temp` (
	`id`,
        `uuid`,
	`name`,
	`created_at`,
	`updated_at`,
	`status`,
	`overtime`,
	`predefined`,
	`order`
)
(SELECT * FROM (
    SELECT
	`id`,
        UUID() `uuid`,
	`name`,
        IF(`@source_database@`.`hour_types`.`created` LIKE '0000-00-00%', CURRENT_TIMESTAMP(), TIMESTAMP(`@source_database@`.`hour_types`.`created`)) created_at,
        IF(`@source_database@`.`hour_types`.`modified` LIKE '0000-00-00%', CURRENT_TIMESTAMP(), TIMESTAMP(`@source_database@`.`hour_types`.`modified`)) updated_at,
    	`status`,
	`overtime`,
	`predefined`,
	`order`
    FROM `@source_database@`.`hour_types`
) AS X);


DROP TABLE IF EXISTS `@target_database@`.`hour_type_user`;

DROP TABLE IF EXISTS `@target_database@`.`hour_types`;

-- CREATE TABLE "hour_types" -----------------------------------
CREATE TABLE `@target_database@`.`hour_types` ( 
	`id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`name` VarChar( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`item_order` Int( 11 ) NULL,
	`updated_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`created_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`is_overtime` TinyInt( 4 ) NULL DEFAULT 0,
	`is_active` TinyInt( 4 ) NULL DEFAULT 1,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;

INSERT INTO `@target_database@`.`hour_types` (
	`id`,
	`name`,
	`created_at`,
	`updated_at`,
	`item_order`,
        `is_active`,
        `is_overtime`
)
(SELECT * FROM (
    SELECT
	`timetracker_migration_temp`.`hour_types_temp`.`uuid` id,
	`timetracker_migration_temp`.`hour_types_temp`.`name`,
	`timetracker_migration_temp`.`hour_types_temp`.`created_at`,
	`timetracker_migration_temp`.`hour_types_temp`.`updated_at`,
	`timetracker_migration_temp`.`hour_types_temp`.`order` item_order,
        IF (`timetracker_migration_temp`.`hour_types_temp`.`status` = 'active', 1, 0) is_active,
        IF (`timetracker_migration_temp`.`hour_types_temp`.`overtime` = 'yes', 1, 0) is_overtime
    FROM `timetracker_migration_temp`.`hour_types_temp`
) AS X);


-- -------------------------------------------------------------


-- CREATE TABLE "hour_type_user" -------------------------------
CREATE TABLE `@target_database@`.`hour_type_user` ( 
	`id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`user_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`hour_type_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`created_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;
-- -------------------------------------------------------------

-- CREATE LINK "user_hour_type_hour_type_id_foreign" -----------
ALTER TABLE `@target_database@`.`hour_type_user`
	ADD CONSTRAINT `user_hour_type_hour_type_id_foreign` FOREIGN KEY ( `hour_type_id` )
	REFERENCES `hour_types`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------

-- CREATE LINK "user_hour_type_user_id_foreign" ----------------
ALTER TABLE `@target_database@`.`hour_type_user`
	ADD CONSTRAINT `user_hour_type_user_id_foreign` FOREIGN KEY ( `user_id` )
	REFERENCES `users`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------

INSERT INTO `@target_database@`.`hour_type_user` (
	`id`,
        `user_id`,
	`hour_type_id`,
	`created_at`,
	`updated_at`
)
(SELECT * FROM (
    SELECT
        UUID() id,
        `timetracker_migration_temp`.`users`.`uuid` user_id,
        `timetracker_migration_temp`.`hour_types_temp`.`uuid` hour_type_id,
	CURRENT_TIMESTAMP() created_at,
	CURRENT_TIMESTAMP() updated_at
    FROM `@source_database@`.`dev_hour_types` 
    JOIN `timetracker_migration_temp`.`hour_types_temp`
        ON `@source_database@`.`dev_hour_types`.`htid` = `timetracker_migration_temp`.`hour_types_temp`.`id`
    JOIN `timetracker_migration_temp`.`users`
        ON `timetracker_migration_temp`.`users`.`id` = `@source_database@`.`dev_hour_types`.`did`
) AS X);