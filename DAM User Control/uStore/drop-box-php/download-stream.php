<?php

set_time_limit(86400);
ini_set('max_execution_time', 86400);
ini_set('memory_limit', '2048M');

header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
header("Cache-Control: no-store, no-cache, must-revalidate");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

require_once "bootstrap.php";

if (!isset($access_token)) {
    header("Location: authorize.php");
    exit;
}

try {
    // Start a new Dropbox session
    // The access token should exist
    // The session should verify if the token is valid and throw an exception
    $session = new DropboxSession(
        $config["dropbox"]["app_key"], 
        $config["dropbox"]["app_secret"], 
        $config["dropbox"]["access_type"], 
        $access_token
    );
    $client = new DropboxClient($session);

    $path = (!empty($_GET["path"])) ? $_GET["path"] : "/test.png";
    $dest = $config["app"]["datadir"] . "/" . basename($path);
    $forceDownload = (isset($_GET["dl"])) ? $_GET["dl"] : "1";

    // Download a file
    //dont save the file
    $dest = null;
    if ($file = $client->getFile($path, $dest)) 
    {
        $pathParts = explode("/", $path);
        $filePath = $pathParts[count($pathParts)-1];
        
        if (!empty($dest)) {
            unset($file["data"]);
            echo "<p>File saved to: <code>" . $dest . "</code></p>";
            echo "<pre>" . print_r($file, true) . "</pre>";
        }
        else {
            header("Content-type: " . $file["mime"]);
            if($forceDownload == "1")
                header('Content-Disposition: attachment; filename="'.$filePath.'"');
            echo $file["data"];
            exit;
        }
    }
}
catch (Exception $e) {
    echo "<strong>ERROR (" . $e->getCode() . ")</strong>: " . $e->getMessage();
    if ($e->getCode() == 401) {
        // Remove auth file
		$authfile = $config["app"]["authfile"];
		chown($authfile, 666);
        unlink($authfile);
        // Re auth
        echo '<p><a href="authorize.php">Click Here to re-authenticate</a></p>';
    }
}
