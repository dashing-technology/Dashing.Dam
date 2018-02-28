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

try 
{
    if( isset($_FILES["file"]) && isset($_POST["path"]) )//accept a raw file stream from the client
    {
        if(!$_FILES["file"]["error"])
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

            $client = new DropboxClient($session);

            $src = $_FILES["file"]["tmp_name"];

            $path = $_POST["path"]."/".$_FILES["file"]["name"];
            
			uploadDropBox($src,$path);
        }
        else
            throw new Exception("Failed to upload file code:2");
    }
    else
        throw new Exception("Failed to upload file code:1");   
}
catch (Exception $e) 
{
    echo "<strong>ERROR (" . $e->getCode() . ")</strong>: " . $e->getMessage();
}

function uploadDropBox($src,$path)
{
	//logEvt("=======START SESSION======");
	//logEvt("Uploading : ".$src." to ".$path);
	
	$chunkSize = 140000;
	$size = filesize($src);
	
	if( $size <= $chunkSize )
	{
		$chunkSize = ceil($size/2);
	}
	
	$fileParts = fsplit($src,sys_get_temp_dir()."\\",$chunkSize);
	//logEvt("File split into chunks - ".var_export($fileParts,true) );
	if( count($fileParts) > 0 )
	{
		$fp = fopen($fileParts[0]->path, 'rb');
		$size = filesize($fileParts[0]->path);

		$cheaders = array('Authorization:Bearer sKK1-7GZkwQAAAAAAABFcAIrwEBKrtg3LCJKHy0ndMypX2CXB7lfz6tx55D0AeMj',
						  'Content-Type: application/octet-stream',
						  'Dropbox-API-Arg: {"close":false}');

		$ch = curl_init('https://content.dropboxapi.com/2/files/upload_session/start');
		curl_setopt($ch, CURLOPT_HTTPHEADER, $cheaders);
		curl_setopt($ch, CURLOPT_PUT, true);
		curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'POST');
		curl_setopt($ch, CURLOPT_INFILE, $fp);
		curl_setopt($ch, CURLOPT_INFILESIZE, $size);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
		curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 18000);
		curl_setopt($ch, CURLOPT_TIMEOUT, 18000 );
		$response = curl_exec($ch);

		curl_close($ch);
		fclose($fp);
		
		if( $response )
		{
			$jsonResponse = json_decode($response);
			if($jsonResponse == null || !isset($jsonResponse->session_id) )
				throw new Exception("Failed to upload file code:5");
			
			$sessionId = $jsonResponse->session_id;
			
			//upload other parts
			$isLast = false;
			for($b=1;$b<count($fileParts);$b++)
			{
				if( (count($fileParts)-1) == $b )
					$isLast = true;
				
				$fp = fopen($fileParts[$b]->path, 'rb');
				$size = filesize($fileParts[$b]->path);

				$cheaders = array('Authorization:Bearer sKK1-7GZkwQAAAAAAABFcAIrwEBKrtg3LCJKHy0ndMypX2CXB7lfz6tx55D0AeMj',
								  'Content-Type: application/octet-stream',
								  'Dropbox-API-Arg: {"cursor": {"session_id": "'.$sessionId.'","offset": '.$fileParts[$b]->offset.'},"close": false}');
				
				if($isLast)
				{
					$cheaders = array('Authorization:Bearer sKK1-7GZkwQAAAAAAABFcAIrwEBKrtg3LCJKHy0ndMypX2CXB7lfz6tx55D0AeMj',
							  'Content-Type: application/octet-stream',
							  'Dropbox-API-Arg: {"cursor": {"session_id": "'.$sessionId.'","offset": '.$fileParts[$b]->offset.'},"commit": {"path": "'.$path.'","mode": "add","autorename": true,"mute": false}}');

				}
				
				$url = 'https://content.dropboxapi.com/2/files/upload_session/append_v2';
				
				if($isLast)
					$url = 'https://content.dropboxapi.com/2/files/upload_session/finish';
				
				$ch = curl_init($url);
				curl_setopt($ch, CURLOPT_HTTPHEADER, $cheaders);
				curl_setopt($ch, CURLOPT_PUT, true);
				curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'POST');
				curl_setopt($ch, CURLOPT_INFILE, $fp);
				curl_setopt($ch, CURLOPT_INFILESIZE, $size);
				curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
				curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
				curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 18000);
				curl_setopt($ch, CURLOPT_TIMEOUT, 18000 );
				$response = curl_exec($ch);

				curl_close($ch);
				fclose($fp);
				
				if( $response )
				{
					if(!$isLast)
					{
						$jsonResponse = json_decode($response);
						if($jsonResponse != null && isset($jsonResponse->error) )
						{
							throw new Exception("Failed to upload file code: 6a");
						}
					}
					else
					{
						$jsonResponse = json_decode($response);
						if($jsonResponse == null || !isset($jsonResponse->client_modified) )
							throw new Exception("Failed to upload file code:7");
					}
				}
				else
					throw new Exception("Failed to upload file code: 6b");
			}
		}
		else
			throw new Exception("Failed to upload file code:5");
	}	
	logEvt("=======END SESSION======");
}

function logEvt($msg)
{
	$fp = fopen("data/debug.log","a");
	fwrite($fp,date("Y-m-d H:i:s").": ".$msg."\n");
	fclose($fp);
}

function fsplit($file,$store_path,$buffer=1024)
{ 
    //open file to read 
    $file_handle = fopen($file,'r'); 
    //get file size 
    $file_size = filesize($file); 
    //no of parts to split 
    $parts = ceil($file_size / $buffer); 
    
    //store all the file names 
    $file_parts = array(); 
    
    //name of input file 
    $file_name = basename($file); 
    
    for($i=0;$i<$parts;$i++)
	{ 
		$filePartObj = new stdClass();
		$filePartObj->offset = ftell($file_handle);
		
        //read buffer sized amount from file 
        $file_part = fread($file_handle, $buffer); 
        //the filename of the part 
        $file_part_path = $store_path.$file_name.".part$i"; 
        //open the new file [create it] to write 
        $file_new = fopen($file_part_path,'w+'); 
        //write the part of file 
        fwrite($file_new, $file_part); 
        //add the name of the file to part list [optional] 
		$filePartObj->path = $file_part_path;
        array_push($file_parts, $filePartObj); 
        //close the part file handle 
        fclose($file_new); 
    }     
    //close the main file handle    
    fclose($file_handle); 
    return $file_parts; 
}  

?>