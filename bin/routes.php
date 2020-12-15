<?php

error_reporting(E_ALL);
ini_set('display_errors', 1);

if (file_exists($_SERVER['DOCUMENT_ROOT'] . '/vendor/autoload.php')) {
    require_once $_SERVER['DOCUMENT_ROOT'] . '/vendor/autoload.php';
}
require_once 'functions.php';

$action = filter_input(INPUT_GET, 'action', FILTER_SANITIZE_SPECIAL_CHARS);
$param = filter_input(INPUT_GET, 'param', FILTER_SANITIZE_SPECIAL_CHARS);

switch ($action) {
    case 'config':
        if (!empty($_POST)) {
            updateConfig('../mtool_conf.php', $_POST);
        }
        $pageData = ['params' => getConfig('../mtool_conf.php')];
        echo renderPage('config.html', $pageData);

        break;

    case 'migrate':
        $config = getConfig('../mtool_conf.php');
        $pageData = [
            'source' => $config['DB_SOURCE'],
            'target' => $config['DB_TARGET'],
        ];
        echo renderPage('migrate.html', $pageData);
        break;
    case 'migrate_down':
        $config = getConfig('../mtool_conf.php');
        $pageData = [
            'source' => $config['DB_SOURCE_DOWNGRADE'],
            'target' => $config['DB_TARGET_DOWNGRADE'],
            'start_date' => $config['MIGRATION_DATE'],
        ];
        echo renderPage('migrate_down.html', $pageData);
        break;
    case 'migrate_start':
        migrate();
        break;
    case 'migrate_downgrade_start':
        migrate_down($param);
        break;
    default:
        break;
}