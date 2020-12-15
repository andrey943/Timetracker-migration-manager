<?php

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of Migration
 *
 * @author avasylchenko
 * 
 * 
 */
require_once 'functions.php';

class DowngradeMigration {

    private $log = [];
    private $config;
    private $stage;

    public function __construct($stage) {
        $this->stage = $stage;
        $this->config = $this->getConfig('../mtool_conf.php');
        try {
            $this->dropDatabase($this->config['DB_TARGET_DOWNGRADE']);
            $this->createDatabase($this->config['DB_TARGET_DOWNGRADE']);
            $this->dropDatabase('timetracker_downgrade_migration_temp');
            $this->createDatabase('timetracker_downgrade_migration_temp');
            $this->createLog();
        } catch (Exception $exc) {
            echo $exc->getTraceAsString();
        }
    }

    private function dropDatabase($dbName) {

        $sql = "DROP DATABASE IF EXISTS $dbName;";

        return $this->executeQuery($sql);
    }

    private function createDatabase($dbName) {

        $sql = "CREATE DATABASE IF NOT EXISTS $dbName;";

        return $this->executeQuery($sql);
    }

    public function run() {
//        $this->createVocabularies();
        $this->importUsers();
        $this->importProjects();
        $this->importHourTypes();
        $this->importProjectsRelationships();
//        $this->importInvoicePeriods();
//        $this->importPaymentPeriods();
//        $this->importAliases();
        $this->importTimeEntries();
//        $this->importUsersHoursTypes();
//        $this->importSkippedDates();
//        $this->createAdmin();
    }

    private function getConnection() {

        if (!$connect = mysqli_connect($this->config['DB_HOST'], $this->config['DB_USERNAME'], $this->config['DB_PASSWORD'])) {
            echo "Failed to connect to MySQL: ", mysqli_connect_error();
        }

        return $connect;
    }

    private function executeQuery($sql) {

        $connection = $this->getConnection();

        return mysqli_query($connection, $sql);
    }

    private function executeFileQuery($fileName) {

        $connection = $this->getConnection();
        $output = [];
        $sqlTemplate = file_get_contents("queries/downgrade/$fileName");
        $sqlTemplate = str_replace("@start_date@", $this->config['MIGRATION_DATE'], $sqlTemplate);
        $sqlTemplate = str_replace("@source_live@", $this->config['DB_LIVE_SOURCE'], $sqlTemplate);
        $sqlTemplate = str_replace("@source_database@", $this->config['DB_SOURCE_DOWNGRADE'], $sqlTemplate);
        $sql = str_replace("@target_database@", $this->config['DB_TARGET_DOWNGRADE'], $sqlTemplate);

        mysqli_multi_query($connection, $sql) or die("Mysql error: " . mysqli_error($connection));
        do {
            if ($result = mysqli_use_result($connection)) {
                while ($row = mysqli_fetch_row($result)) {
                    $output[] = $row;
                }
                mysqli_free_result($result);
            }
        } while (mysqli_more_results($connection) && mysqli_next_result($connection));
        if (mysqli_error($connection)) {
            echo $fileName . PHP_EOL;
            die(mysqli_error($connection));
        }

        return $output;
    }

    private function getConfig($filename) {

        $config = include $filename;

        return $config;
    }

    private function createVocabularies() {

        return $this->executeFileQuery('vocabularies_creation.sql');
    }

    private function importUsers() {

        $this->executeFileQuery('users_migration.sql');

        if ($newUsers = $this->checkNewUsers()) {
            $pageData = [
                'users' => $newUsers,
                'source' => $this->config['DB_SOURCE_DOWNGRADE'],
                'target' => $this->config['DB_TARGET_DOWNGRADE'],
            ];
            echo renderPage('users_list.html', $pageData);
            $this->addNewUsers();
        }
    }

    private function checkNewUsers() {

        return $this->executeFileQuery('check_new_users.sql');
    }

    private function addNewUsers() {

        return $this->executeFileQuery('add_new_users.sql');
    }

    private function importHourTypes() {

        $this->executeFileQuery('htypes_migration.sql');

        if ($newHourTypes = $this->checkNewHourTypes()) {
            $pageData = [
                'htypes' => $newHourTypes,
                'source' => $this->config['DB_SOURCE_DOWNGRADE'],
                'target' => $this->config['DB_TARGET_DOWNGRADE'],
            ];
            echo renderPage('htypes_list.html', $pageData);
            $this->addNewHourTypes();
        }
    }

    private function checkNewHourTypes() {

        return $this->executeFileQuery('check_new_htypes.sql');
    }

    private function addNewHourTypes() {

        return $this->executeFileQuery('add_new_htypes.sql');
    }

    private function importProjects() {

        $this->executeFileQuery('projects_migration.sql');

        if ($newProjects = $this->checkNewProjects()) {
            $pageData = [
                'projects' => $newProjects,
                'source' => $this->config['DB_SOURCE_DOWNGRADE'],
                'target' => $this->config['DB_TARGET_DOWNGRADE'],
            ];
            echo renderPage('projects_list.html', $pageData);
            $this->addNewProjects();
        }
    }

    private function checkNewProjects() {

        return $this->executeFileQuery('check_new_projects.sql');
    }

    private function addNewProjects() {

        return $this->executeFileQuery('add_new_projects.sql');
    }

    private function createLog() {

        return $this->executeFileQuery('create_log.sql');
    }

    private function importProjectsRelationships() {

        $this->executeFileQuery('projects_relationships_migration.sql');

        if ($newProjectsRelationships = $this->checkNewProjectsRelationships()) {
            $pageData = [
                'rels' => $newProjectsRelationships,
                'source' => $this->config['DB_SOURCE_DOWNGRADE'],
                'target' => $this->config['DB_TARGET_DOWNGRADE'],
            ];
            echo renderPage('projects_relationships_list.html', $pageData);
            //$this->addNewProjectsRelationships();
        }
    }

    private function checkNewProjectsRelationships() {

        return $this->executeFileQuery('check_new_projects_relationships.sql');
    }

    private function addNewProjectsRelationships() {

        return $this->executeFileQuery('add_new_projects_relationships.sql');
    }

    private function importInvoicePeriods() {

        return $this->executeFileQuery('invoice_periods_migration.sql');
    }

    private function importPaymentPeriods() {

        return $this->executeFileQuery('payment_periods_migration.sql');
    }

    private function importAliases() {

        return $this->executeFileQuery('aliases_migration.sql');
    }

    private function importTimeEntries() {

        $this->executeFileQuery('timeentries_migration.sql');

        if ($newEntries = $this->checkNewEntries()) {
            $pageData = [
                'time_entries' => $newEntries,
                'source' => $this->config['DB_SOURCE_DOWNGRADE'],
                'target' => $this->config['DB_TARGET_DOWNGRADE'],
            ];
            echo renderPage('time_entries_list.html', $pageData);
            $this->addNewEntries();
        }
    }

    private function checkNewEntries() {

        return $this->executeFileQuery('check_new_timeentries.sql');
    }

    private function addNewEntries() {

        return $this->executeFileQuery('add_new_timeentries.sql');
    }

    private function importUsersHoursTypes() {

        return $this->executeFileQuery('hour_types_migration.sql');
    }

    private function importSkippedDates() {

        return $this->executeFileQuery('skipped_dates_migration.sql');
    }

    private function createAdmin() {

        $connection = $this->getConnection();
        $sqlTemplate = file_get_contents("queries/admin_creation.sql");
        $sqlTemplate = str_replace("@source_database@", $this->config['DB_SOURCE_DOWNGRADE'], $sqlTemplate);
        $sqlTemplate = str_replace("@target_database@", $this->config['DB_TARGET_DOWNGRADE'], $sqlTemplate);
        $sqlTemplate = str_replace("@admin_name@", $this->config['ADMIN_NAME'], $sqlTemplate);
        $sqlTemplate = str_replace("@admin_login@", $this->config['ADMIN_LOGIN'], $sqlTemplate);
        $sqlTemplate = str_replace("@admin_email@", $this->config['ADMIN_EMAIL'], $sqlTemplate);
        $sql = str_replace("@admin_pass@", password_hash($this->config['ADMIN_PASS'], PASSWORD_BCRYPT), $sqlTemplate);

        if (!$result = mysqli_multi_query($connection, $sql)) {
            exit(mysqli_error($connection));
        }

        return $result;
    }

}
