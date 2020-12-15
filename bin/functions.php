<?php

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
require_once $_SERVER['DOCUMENT_ROOT'] . '/bin/Migration.php';
require_once $_SERVER['DOCUMENT_ROOT'] . '/bin/DowngradeMigration.php';

function renderPage($templateName, $pageData) {

    $loader = new Twig_Loader_Filesystem($_SERVER['DOCUMENT_ROOT'] . '/bin/templates');

    $twig = new Twig_Environment($loader, [
//        'cache' => $_SERVER['DOCUMENT_ROOT'] . '/cache',
    ]);


    $template = $twig->loadTemplate($templateName);

    return $template->render($pageData);
}

function getConfig($filename) {
    $config = include $filename;
    return $config;
}

function updateConfig($filename, array $config) {
    $config = var_export($config, true);
    file_put_contents($filename, "<?php return $config ;");
}

function getMysqlConnection($config) {
    return mysqli_connect($config['DB_HOST'], $config['DB_USERNAME'], $config['DB_PASSWORD']);
}

function migrate() {
    $migration = new Migration();
    $migration->run();
}
function migrate_down($stage) {
    $migration = new DowngradeMigration($stage);
    $migration->run();
}
