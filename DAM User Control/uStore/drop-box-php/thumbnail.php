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

    
        //header("Content-type: " . $file["mime"]);
        //echo $file["data"];
        //exit;
		
		$cheaders = array('Authorization:Bearer sKK1-7GZkwQAAAAAAABFcAIrwEBKrtg3LCJKHy0ndMypX2CXB7lfz6tx55D0AeMj',
					  'Content-Type: text/plain'
					  ,'Dropbox-API-Arg: {"path":"'.$path.'"}');

		//$data = array("path" =>$path);                                                                    
		//$data_string = json_encode($data);	

		$ch = curl_init('https://content.dropboxapi.com/2/files/get_thumbnail');
		curl_setopt($ch, CURLOPT_HTTPHEADER, $cheaders);
		//curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");                                                                     
		//curl_setopt($ch, CURLOPT_POSTFIELDS, $data_string);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
		curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 18000);
		curl_setopt($ch, CURLOPT_TIMEOUT, 18000 );
		$response = curl_exec($ch);

		curl_close($ch);
		
		if( $response )
		{
			header("Content-type: image/jpeg");
			echo $response;
			exit;
		}
		else
					throw new Exception("Failed to thumbnail list code:6");
}
catch (Exception $e) {
    echo "<strong>ERROR (" . $e->getCode() . ")</strong>: " . $e->getMessage();
    if ($e->getCode() == 401) {
        // Remove auth file
        unlink($config["app"]["authfile"]);
        // Re auth
        echo '<p><a href="authorize.php">Click Here to re-authenticate</a></p>';
    }
}
