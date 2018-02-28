<?php
// Prevent calling this script directly
if ($_SERVER["SCRIPT_FILENAME"] == __FILE__) {
    exit("Access denied!");
}

header("Access-Control-Allow-Origin: http://eezeeorder.com.au");

if( !isset($_GET["tk"]) || $_GET["tk"] != "d098lkLKHJg903kjh3liO78Go2s0987sgd8gq1IUY21kI9g" )
    die();

// app settings
$config = array();
$config["dropbox"]["app_key"] = "ihvp6c4qb21jzyr";
$config["dropbox"]["app_secret"] = "bo9ff10wvxhco8c";
// ACCESS_TYPE should be "dropbox" or "app_folder"
$config["dropbox"]["access_type"] = "dropbox";

$config["app"]["root"] = "http://" . $_SERVER["HTTP_HOST"] . "/drop-box-php/";
$config["app"]["datadir"] = "C:\\Web-Applications\\drop-box-php\\data";
$config["app"]["authfile"] = $config["app"]["datadir"] . "/auth.php";

// environment check
if (!is_dir($config["app"]["datadir"]) || !is_writable($config["app"]["datadir"])) {
    exit("The data directory is not writeable!");
}
if (file_exists($config["app"]["authfile"]) && !is_writable($config["app"]["authfile"])) {
    exit("The auth storage file is not writeable!");
}

// Load libraries and start a new session
require_once "lib/dropbox/rest.php";
require_once "lib/dropbox/session.php";
require_once "lib/dropbox/client.php";

session_start();

// Search for a previously obtained access token
$access_token = null;
if (file_exists($config["app"]["authfile"])) {
    include_once $config["app"]["authfile"];
}
