<?php

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
require_once 'functions.php';
/**
 * Description of Migration
 *
 * @author avasylchenko
 */
class Migration {

    private $log = [];
    private $config;
    const CONFIG_PATH = '../mtool_conf.php';

    public function __construct() {
        $this->config = $this->getConfig(self::CONFIG_PATH);
        try {
            $this->dropDatabase($this->config['DB_TARGET']);
            $this->createDatabase($this->config['DB_TARGET']);
            $this->dropDatabase('timetracker_migration_temp');
            $this->createDatabase('timetracker_migration_temp');
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
        $this->createVocabularies();
        $this->importUsers();
        $this->importProjects();
        $this->importProjectsRelationships();
        $this->importInvoicePeriods();
        $this->importPaymentPeriods();
        $this->importAliases();
        $this->importTimeEntries();
        $this->importUsersHoursTypes();
        $this->importSkippedDates();
        $this->createAdmin();
        $this->copyTestDatabase();
        $this->saveMigrationDate();
        
        echo 'Migration successfully finished.'; 
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
        $sqlTemplate = file_get_contents("queries/migrate/$fileName");
        $sqlTemplate = str_replace("@source_database@", $this->config['DB_SOURCE'], $sqlTemplate);
        $sql = str_replace("@target_database@", $this->config['DB_TARGET'], $sqlTemplate);

//        if (!$result = mysqli_multi_query($connection, $sql)) {
//            exit(mysqli_error($connection));
//        }
        mysqli_multi_query($connection, $sql) or die("Mysql error: " . mysqli_error($connection));
        do {
            if ($result = mysqli_store_result($connection)) {
                mysqli_free_result($result);
            }
        } while (mysqli_more_results($connection) && mysqli_next_result($connection));
        if (mysqli_error($connection)) {
            echo $fileName . PHP_EOL;
            die(mysqli_error($connection));
        }

        return $result;
    }

    private function getConfig($filename) {

        $config = include $filename;

        return $config;
    }

    private function createVocabularies() {

        return $this->executeFileQuery('vocabularies_creation.sql');
    }

    private function importUsers() {

        return $this->executeFileQuery('users_migration.sql');
    }

    private function importProjects() {

        return $this->executeFileQuery('projects_migration.sql');
    }

    private function importProjectsRelationships() {

        return $this->executeFileQuery('projects_relationships_migration.sql');
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

        return $this->executeFileQuery('time_entries_migration.sql');
    }

    private function importUsersHoursTypes() {

        return $this->executeFileQuery('hour_types_migration.sql');
    }

    private function importSkippedDates() {
        
        return $this->executeFileQuery('skipped_dates_migration.sql');
    }

    private function copyTestDatabase() {
        
        return $this->executeFileQuery('save_temp_tables.sql');
    }

    private function saveMigrationDate() {
        
        $this->config['MIGRATION_DATE'] = gmdate('Y-m-d H:i:s');
        updateConfig(self::CONFIG_PATH, $this->config);
    }    
    private function createAdmin() {

        $connection = $this->getConnection();
        $sqlTemplate = file_get_contents("queries/migrate/admin_creation.sql");
        $sqlTemplate = str_replace("@source_database@", $this->config['DB_SOURCE'], $sqlTemplate);
        $sqlTemplate = str_replace("@target_database@", $this->config['DB_TARGET'], $sqlTemplate);
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
