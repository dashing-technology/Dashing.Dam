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
    $dest = $config["app"]["datadir"] . "/" . basename($path);
    $forceDownload = (isset($_GET["dl"])) ? $_GET["dl"] : "1";

    // Download a file
    //dont save the file
	
	$cheaders = array('Authorization:Bearer sKK1-7GZkwQAAAAAAABFcAIrwEBKrtg3LCJKHy0ndMypX2CXB7lfz6tx55D0AeMj',
						  'Content-Type: application/json');
	
	$data = array("path" =>$path, "settings" => array("requested_visibility"=>"public"));                                                                    
	$data_string = json_encode($data);	
	
	$ch = curl_init('https://api.dropboxapi.com/2/sharing/create_shared_link_with_settings');
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
		if($jsonResponse == null || !isset($jsonResponse->url) )
		{
			$tag = ".tag";
			if( isset($jsonResponse->error) 
				&& isset($jsonResponse->error->$tag) 
			&& $jsonResponse->error->$tag == "shared_link_already_exists" )
			{
				$cheaders = array('Authorization:Bearer sKK1-7GZkwQAAAAAAABFcAIrwEBKrtg3LCJKHy0ndMypX2CXB7lfz6tx55D0AeMj',
						  'Content-Type: application/json');
	
				$data = array("path" =>$path);                                                                    
				$data_string = json_encode($data);
				
				$ch = curl_init('https://api.dropboxapi.com/2/sharing/list_shared_links');
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
					if($jsonResponse == null || !isset($jsonResponse->links) || count($jsonResponse->links) <1 )
					{
						throw new Exception("Failed to upload file code:6");
					}
					
					$jsonResponse->url = $jsonResponse->links[0]->url;
				}
			}
			else
				throw new Exception("Failed to upload file code:5");
		}
		
		if($forceDownload)
			$jsonResponse->url = str_replace ("dl=0" ,"dl=1" ,$jsonResponse->url);
		else
			$jsonResponse->url = str_replace ("dl=1" ,"dl=0" ,$jsonResponse->url);
		
		header("Location: ".$jsonResponse->url);
	}
}
catch (Exception $e) {
    echo "<strong>ERROR (" . $e->getCode() . ")</strong>: " . $e->getMessage();
}
