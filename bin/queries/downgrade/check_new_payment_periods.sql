SELECT
    `sut`.`name`,
    `pp`.`start_date`, 
    `pp`.`end_date`
FROM `@source_database@`.`payment_periods` pp
        JOIN `@source_database@`.`users_temp` sut
            ON `pp`.`user_id` = `sut`.`uuid`
WHERE `pp`.`created_at` > "@start_date@";