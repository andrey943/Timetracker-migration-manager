DROP TABLE IF EXISTS `@target_database@`.`project_pm` CASCADE;

CREATE TABLE `@target_database@`.`project_pm` ( 
	`id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`user_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`project_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`is_enabled` TinyInt( 4 ) NULL DEFAULT 1,
	`created_at` DateTime NULL,
	`updated_at` DateTime NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;

CREATE INDEX `fk_users_projects_projects_0` USING BTREE ON `@target_database@`.`project_pm`( `project_id` );

CREATE INDEX `fk_users_projects_users_0` USING BTREE ON `@target_database@`.`project_pm`( `user_id` );

ALTER TABLE `@target_database@`.`project_pm`
	ADD CONSTRAINT `project_user_project_id_foreign_0` FOREIGN KEY ( `project_id` )
	REFERENCES `projects`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;

ALTER TABLE `@target_database@`.`project_pm`
	ADD CONSTRAINT `project_user_user_id_foreign_0` FOREIGN KEY ( `user_id` )
	REFERENCES `users`( `id` )
	ON DELETE Cascade
	ON UPDATE No Action;

DROP TABLE IF EXISTS `@target_database@`.`project_user` CASCADE;

CREATE TABLE `@target_database@`.`project_user` ( 
	`id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`user_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`project_id` Char( 36 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
	`is_enabled` TinyInt( 4 ) NULL DEFAULT 1,
	`created_at` DateTime NULL,
	`updated_at` DateTime NULL,
	PRIMARY KEY ( `id` ) )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;

CREATE INDEX `project_user_project_id_foreign` USING BTREE ON `@target_database@`.`project_user`( `project_id` );

CREATE INDEX `project_user_user_id_foreign` USING BTREE ON `@target_database@`.`project_user`( `user_id` );

ALTER TABLE `@target_database@`.`project_user`
	ADD CONSTRAINT `project_user_project_id_foreign` FOREIGN KEY ( `project_id` )
	REFERENCES `projects`( `id` )
	ON DELETE CASCADE
	ON UPDATE NO ACTION;

ALTER TABLE `@target_database@`.`project_user`
	ADD CONSTRAINT `project_user_user_id_foreign` FOREIGN KEY ( `user_id` )
	REFERENCES `users`( `id` )
	ON DELETE CASCADE
	ON UPDATE NO ACTION;

INSERT INTO `@target_database@`.`project_user` ( `id`, `user_id`, `project_id`, `is_enabled`)
SELECT 
UUID() id,
tmtu.uuid user_id,
tmtp.uuid project_id,
1 is_enabled
FROM `@source_database@`.`users_projects_xref` tlupx 
JOIN `timetracker_migration_temp`.`projects` tmtp ON tmtp.id = tlupx.pid
JOIN `timetracker_migration_temp`.`users` tmtu ON tmtu.id = tlupx.uid
GROUP BY CONCAT(`tlupx`.`pid`, `tlupx`.`uid`);