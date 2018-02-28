<?php

header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
header("Cache-Control: no-store, no-cache, must-revalidate");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

require_once "bootstrap.php";

function reArrayFiles(&$file_post) {

    $file_ary = array();
    $file_count = count($file_post['name']);
    $file_keys = array_keys($file_post);

    for ($i=0; $i<$file_count; $i++) {
        foreach ($file_keys as $key) {
            $file_ary[$i][$key] = $file_post[$key][$i];
        }
    }

    return $file_ary;
}

if (!isset($access_token)) {
    header("Location: authorize.php");
    exit;
}

try 
{
		// Start a new Dropbox session
	// The access token should be passed
	// The session should verify if the token is valid and throw an exception
	$session = new DropboxSession(
		$config["dropbox"]["app_key"], 
		$config["dropbox"]["app_secret"], 
		$config["dropbox"]["access_type"], 
		$access_token
	);
	$arrFiles = reArrayFiles($_FILES['files']);
	$client = new DropboxClient($session);
	$exception = "";
	foreach ($arrFiles as $file) {     

		if(!$_FILES["file"]["error"])
        {
			$src = $file['tmp_name'];

			$path = $_POST["path"]."/".$file['name'];
			$fp = fopen($src, 'rb');
			$size = filesize($src);

			$cheaders = array('Authorization:Bearer sKK1-7GZkwQAAAAAAABFcAIrwEBKrtg3LCJKHy0ndMypX2CXB7lfz6tx55D0AeMj',
							  'Content-Type: application/octet-stream',
							  'Dropbox-API-Arg: {"path":"'.$path.'", "mode":"overwrite"}');

			$ch = curl_init('https://content.dropboxapi.com/2/files/upload');
			curl_setopt($ch, CURLOPT_HTTPHEADER, $cheaders);
			curl_setopt($ch, CURLOPT_PUT, true);
			curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'POST');
			curl_setopt($ch, CURLOPT_INFILE, $fp);
			curl_setopt($ch, CURLOPT_INFILESIZE, $size);
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
			curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
			$response = curl_exec($ch);

			curl_close($ch);
			fclose($fp);
			
			 if( $response )
			{
				$jsonResponse = json_decode($response);
				if($jsonResponse == null || !isset($jsonResponse->client_modified) )
					$exception = $exception . " - ". $file['name']. "Failed to upload file code:4";
			}
			else
				$exception = $exception . " - ". $file['name']. "Failed to upload file code:3";
		}
		else
				$exception = $exception . " - ". $file['name']. "Failed to upload file code:2";
	}

	if( isset($_GET["fromPath"]) )
	{
		header("Location: http://glmcampaign.com.au/drop-box-php/upload-form-from-path.php?t=1");
		die();
	}
	else
	{
		header("Location: http://glmcampaign.com.au/drop-box-php/upload-form.php?t=1");
		die();
	}
}
catch (Exception $e) 
{
    echo "<strong>ERROR (" . $e->getCode() . ")</strong>: " . $e->getMessage();
}
