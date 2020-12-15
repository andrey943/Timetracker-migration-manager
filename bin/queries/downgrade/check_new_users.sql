    SELECT
        IF (`tmu`.`company_name` = '' OR `tmu`.`company_name` IS NULL, CONCAT(`tmu`.`last_name`, ' ', `tmu`.`first_name`), `tmu`.`company_name`) `name`,
        `tmu`.`email` `email`,
        `tmu`.`password`,
        `tmu`.`created_at` `created`, 
        `tmu`.`updated_at` `modified`,
        `tmu`.`last_visit`,
        IF (`tmu`.`user_type_id`='2', 'developer', IF (`tmu`.`user_type_id`='3', 'client', '')) `role`,
        IF (`tmu`.`is_active`='1', 'active', 'hidden') `status`,
        `tmu`.`id` uuid
    FROM  `@source_database@`.`users` tmu 
    LEFT JOIN `@source_database@`.`users_temp` tmtu  
        ON tmtu.uuid = tmu.id 
    WHERE tmu.id != '1'
        AND tmtu.name IS NULL;