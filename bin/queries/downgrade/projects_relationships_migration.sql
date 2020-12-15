
DROP TABLE IF EXISTS `timetracker_downgrade_migration_temp`.`project_user`;

-- CREATE TABLE "projects" -------------------------------------
CREATE TABLE `timetracker_downgrade_migration_temp`.`project_user` (
	`id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`created_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
        `user_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
        `project_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`uid` Int( 11 ) NOT NULL,
	`pid` Int( 11 ) NOT NULL,
	`did_alias` Int( 11 ) NOT NULL DEFAULT 0,
	PRIMARY KEY ( `uid`, `pid`, `did_alias` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;
-- -------------------------------------------------------------

-- CREATE INDEX "did_alias" ------------------------------------
CREATE INDEX `did_alias` USING BTREE ON `timetracker_downgrade_migration_temp`.`project_user`( `did_alias` );
-- -------------------------------------------------------------

-- CREATE INDEX "pid" ------------------------------------------
CREATE INDEX `pid` USING BTREE ON `timetracker_downgrade_migration_temp`.`project_user`( `pid` );
-- -------------------------------------------------------------

INSERT INTO `timetracker_downgrade_migration_temp`.`project_user` 
SELECT 
    `pu`.`id`,
    `pu`.`created_at`,
    `pu`.`updated_at`,
    `pu`.`user_id`,
    `pu`.`project_id`,
    `tu`.`id` `uid`,
    `tp`.`id` `pid`,
    IF(`aliases`.`id` IS NULL, 0, `aliases`.`id`) `did_alias`
FROM `@source_database@`.`project_user` pu 
    JOIN `timetracker_downgrade_migration_temp`.`projects` tp ON `pu`.`project_id` = `tp`.`uuid`
    JOIN `timetracker_downgrade_migration_temp`.`users` tu ON `pu`.`user_id` = `tu`.`uuid`
    LEFT JOIN `@source_database@`.`user_aliases` ua 
        ON `ua`.`project_id` = `pu`.`project_id` 
        AND `ua`.`user_id` = `pu`.`user_id`
    LEFT JOIN `timetracker_downgrade_migration_temp`.`users` aliases ON `aliases`.`uuid` = `ua`.`alias_id`;

-- CREATE TABLE "users_projects_xref" --------------------------
CREATE TABLE `@target_database@`.`users_projects_xref` ( 
	`uid` Int( 11 ) NOT NULL,
	`pid` Int( 11 ) NOT NULL,
	`did_alias` Int( 11 ) NOT NULL DEFAULT 0,
	PRIMARY KEY ( `uid`, `pid`, `did_alias` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;
-- -------------------------------------------------------------

-- CREATE INDEX "did_alias" ------------------------------------
CREATE INDEX `did_alias` USING BTREE ON `@target_database@`.`users_projects_xref`( `did_alias` );
-- -------------------------------------------------------------

-- CREATE INDEX "pid" ------------------------------------------
CREATE INDEX `pid` USING BTREE ON `@target_database@`.`users_projects_xref`( `pid` );
-- -------------------------------------------------------------

INSERT INTO `@target_database@`.`users_projects_xref` SELECT * FROM `@source_live@`.`users_projects_xref`;