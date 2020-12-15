-- CREATE TABLE "log" ------------------------------------------
CREATE TABLE `timetracker_downgrade_migration_temp`.`log` ( 
	`event` VarChar( 255 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
	`is_complete` TinyInt( 4 ) NOT NULL DEFAULT 1,
	`logged_at` DateTime NOT NULL )
CHARACTER SET = utf8
COLLATE = utf8_general_ci
ENGINE = InnoDB;
-- -------------------------------------------------------------