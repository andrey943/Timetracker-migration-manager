INSERT INTO `@target_database@`.`users`(
    `id`,
    `name`,
    `email`,
    `password`,
    `created_at`,
    `updated_at`,
    `last_visit`,
    `is_admin`,
    `remember_token`,
    `email_verified_at`,
    `is_active`,
    `user_type_id`,
    `first_name`,
    `last_name`,
    `company_name`,
    `login`,
    `auto_close`,
    `is_pm`,
    `is_short_day_allowed`
) VALUES (
    '1',
    '@admin_name@',
    '@admin_email@',
--     '$2y$10$Tv.XPQAtKgZxW9ExDfCOJ.te4GnCMaomJDQ.n/QGijxx85s0cOv2u',
    '@admin_pass@',
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP(),
    1,
    NULL,
    NULL,
    1,
    '4',
    '@admin_name@',
    '',
    '',
    'admin',
    0,
    0,
    0
 );