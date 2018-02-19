<%@ Control Language="C#"   ClassName="DamFilesList" Debug="true" %>
<html>

    <head>
        <script type="text/javascript" href="~/jquery-1.11.3.min.js"></script>
<script type="text/javascript" href="~/jquery.dataTables.min.js"></script>
<link rel="stylesheet" href="~/jquery.dataTables.min.css" />
    </head>

    <body>
  <table id="example">

  </table>
    
  <script>
      $(document).ready(function () {
          $("#example").dataTable({
              "aaData": [
                  ["/Red.jpg", "Asset1", "10mb", "jpg", "10X10","Delete","Download"],
                  ["/Red.jpg", "Asset2", "12mb", "png", "12X15", "Delete", "Download"]

              ],
              "aoColumnDefs": [{
                  "sTitle": "Images",
                  "aTargets": [0],
                  "bSortable": false,
                  //"sWidth": "40px",
                  //"mRender": function () {
                  //    //var img ='<div class="nailthumb-container"> < img id="red" src= "/red.jpg" /> </div >'
                  //    //'<div class="nailthumb-container"> < img id="red" src= "/red.jpg" /> </div >'
                  //    //var img = '<img id="red" src="/red.jpg" />';
                  //    //return '<img id="red" src="/red.jpg" />';
                  //    return $("#red").nailthumb({ width: 100, height: 100 });
                  //}
              },
                  {
                      "sTitle": "Asset Name",
                      "aTargets": [1],
                      "sType": "string",
                      "sWidth": "40px"
                      //"mRender": function () {
                      //    return "A Name";
                      //}
                  },
                  {
                      "sTitle": "File Size",
                      "aTargets": [2],
                      "sType": "string",
                      "sWidth": "40px",
                      "data":"size",
                      "mRender": function (data) {
                          return data+" MB";
                      }
                  },
                  {
                      "sTitle": "Asset Type",
                      "aTargets": [3],
                      "sType": "string",
                      "sWidth": "40px"
                      //"mRender": function () {
                      //    return "A Type";
                      //}
                  },
                          {
                          "sTitle": "Asset Size",
                          "aTargets": [4],
                          "sType": "string",
                          "sWidth": "40px"
                          //"mRender": function () {
                          //    return "A Size";
                          //}
                  }, {
                      "sTitle": "Delete",
                      "aTargets": [5],
                      "sType": "string",
                      "sWidth": "40px",
                      "mRender": function () {
                          return '<a href="http://www.google.com">Delete</a>';
                      }
                          }, {
                              "sTitle": "Download",
                              "aTargets": [6],
                              "sType": "string",
                              "sWidth": "40px",
                              "mRender": function () {
                                  return '<a href="http://www.google.com">Download</a>';
                              }
                          }]
              });
             
         
      });
      
  </script>
        </body>
</html>