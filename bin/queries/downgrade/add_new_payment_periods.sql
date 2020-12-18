
INSERT INTO `timetracker_downgrade_migration_temp`.`payment_periods` 
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
        `spp`.`id`,
        `spp`.`created_at`,
        `spp`.`updated_at`,
        `spp`.`user_id`,
        `spp`.`start_date`,
        `spp`.`end_date`,
        `sut`.`id` `uid`,
        IF (`spp`.`end_date` = `gtbl`.`last_date`, 'yes', 'no') `is_last_closed`
    FROM `@source_database@`.`payment_periods` spp
        JOIN `@source_database@`.`users_temp` sut
            ON `spp`.`user_id` = `sut`.`uuid`
        LEFT JOIN (
            SELECT `gip`.`user_id`, MAX(`gip`.`end_date`) last_date 
            FROM `@source_database@`.`payment_periods` gip 
            GROUP BY `gip`.`user_id`) AS gtbl ON spp.user_id = gtbl.user_id
) AS tbl
);

INSERT INTO `@target_database@`.`payment_periods` (
	`start_date`,
	`end_date`,
	`uid`,
	`is_last_closed`
    )
SELECT
    `tdpp`.`start_date`,
    `tdpp`.`end_date`,
    `tdpp`.`uid`,
    `tdpp`.`is_last_closed`
FROM  `timetracker_downgrade_migration_temp`.`payment_periods` tdpp 
WHERE `tdpp`.`created_at` > "@start_date@";
