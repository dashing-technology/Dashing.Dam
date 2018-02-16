<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm1.aspx.cs" Inherits="DAM_User_Control.WebForm1" %>
<%--<%@ Register TagPrefix="gldXmpExt" TagName="eWayExt" Src="~/DAMFilesList.ascx" %>--%>
<!DOCTYPE html>

<html>

    <head>
      <script type="text/javascript" src="/jquery-1.11.3.min.js"></script>
      <script type="text/javascript" src="/jquery-1.11.3.min.js"></script>
      <script type="text/javascript" src="/jquery.dataTables.min.js"></script>
      <link rel="stylesheet" href="/jquery.dataTables.min.css" />
        <title></title>
        <script type="text/javascript">
            var jsondata;
            $(document).ready(function () {
                var folderPath = "/Red Rooster/Smitha";
                getFiles();
                //jsondata = [
                //    {
                //        "name": "dahing group ACR account.PNG",
                //        "size": 19052,
                //        "type": "PNG"
                //    },
                //    {
                //        "name": "port forwarding all.PNG",
                //        "size": 154054,
                //        "type": "PNG"
                //    },
                //    {
                //        "name": "getting started with AKS.PNG",
                //        "size": 796799,
                //        "type": "PNG"
                //    },
                
                //];
                function getFiles(folderPath) {
                    $.ajax({
                        type: "POST",
                        url: "/TestProxy.aspx/GetFiles",
                        data: "{'folderPath':'" + folderPath + "'}",
                        dataType: "json",
                        contentType: "application/json; charset=utf-8",

                        success: function (data) {
                           
                            console.log(data);
                            jsondata = JSON.parse(data.d);
                         
                        },
                        error: function () {

                        },
                        async: true

                    })
                };
               

            });

           
            function populateData() {
               
                       $("#example").dataTable(
                        {
                            destroy:true,
                            "data": jsondata,
                            "aoColumnDefs": [
                                {
                                    "sTitle": "Thumbnail",
                                    "aTargets": [0],
                                    "bSortable": false,
                                    "mRender": function () {
                                        return '<img src="/Red.jpg"/>';
                                    }
                                },
                                {
                                    "data": "name",
                                    "aTargets":[1]
                                },
                                {
                                    "data": "size",
                                    "aTargets": [2]
                                },
                                {
                                    "data": "type",
                                    "aTargets": [3]
                                },
                                {
                                    "sTitle": "",
                                    "aTargets": [4],
                                    "sType": "string",
                                    "bSortable": false,
                                   
                                    "mRender": function () {
                                        return '<a href="http://www.google.com">View</a>';
                                    }
                                },
                                {
                                    "sTitle": "",
                                    "aTargets": [5],
                                    "sType": "string",
                                    "bSortable": false,

                                    "mRender": function () {
                                        return '<a href="http://www.google.com">Delete</a>';
                                    }
                                },
                                {
                                    "sTitle": "",
                                    "aTargets": [6],
                                    "sType": "string",
                                    "bSortable": false,

                                    "mRender": function () {
                                        return '<a href="http://www.google.com">Download</a>';
                                    }
                                }

                                ]
                        });
            }
           
    </script>
    </head>

    <body>
        <button id="aa" name="aa" onclick="populateData()">Click me</button>
  <table id="example">
      <thead>
          <tr>
              <th>Thumbnail</th>
              <th>Name</th>
              <th>Size</th>
              <th>Type</th>
              <th></th>
               <th></th>
               <th></th>

          </tr>
      </thead>

  </table>
    
 
        </body>
</html>
