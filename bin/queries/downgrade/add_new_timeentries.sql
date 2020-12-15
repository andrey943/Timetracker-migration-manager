INSERT INTO `timetracker_downgrade_migration_temp`.`time_entries` (
	`uuid`,
	`day_id`,
	`created`,
	`modified`,
	`accounting_date`,
	`developer_id`,
	`user_id`,
	`did_alias`,
	`alias_id`,
	`pid`,
	`project_id`,
	`description`,
	`time`,
	`hour_type_id`,
	`dev_status`,
	`adm_status`
    )
(SELECT * FROM (
    SELECT 
	`tmte`.`id`,
	`tmte`.`day_id`,
        `days`.`accounting_date` `created`, 
        `tmte`.`updated_at` `modified`,
	`days`.`accounting_date`,
	`developers`.`id` `developer_id`,
	`tmte`.`user_id`,
	`aliases`.`id` `did_alias`,
	`tmte`.`alias_id`,
	`projects`.`id` `pid`,
	`tmte`.`project_id`,
	`tmte`.`description`,
        ROUND(`tmte`.`time_spent`/3600, 2) `time`,
	IFNULL(`htypes`.`id`, 1) `hour_type_id`,
	'new' `dev_status`,
	'new' `adm_status`
    FROM  `@source_database@`.`time_entries` tmte
    LEFT JOIN `@source_database@`.`time_entries_temp` tmtet  
        ON tmtet.uuid = tmte.id
    LEFT JOIN `@source_database@`.`users_temp` developers
        ON `tmte`.`user_id` = `developers`.`uuid`
    LEFT JOIN `@source_database@`.`users_temp` aliases
        ON `tmte`.`alias_id` = `aliases`.`uuid`
    LEFT JOIN `@source_database@`.`projects_temp` projects
        ON `tmte`.`project_id` = `projects`.`uuid`
    LEFT JOIN `@source_database@`.`hour_types_temp` htypes
        ON `tmte`.`hour_type_id` = `htypes`.`uuid`
    LEFT JOIN `@source_database@`.`days` days
        ON `tmte`.`day_id` = `days`.`id`
    WHERE tmtet.id IS NULL
) as x);


INSERT INTO `@target_database@`.`time_entries` (
	`created`,
	`modified`,
	`developer_id`,
	`did_alias`,
	`project_id`,
	`description`,
	`time`,
	`hour_type_id`,
	`dev_status`,
	`adm_status`
    )
SELECT
	`tdmtp`.`created`,
	`tdmtp`.`modified`,
	`tdmtp`.`developer_id`,
	`tdmtp`.`did_alias`,
	`tdmtp`.`pid` `project_id`,
	`tdmtp`.`description`,
	`tdmtp`.`time`,
	`tdmtp`.`hour_type_id`,
	`tdmtp`.`dev_status`,
	`tdmtp`.`adm_status`
FROM  `timetracker_downgrade_migration_temp`.`time_entries` tdmtp 
LEFT JOIN `@source_live@`.`projects` tlp  
    ON tdmtp.id = tlp.id 
WHERE  (tlp.id IS NULL) AND `tdmtp`.`created` > "@start_date@";
