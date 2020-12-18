SELECT
    `sut`.`name`,
    `ip`.`start_date`, 
    `ip`.`end_date`
FROM `@source_database@`.`invoice_periods` ip
        JOIN `@source_database@`.`users_temp` sut
            ON `ip`.`user_id` = `sut`.`uuid`
WHERE `ip`.`created_at` > "@start_date@";