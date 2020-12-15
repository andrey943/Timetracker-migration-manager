SELECT
    `tmp`.`name`,
    `tmp`.`created_at` `created`, 
    `tmp`.`updated_at` `modified`
FROM  `@source_database@`.`hour_types` tmp
LEFT JOIN `@source_database@`.`hour_types_temp` tmtp  
    ON tmtp.uuid = tmp.id 
WHERE tmtp.name IS NULL