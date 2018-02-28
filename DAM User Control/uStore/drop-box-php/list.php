<?php

require_once "bootstrap.php";


require_once 'lib/Config.php';
require_once 'lib/Util.php';
require_once 'lib/SQLBroker.php';

$file = getcwd().DIRECTORY_SEPARATOR."Logs".DIRECTORY_SEPARATOR."Log.txt";

if (!isset($access_token)) {
    header("Location: authorize.php");
    exit;
}

try {
	
	file_put_contents($file, "Here now", FILE_APPEND | LOCK_EX);
	
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

    $path = (!empty($_GET["path"])) ? $_GET["path"] : "/";
	// "file" + $file;
	file_put_contents($file, "List Path - " .  $path, FILE_APPEND | LOCK_EX);
	
	//$path = str_replace(" ","%20",$path);
	//$path = str_replace("'","%27",$path);
	
	$cheaders = array('Authorization:Bearer sKK1-7GZkwQAAAAAAABFcAIrwEBKrtg3LCJKHy0ndMypX2CXB7lfz6tx55D0AeMj',
					  'Content-Type: application/json');

	$data = array("path" =>$path);                                                                    
	$data_string = json_encode($data);	

	$ch = curl_init('https://api.dropboxapi.com/2/files/list_folder');
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
		if($jsonResponse != null && isset($jsonResponse->entries) )
		{
			$referringCat = "";
			$referringUrlParts = explode("/",$_SERVER['HTTP_REFERER']);
			
			foreach($referringUrlParts as $key => $referringUrlPart)
			{
				if($referringUrlPart == "Category")
				{
					$referringCat = $referringUrlParts[$key+1];
				}
			}
			
			$home = array();
			$home["contents"] = $jsonResponse->entries;
			
			foreach($home["contents"] as $key => $content)
			{
				$home["contents"][$key] =  (array) $home["contents"][$key];
				
				$descID = "";
				$home["contents"][$key]["path"] = $home["contents"][$key]["path_display"];
				$pathParts = explode("/", $home["contents"][$key]["path"]);
				$filePath = $pathParts[count($pathParts)-1];
				
			   $home["contents"][$key]["fileName"] = $filePath;
				
				$link =  "//$_SERVER[HTTP_HOST]/drop-box-php";
				$escaped_link = htmlspecialchars($link, ENT_QUOTES, 'UTF-8');
				$thumbDwnldLink = $escaped_link."/images/generic-document.jpg";
				
				$home["contents"][$key]["desc"] = "";
				
				$sqlResult = SQLBroker::getSQLConnection()->selectQuery(
				"SELECT [dropBoxFileDescId]
					  ,[fileName]
					  ,[catId]
					  ,[fileDesc]
				  FROM [GLD-Xmpie-EXT].[dbo].[DropBox-File-Desc]
				  WHERE [fileName] = '".Util::stripChar($home["contents"][$key]["fileName"],"'")."'
				  AND catId = ".(int)$referringCat);
				
				if( is_array($sqlResult) && count($sqlResult) > 0 )
				{
					$home["contents"][$key]["desc"] = "<span class='dropBoxFileDescId' id='dropBoxFileDescId-".$sqlResult[0]->dropBoxFileDescId."'>".$sqlResult[0]->fileDesc."</span><br>";
					$descID = $sqlResult[0]->dropBoxFileDescId;
				}
				 
				if( !isset($home["contents"][$key]["mime_type"]) )
				{
					$home["contents"][$key]["mime_type"] = "";
				}
				
				//if( $home["contents"][$key]["mime_type"] == "application/pdf"
				//    || preg_match ("/image\//",$home["contents"][$key]["mime_type"],$matches) )
			   // {
					$previewLink = $escaped_link."/download.php?tk=d098lkLKHJg903kjh3liO78Go2s0987sgd8gq1IUY21kI9g&dl=0&path=".urlencode($home["contents"][$key]["path"]);
					//download the file
				//}
				//else
			   // {
				   // $previewLink = $escaped_link."/preview.php?tk=d098lkLKHJg903kjh3liO78Go2s0987sgd8gq1IUY21kI9g&rev=".$home["contents"][$key]["rev"]."&path=".urlencode($home["contents"][$key]["path"]);
					//make a dropbox preview
			   // }
				
				$ext = pathinfo($filePath, PATHINFO_EXTENSION);
				$ext = strtolower($ext);
				
				if($ext == "pdf")
					$home["contents"][$key]["mime_type"] = "application/pdf";
				
				$thumbOpts = array("jpeg","jpg","png", "tiff", "tif", "gif","bmp");
				
				if( in_array($ext,$thumbOpts) )
				{
					$home["contents"][$key]["thumb_exists"] = 1;
				}
				else
				{
					$home["contents"][$key]["thumb_exists"] = 0;
				}
				
				if( $home["contents"][$key]["thumb_exists"] == 1 )
					$thumbDwnldLink = $escaped_link."/thumbnail.php?tk=d098lkLKHJg903kjh3liO78Go2s0987sgd8gq1IUY21kI9g&path=".urlencode($home["contents"][$key]["path"]);
				else if( $home["contents"][$key]["mime_type"] == "application/pdf" )
				{
					$thumbDwnldLink = $escaped_link."/images/pdf-icon.jpg";
				}

				$home["contents"][$key]["thumb"] = "<a class='previewLink' href='$previewLink' target='_blank'><img src='".$thumbDwnldLink."' alt='Thumbnail Preview' /></a>";
				 
			}
			
			if( isset($_GET["filesOnly"]) )
			{
				$temp = array();
				foreach($home["contents"] as $key => $content)
				{
					if( $home["contents"][$key][".tag"] == "folder" )
						unset($home["contents"][$key]);
					else
						$temp[] = $content;
				}
				$home["contents"] = $temp;
			}
			
			if( isset($_GET["downloadFiles"]) )
			{
				foreach($home["contents"] as $key => $content)
				{
					if( $home["contents"][$key][".tag"] != "folder")
					{
						$link =  "//$_SERVER[HTTP_HOST]/drop-box-php";
						$escaped_link = htmlspecialchars($link, ENT_QUOTES, 'UTF-8');
						$dwnldLink = $escaped_link."/download.php?tk=d098lkLKHJg903kjh3liO78Go2s0987sgd8gq1IUY21kI9g&path=".urlencode($home["contents"][$key]["path"]);
						
						$home["contents"][$key]["path"] = "<a href='".$dwnldLink."' alt='$descID'>".$home["contents"][$key]["fileName"]."</a>";
						
					}
				}
			}
			
			echo json_encode( array("respone"=>"1","data"=>$home["contents"]) );
			
		}
		else
				throw new Exception("Failed to retrieve file list code:5");
	}
	else
				throw new Exception("Failed to retrieve file list code:6");
}
catch (Exception $e) {
    echo json_encode( array("respone"=>"0") );
    /*echo "<strong>ERROR (" . $e->getCode() . ")</strong>: " . $e->getMessage();
    if ($e->getCode() == 401) {
        // Remove auth file
        unlink($config["app"]["authfile"]);
        // Re auth
        echo '<p><a href="authorize.php">Click Here to re-authenticate</a></p>';
    }*/
}
