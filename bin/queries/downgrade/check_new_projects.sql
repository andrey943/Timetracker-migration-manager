SELECT
    `tmp`.`name`,
    `tmp`.`created_at` `created`, 
    `tmp`.`updated_at` `modified`,
    IF (`tmp`.`is_active`='1', 'active', 'hidden') `status`,
    `tmp`.`id` uuid
FROM  `@source_database@`.`projects` tmp
LEFT JOIN `@source_database@`.`projects_temp` tmtp  
    ON tmtp.uuid = tmp.id 
WHERE tmtp.name IS NULL
    AND `tmp`.`is_active` = 1;