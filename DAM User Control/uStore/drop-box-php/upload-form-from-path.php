<!DOCTYPE html>
<html>
    <head>
        <title>Upload</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
		<script
  src="https://code.jquery.com/jquery-3.1.1.min.js"
  integrity="sha256-hVVnYaiADRTO2PzUGmuLJr8BLUSjGIZsDYGmIJLv2b8="
  crossorigin="anonymous"></script>
  <script>
	$(document).ready( function()
	{
		$("#uploadForm").submit( function()
		{
			$("#uploadBtn").hide();
			$("#uploadMsg").show();
		} );
	} );
	
  
  </script>
    </head>
    <body>
        <div style="width: 518px;">
			<div style="text-align:center;color:green;font-family:sans-serif;<?php if(!isset($_GET["t"])) { ?>display:none;<?php } ?>">
				<b>File(s) uploaded Successfully!</b>
				<hr />
			</div>
            <form action="upload_new.php?tk=d098lkLKHJg903kjh3liO78Go2s0987sgd8gq1IUY21kI9g&fromPath=1" 
                  method="post" enctype="multipart/form-data" id="uploadForm">
                
                <label style="font-family:sans-serif;" for="path">Location: </label>
				<input type="hidden" name="path" value="<?php if(isset($_GET["path"])) { echo $_GET["path"]; } ?>" />
				
				
				<input name="files[]" id="file" multiple type="file" /><br /><hr />
                <div style="float:right;">
					<input type="submit" value="Upload" id="uploadBtn" />
					<p id="uploadMsg" style="display:none;color:green;font-family:sans-serif;">Uploading Please wait ...</p>
				</div>
            </form>
        </div>
    </body>
</html>
