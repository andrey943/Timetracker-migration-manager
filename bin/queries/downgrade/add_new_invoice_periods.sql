
INSERT INTO `timetracker_downgrade_migration_temp`.`invoice_periods` 
(
	`id`,
	`created_at`,
	`updated_at`,
        `user_id`,
	`start_date`,
	`end_date`,
	`uid`,
	`is_last_closed`
)
(SELECT * FROM (
    SELECT 
        `sip`.`id`,
        `sip`.`created_at`,
        `sip`.`updated_at`,
        `sip`.`user_id`,
        `sip`.`start_date`,
        `sip`.`end_date`,
        `sut`.`id` `uid`,
        IF (`sip`.`end_date` = `gtbl`.`last_date`, 'yes', 'no') `is_last_closed`
    FROM `@source_database@`.`invoice_periods` sip
        JOIN `@source_database@`.`users_temp` sut
            ON `sip`.`user_id` = `sut`.`uuid`
        LEFT JOIN (
            SELECT `gip`.`user_id`, MAX(`gip`.`end_date`) last_date 
            FROM `@source_database@`.`invoice_periods` gip 
            GROUP BY `gip`.`user_id`) AS gtbl ON sip.user_id = gtbl.user_id
) AS tbl
);

INSERT INTO `@target_database@`.`invoice_periods` (
	`start_date`,
	`end_date`,
	`uid`,
	`is_last_closed`
    )
SELECT
    `tdip`.`start_date`,
    `tdip`.`end_date`,
    `tdip`.`uid`,
    `tdip`.`is_last_closed`
FROM  `timetracker_downgrade_migration_temp`.`invoice_periods` tdip 
WHERE `tdip`.`created_at` > "@start_date@";
