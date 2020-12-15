INSERT INTO `timetracker_downgrade_migration_temp`.`hour_types` ( 
	`uuid`,
	`name`,
	`created`,
	`modified`,
	`status`,
	`overtime`,
	`predefined`,
	`order`
    )
(SELECT * FROM (
    SELECT
        `tmp`.`id` `uuid`,
        `tmp`.`name`,
        `tmp`.`created_at` `created`, 
        `tmp`.`updated_at` `modified`,
        IF (`tmp`.`is_active`='1', 'active', 'hidden') `status`,
        IF (`tmp`.`is_overtime`='1', 'yes', 'no') `overtime`,
        'no' `predefined`,
        MAX(`tmp`.`item_order`) + 1 `order`
    FROM  `@source_database@`.`hour_types` tmp
    LEFT JOIN `@source_database@`.`hour_types_temp` tmtp  
        ON tmtp.uuid = tmp.id 
    WHERE tmtp.name IS NULL
) as x);


INSERT INTO `@target_database@`.`hour_types` (
        `id`,
	`name`,
	`created`,
	`modified`,
	`status`,
	`overtime`,
	`predefined`,
	`order`
    )
SELECT
        `tdmtp`.`id`,
	`tdmtp`.`name`,
        `tdmtp`.`created`, 
        `tdmtp`.`modified`,
	`tdmtp`.`status`,
	`tdmtp`.`overtime`,
	`tdmtp`.`predefined`,
	`tdmtp`.`order`
FROM  `timetracker_downgrade_migration_temp`.`hour_types` tdmtp 
LEFT JOIN `@source_live@`.`hour_types` tlp  
    ON tdmtp.id = tlp.id 
WHERE  (tlp.id IS NULL) AND `tdmtp`.`created` > "@start_date@";
