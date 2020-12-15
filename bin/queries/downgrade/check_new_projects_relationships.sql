SELECT 
    `tp`.`name` `project_name`,
    `tu`.`name` `user_name`,
    `aliases`.`name` `alias_name`
FROM `@source_database@`.`project_user` pu 
    JOIN `timetracker_downgrade_migration_temp`.`projects` tp ON `pu`.`project_id` = `tp`.`uuid`
    JOIN `timetracker_downgrade_migration_temp`.`users` tu ON `pu`.`user_id` = `tu`.`uuid`
    LEFT JOIN `@source_database@`.`user_aliases` ua 
        ON `ua`.`project_id` = `pu`.`project_id` 
        AND `ua`.`user_id` = `pu`.`user_id`
    LEFT JOIN `timetracker_downgrade_migration_temp`.`users` aliases ON `aliases`.`uuid` = `ua`.`alias_id`
WHERE `pu`.`created_at` > "@start_date@" OR `ua`.`created_at` > "@start_date@"
UNION
SELECT 
    `tp`.`name` `project_name`,
    `tu`.`name` `user_name`,
    '' `alias_name`
FROM `@source_database@`.`project_pm` pu 
    JOIN `timetracker_downgrade_migration_temp`.`projects` tp ON `pu`.`project_id` = `tp`.`uuid`
    JOIN `timetracker_downgrade_migration_temp`.`users` tu ON `pu`.`user_id` = `tu`.`uuid`
WHERE `pu`.`created_at` > "@start_date@";