<?php

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
    $rev = (!empty($_GET["rev"])) ? $_GET["rev"] : "";

    
    if ( $file = $client->preview($path,$rev) ) 
    {
        header("Content-type: " . $file["mime"]);
        echo $file["data"];
        exit;
    }
}
catch (Exception $e) 
{
    echo "<strong>Preview unavailable for this file type.</strong>";
    
    /*echo "<strong>ERROR (" . $e->getCode() . ")</strong>: " . $e->getMessage();
    if ($e->getCode() == 401) {
        // Remove auth file
        unlink($config["app"]["authfile"]);
        // Re auth
        echo '<p><a href="authorize.php">Click Here to re-authenticate</a></p>';
    }*/
}
