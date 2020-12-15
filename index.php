<?php

header('Content-Type: text/html; charset=utf-8');
error_reporting(E_ALL);
ini_set('display_errors', 1);

if (file_exists($_SERVER['DOCUMENT_ROOT'] . '/vendor/autoload.php')) {
    require_once $_SERVER['DOCUMENT_ROOT'] . '/vendor/autoload.php';
}

require_once 'bin/functions.php';

$pageData = [
    'links' => [
        ['title' => 'Config', 'route' => 'config'],
        ['title' => 'Start migration v1 -> v3', 'route' => 'migrate'],
        ['title' => 'Start migration v3 -> v1', 'route' => 'migrate_down'],
        ['title' => 'View Logs', 'route' => 'logs'],
        ['title' => 'Clear Target', 'route' => 'clear_target'],
    ]
];

echo renderPage('main.html', $pageData);
