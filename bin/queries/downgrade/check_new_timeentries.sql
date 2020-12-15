SELECT
    `days`.`accounting_date`,
    CONCAT(`users`.`last_name`, ' ', `users`.`first_name`) `user_name`, 
    `projects`.`name` `project_name`,
    `tmte`.`time_spent` time_spent
FROM  `@source_database@`.`time_entries` tmte
LEFT JOIN `@source_database@`.`projects` projects
    ON `tmte`.`project_id` = `projects`.`id`
LEFT JOIN `@source_database@`.`users` users
    ON `tmte`.`user_id` = `users`.`id`
LEFT JOIN `@source_database@`.`days` days
    ON `tmte`.`day_id` = `days`.`id`
LEFT JOIN `@source_database@`.`time_entries_temp` tmtte
    ON tmtte.uuid = tmte.id 
WHERE tmtte.id IS NULL