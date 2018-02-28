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
		<script type="text/javascript" src="js/plupload.full.min.js"></script>
 <script type="text/javascript">
			$(document).ready( function(){
            var fileLimit = 20;
            var uploader = new plupload.Uploader({
              browse_button: document.getElementById('uploadBtn'), // this can be an id of a DOM element or the DOM element itself
              url: 'upload-chunked.php?tk=d098lkLKHJg903kjh3liO78Go2s0987sgd8gq1IUY21kI9g&fromPath=1',
              filters : {
                max_file_size : '1050mb'
              },
				multipart_params : {
					"path" : "<?php if(isset($_GET["path"])) { echo $_GET["path"]; } ?>"
				}
            });

            uploader.init();

            uploader.bind('FilesAdded', function(up, files) {
				$("#uploadMsgConfirm").hide();
              var html = '';
              plupload.each(files, function(file) {
                    html += '<li id="' + file.id + '">' + file.name + '<b></b></li>';
              });
              document.getElementById('filelist').innerHTML += html;
              var currFiles = 0;
              var clip = false;
              plupload.each(files, function(file) 
              {
                if(currFiles >= fileLimit)
                {
                    clip = true;
                }
                    
                currFiles++;

              });
              
              if(clip)
              {
                  clearImgUpload();
                  alert("Maximum "+fileLimit+" Files.");
              }
              else
                  uploader.start();

            });

            uploader.bind('UploadProgress', function(up, file) 
			{
				var progressHtml = '<span> ' + file.percent + "%</span>";
				if( file.percent == 100 )
					progressHtml = '<span> Adding to Dropbox... <img style="vertical-align: middle;" src="images/spinner-white.gif" /></span>';
				document.getElementById(file.id).getElementsByTagName('b')[0].innerHTML = progressHtml;
            });

            uploader.bind('Error', function(up, err) 
            {
				var errMsg;
                if(err.code == -601)
                    errMsg = "Invalid File Type";
                else if(err.code == -600)
                    errMsg = "File too large. Maximum 140mb.";
                else
                    errMsg = "Could not add file.";
				
                $("#uploadMsgerrorCntr").show();
				$("#uploadMsgerror").text(errMsg);
				
                clearImgUpload();
            });
            
            uploader.bind('UploadFile', function(up, file) 
            {
                $("#uploadBtn").hide();
				$("#uploadMsg").show();
				$("#uploadMsgerrorCntr").hide();
            });
            
            uploader.bind('UploadComplete', function(up, files) 
            {
                
				$("#uploadMsgConfirm").show();
				$("#uploadBtn").show();
				$("#uploadMsg").hide();
				document.getElementById('filelist').innerHTML = "";
            });
			
			
            
            function clearImgUpload()
            {
                uploader.splice(0,uploader.files.length);
                document.getElementById('filelist').innerHTML = "";
                $("#uploadBtn").show();
				$("#uploadMsg").hide();
				$("#uploadMsgConfirm").hide();
				
            }
	} );
	</script>
      
    </head>
    <body>
        <div style="width: 518px;">
			<div id="uploadMsgConfirm" style="text-align:center;color:green;font-family:sans-serif;<?php if(!isset($_GET["t"])) { ?>display:none;<?php } ?>">
				<b>File(s) uploaded Successfully!</b>
				<hr />
			</div>
			<div id="uploadMsgerrorCntr" style="text-align:center;color:red;font-family:sans-serif;display:none;">
				<p id="uploadMsgerror"></p>
				<hr />
			</div>
                <div>
					<button id="uploadBtn">Choose Files</button>
					<p id="uploadMsg" style="display:none;color:green;font-family:sans-serif;">Uploading... <img style="vertical-align: middle;" src="images/spinner-white.gif" /></p>
				</div>
				<hr />
				<ul id="filelist" style="list-style-type: none;clear:both;"></ul>
        </div>
    </body>
</html>
