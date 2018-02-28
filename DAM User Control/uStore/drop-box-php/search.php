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
	$query = (!empty($_GET["query"])) ? $_GET["query"] : "";
	// "file" + $file;
	//file_put_contents($file, "List Path - " .  $path, FILE_APPEND | LOCK_EX);

	$cheaders = array('Authorization:Bearer sKK1-7GZkwQAAAAAAABFcAIrwEBKrtg3LCJKHy0ndMypX2CXB7lfz6tx55D0AeMj',
					  'Content-Type: application/json');
$path = urldecode($path);
$query = urldecode($query);
	$data = array("path" =>$path,"query"=>$query);                                                                    
	$data_string = json_encode($data);	

	$ch = curl_init('https://api.dropboxapi.com/2/files/search');
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
		if($jsonResponse != null && isset($jsonResponse->matches) )
		{
			$referringCat = "";
		
			if( isset($_SERVER['HTTP_REFERER']) )
			{
				$referringUrlParts = explode("/",$_SERVER['HTTP_REFERER']);
			
				foreach($referringUrlParts as $key => $referringUrlPart)
				{
					if($referringUrlPart == "Category")
					{
						$referringCat = $referringUrlParts[$key+1];
					}
				}
			}
			
			$home = $jsonResponse->matches;
			
			foreach($home as $key => $content)
			{
				$home[$key] = (array) $content->metadata;
				$home[$key]["path"] = $home[$key]["path_lower"];
				
				$descID = "";
				$pathParts = explode("/", $home[$key]["path"]);
				$filePath = $pathParts[count($pathParts)-1];
				
			   $home[$key]["fileName"] = $filePath;
				
				$link =  "//$_SERVER[HTTP_HOST]/drop-box-php";
				$escaped_link = htmlspecialchars($link, ENT_QUOTES, 'UTF-8');
				$thumbDwnldLink = $escaped_link."/images/generic-document.jpg";
				
				$home[$key]["desc"] = "";
				
				$sqlResult = SQLBroker::getSQLConnection()->selectQuery(
				"SELECT [dropBoxFileDescId]
					  ,[fileName]
					  ,[catId]
					  ,[fileDesc]
				  FROM [GLD-Xmpie-EXT].[dbo].[DropBox-File-Desc]
				  WHERE [fileName] = '".Util::stripChar($home[$key]["fileName"],"'")."'
				  AND catId = ".(int)$referringCat);
				
				if( is_array($sqlResult) && count($sqlResult) > 0 )
				{
					$home[$key]["desc"] = "<span class='dropBoxFileDescId' id='dropBoxFileDescId-".$sqlResult[0]->dropBoxFileDescId."'>".$sqlResult[0]->fileDesc."</span><br>";
					$descID = $sqlResult[0]->dropBoxFileDescId;
				}
				 
				if( !isset($home[$key]["mime_type"]) )
				{
					$home[$key]["mime_type"] = "";
				}
				
			   // if( $home[$key]["mime_type"] == "application/pdf"
			   //     || preg_match ("/image\//",$home[$key]["mime_type"],$matches) )
			   // {
					$previewLink = $escaped_link."/download.php?tk=d098lkLKHJg903kjh3liO78Go2s0987sgd8gq1IUY21kI9g&dl=0&path=".urlencode($home[$key]["path"]);
					//download the file
			   // }
			   // else
			   // {
				   // $previewLink = $escaped_link."/preview.php?tk=d098lkLKHJg903kjh3liO78Go2s0987sgd8gq1IUY21kI9g&rev=".$home[$key]["rev"]."&path=".urlencode($home[$key]["path"]);
					//make a dropbox preview
			  //  }
				
				$home[$key]["preview"] = $previewLink;
				
				$ext = pathinfo($filePath, PATHINFO_EXTENSION);
				$ext = strtolower($ext);
				
				if($ext == "pdf")
					$home[$key]["mime_type"] = "application/pdf";
				
				$thumbOpts = array("jpeg","jpg","png", "tiff", "tif", "gif","bmp");
				
				if( in_array($ext,$thumbOpts) )
				{
					$home[$key]["thumb_exists"] = 1;
				}
				else
				{
					$home[$key]["thumb_exists"] = 0;
				}
				
				if( $home[$key]["thumb_exists"] == 1 )
					$thumbDwnldLink = $escaped_link."/thumbnail.php?tk=d098lkLKHJg903kjh3liO78Go2s0987sgd8gq1IUY21kI9g&path=".urlencode($home[$key]["path"]);
				else if( $home[$key]["mime_type"] == "application/pdf" )
				{
					$thumbDwnldLink = $escaped_link."/images/pdf-icon.jpg";
				}

				$home[$key]["thumb"] = $thumbDwnldLink;
				 
			}
			
			if( isset($_GET["filesOnly"]) )
			{
				$temp = array();
				foreach($home as $key => $content)
				{
					if( $home[$key][".tag"] == "folder" )
						unset($home[$key]);
					else
						$temp[] = $content;
				}
				$home = $temp;
			}
			
			if( isset($_GET["downloadFiles"]) )
			{
				foreach($home as $key => $content)
				{
					if( $home[$key][".tag"] != "folder" )
					{
						$link =  "//$_SERVER[HTTP_HOST]/drop-box-php";
						$escaped_link = htmlspecialchars($link, ENT_QUOTES, 'UTF-8');
						$dwnldLink = $escaped_link."/download.php?tk=d098lkLKHJg903kjh3liO78Go2s0987sgd8gq1IUY21kI9g&path=".urlencode($home[$key]["path"]);
						
						$home[$key]["downloadLnk"] = $dwnldLink;	
					}
				}
			}
			
			echo json_encode( array("respone"=>"1","data"=>$home) );
		}
		else
				throw new Exception("Failed to retrieve file list code:5");
	}
	else
				throw new Exception("Failed to retrieve file list code:6");
}
catch (Exception $e) {
    echo json_encode( array("respone"=>"0ex".$e->getMessage()) );
    /*echo "<strong>ERROR (" . $e->getCode() . ")</strong>: " . $e->getMessage();
    if ($e->getCode() == 401) {
        // Remove auth file
        unlink($config["app"]["authfile"]);
        // Re auth
        echo '<p><a href="authorize.php">Click Here to re-authenticate</a></p>';
    }*/
}
