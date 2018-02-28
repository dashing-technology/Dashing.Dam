<?php

require_once "bootstrap.php";

if (!isset($access_token)) {
    header("Location: authorize.php");
    exit;
}

try {
    // Start a new Dropbox session
    // The access token should be defined
    // The session should verify if the token is valid and throw an exception
    $session = new DropboxSession(
        $config["dropbox"]["app_key"], 
        $config["dropbox"]["app_secret"], 
        $config["dropbox"]["access_type"], 
        $access_token
    );
    $client = new DropboxClient($session);

    $path = (!empty($_GET["path"])) ? $_GET["path"] : null;
    
    $newPath = (!empty($_GET["newPath"])) ? $_GET["newPath"] : null;
    
    if($path == null || $newPath == null) throw new Exception("Path Missing");
    
	$cheaders = array('Authorization:Bearer sKK1-7GZkwQAAAAAAABFcAIrwEBKrtg3LCJKHy0ndMypX2CXB7lfz6tx55D0AeMj',
					  'Content-Type: application/json');
	$path = urldecode($path);
	$newPath = urldecode($newPath);
	$data = array("from_path" =>$path,"to_path"=>$newPath);                                                                    
	$data_string = json_encode($data);	

	$ch = curl_init('https://api.dropboxapi.com/2/files/move_v2');
	curl_setopt($ch, CURLOPT_HTTPHEADER, $cheaders);
	curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");                                                                     
	curl_setopt($ch, CURLOPT_POSTFIELDS, $data_string);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
	curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 18000);
	curl_setopt($ch, CURLOPT_TIMEOUT, 18000 );
	$response = curl_exec($ch);

	curl_close($ch);
	
	if( $response )
	{
		$jsonResponse = json_decode($response);
		if($jsonResponse != null && isset($jsonResponse->metadata) )
		{
			echo json_encode( array("respone"=>"1") );
		}
		else
			throw new Exception("Failed to rename file code:5");
	}
	else
		throw new Exception("Failed to rename file code:6");
}
catch (Exception $e) {
    echo json_encode( array("ERROR"=>"0") );
    //echo "<strong>ERROR (" . $e->getCode() . ")</strong>: " . $e->getMessage();
    /*echo "<strong>ERROR (" . $e->getCode() . ")</strong>: " . $e->getMessage();
    if ($e->getCode() == 401) {
        // Remove auth file
        unlink($config["app"]["authfile"]);
        // Re auth
        echo '<p><a href="authorize.php">Click Here to re-authenticate</a></p>';
    }*/
}

