<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="DAMFilesList.ascx.cs" Inherits="DAM_User_Control.DAMFilesList" %>
<html>
<head>
   
  <link rel="stylesheet" type="text/css" href="/jquery.dataTables.min.css">
     <script type="text/javascript" charset="utf8" src="/jquery-1.11.3.min.js"></script>
  <script type="text/javascript" charset="utf8" src="/jquery.dataTables.min.js"></script>
     <script type="text/javascript" charset="utf8" src="/jquery.nailthumb.1.1.js"></script>
    

    <title>Folder Name</title>
</head>
     
<body>
   <img id="red" src= "/red.jpg"/>
  <table id="example">
      <%-- <div class="nailthumb-container">
        <img src="/red.jpg" />
    </div>--%>
    <thead>
        <%-- <tr><th>Thumb</th><th>Asset Name </th><th>File Size</th><th>Type</th><th>Asset Size</th></tr>--%>
      <%--<tr>
          <th>Thumbnail</th>
           <th>Asset Name</th>
           <th>File Size</th>
           <th>Asset Type</th>
           <th>Asset Size</th>
     </tr>--%>
    </thead>

    <tbody>
      
    <%-- <tr><td>Thumbnail</td></tr>
      <tr><td>Asset Name</td></tr>
      <tr><td>File Size</td></tr>
          <tr><td>Asset Type</td></tr>
          <tr><td>Asset Size</td></tr>--%>
          <%--<tr><td>Upload New Version</td></tr>
          <tr><td>Delete</td></tr>
          <tr><td>Download</td></tr>--%>
    </tbody>
  </table>
    
  <script>
      $(document).ready(function () {
          $("#example").dataTable({
              "aaData": [
                  ["/Red.jpg", "Asset1", "10mb", "jpg", "10X10","Delete","Download"],
                  ["/Red.jpg", "Asset2", "12mb", "png", "12X15", "Delete", "Download"]

              ],              "aoColumnDefs": [{
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
                      "sWidth": "40px"
                      //"mRender": function () {
                      //    return "F Size";
                      //}
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
                          }]              });
             
         
      });
      
  </script>
</body>
</html>