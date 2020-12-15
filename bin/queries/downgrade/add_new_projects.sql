INSERT INTO `timetracker_downgrade_migration_temp`.`projects` ( 
	`name`,
	`created`,
	`modified`,
	`status`,
        `uuid`
    )
(SELECT * FROM (
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
) as x);


INSERT INTO `@target_database@`.`projects` (
        `id`,
	`name`,
	`created`,
	`modified`,
	`status`
    )
SELECT
        `tdmtp`.`id`,
	`tdmtp`.`name`,
	`tdmtp`.`created`,
	`tdmtp`.`modified`,
	`tdmtp`.`status`
FROM  `timetracker_downgrade_migration_temp`.`projects` tdmtp 
LEFT JOIN `@source_live@`.`projects` tlp  
    ON tdmtp.id = tlp.id 
WHERE  (tlp.id IS NULL) 
    AND `tdmtp`.`created` > "@start_date@"
    AND `tdmtp`.`status` = 'active';
