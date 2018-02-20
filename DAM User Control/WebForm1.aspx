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
            var folderPath = "/Red Rooster/Smitha";
            $(document).ready(function () {
                
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
                                   
                                    "aTargets": [0],
                                    "bSortable": false,
                                    "data":"type",
                                    "mRender": function (data) {
                                       
                                        if (data == "pdf")
                                            return '<img height="50px" width="50px" src="/pdf.png"/>';
                                        else
                                            return '<img height="50px" width="50px" src="/image.png"/>';

                                      //return '<img src="data:image/jpeg;base64,'+data+'"/>';
                                    }
                                },
                                {
                                    "data": "name",
                                    "aTargets":[1]
                                },
                                {
                                    "data": "size",
                                    "aTargets": [2],
                                    "mRender": function (data) {
                                        return data + " MB";
                                    }
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
                                    "data": "name",
                                    
                                    "mRender": function (data) {
                                      return '<a href="#" onclick="confirmationDelete(\'' +data+'\')">Del</a>';
                                    }
                                },
                                
                                {
                                    "sTitle": "",
                                    "aTargets": [5],
                                    "sType": "string",
                                    "bSortable": false,

                                    "mRender": function () {
                                        return '<a href="http://www.google.com">Download</a>';
                                    }
                                }

                                ]
                        });
            }
            function confirmationDelete(data)
            {
                if (confirm("Are you sure you want to delete this file?"))
                    deleteFile(folderPath + '/' + data);
            }

            function deleteFile(filePath) {
                $.ajax({
                    type: "POST",
                    url: "/TestProxy.aspx/Delete",
                    data: "{'path':'" + filePath + "'}",
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function (data) {
                    //alert("success");
                },
                async: true

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
          

          </tr>
      </thead>

  </table>
    
 
        </body>
</html>
