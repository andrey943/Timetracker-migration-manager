DROP TABLE IF EXISTS `@target_database@`.`user_aliases`;

-- CREATE TABLE "user_aliases" ---------------------------------
CREATE TABLE `@target_database@`.`user_aliases` ( 
	`id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`user_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`alias_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`project_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`created_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DateTime NULL DEFAULT CURRENT_TIMESTAMP,
	`is_active` TinyInt( 4 ) NULL DEFAULT 1,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;
-- -------------------------------------------------------------

-- CREATE INDEX "user_aliases_alias_id_foreign" ----------------
CREATE INDEX `user_aliases_alias_id_foreign` USING BTREE ON `@target_database@`.`user_aliases`( `alias_id` );
-- -------------------------------------------------------------

-- CREATE INDEX "user_aliases_project_id_foreign" --------------
CREATE INDEX `user_aliases_project_id_foreign` USING BTREE ON `@target_database@`.`user_aliases`( `project_id` );
-- -------------------------------------------------------------

-- CREATE INDEX "user_aliases_user_id_foreign" -----------------
CREATE INDEX `user_aliases_user_id_foreign` USING BTREE ON `@target_database@`.`user_aliases`( `user_id` );
-- -------------------------------------------------------------

-- CREATE LINK "user_aliases_alias_id_foreign" -----------------
ALTER TABLE `@target_database@`.`user_aliases`
	ADD CONSTRAINT `user_aliases_alias_id_foreign` FOREIGN KEY ( `alias_id` )
	REFERENCES `users`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------

-- CREATE LINK "user_aliases_project_id_foreign" ---------------
ALTER TABLE `@target_database@`.`user_aliases`
	ADD CONSTRAINT `user_aliases_project_id_foreign` FOREIGN KEY ( `project_id` )
	REFERENCES `projects`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------

-- CREATE LINK "user_aliases_user_id_foreign" ------------------
ALTER TABLE `@target_database@`.`user_aliases`
	ADD CONSTRAINT `user_aliases_user_id_foreign` FOREIGN KEY ( `user_id` )
	REFERENCES `users`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;
-- -------------------------------------------------------------

INSERT INTO `@target_database@`.`user_aliases` ( 
	`id`,
	`user_id`,
	`alias_id`,
	`project_id`,
	`created_at`,
	`updated_at` 
    )
(SELECT * FROM (
    SELECT 
        UUID() id,
        `developers`.`uuid` user_id,
        `aliases`.`uuid` alias_id,
        `timetracker_migration_temp`.`projects`.`uuid` project_id,
	UTC_TIMESTAMP() `created_at`,
	UTC_TIMESTAMP() `updated_at` 
    FROM `@source_database@`.`users_projects_xref`
    LEFT JOIN `timetracker_migration_temp`.`users` as developers
    ON `@source_database@`.`users_projects_xref`.`uid` = `developers`.`id`
    JOIN `timetracker_migration_temp`.`users` as aliases
    ON `@source_database@`.`users_projects_xref`.`did_alias` = `aliases`.`id`
    LEFT JOIN `timetracker_migration_temp`.`projects`
    ON `@source_database@`.`users_projects_xref`.`pid` = `timetracker_migration_temp`.`projects`.`id`
) as x);