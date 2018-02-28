<%@ Page Language="C#" AutoEventWireup="true"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>jsTree test</title>
    <!-- 2 load the theme CSS file -->
    <link rel="stylesheet" href="dist/themes/default/style.min.css" />

</head>
<body>

<div id="fine-uploader-gallery"></div>

<!-- 3 setup a container element -->
<div id="jstree">
    <!-- in this example the tree is populated from inline HTML -->
    <%--<ul>
        <li>Root node 1
            <ul>
                <li id="child_node_1">Child node 1</li>
                <li>Child node 2</li>
            </ul>
        </li>
        <li>Root node 2</li>
    </ul>--%>
</div>
<button>demo button</button>
<input type="file" id="file" onchange="upload2()"/>
<table id="filesTable">
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
<script language="c#" runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        Session["DbxToken"] = "lpGPoFMIcGAAAAAAAAAAEqsb7NxYp_GcmMt2ED09HFIoupHrdw9qMz1HJ0qoa7Id";
    }

</script>

<!-- 4 include the jQuery library -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/1.12.1/jquery.min.js"></script>
<!-- 5 include the minified jstree source -->
<script src="dist/jstree.min.js"></script>

<script type="text/javascript" src="/jQueryDataTable/jquery.dataTables.min.js"></script>
<link rel="stylesheet" href="/jQueryDataTable/jquery.dataTables.min.css" />

<link href="client/fine-uploader-new.css" rel="stylesheet">

<!-- Fine Uploader jQuery JS file
====================================================================== -->
<script src="client/jquery.fine-uploader.js"></script>
<script type="text/template" id="qq-template-gallery">
        <div class="qq-uploader-selector qq-uploader qq-gallery" qq-drop-area-text="Drop files here">
            <div class="qq-total-progress-bar-container-selector qq-total-progress-bar-container">
                <div role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" class="qq-total-progress-bar-selector qq-progress-bar qq-total-progress-bar"></div>
            </div>
            <div class="qq-upload-drop-area-selector qq-upload-drop-area" qq-hide-dropzone>
                <span class="qq-upload-drop-area-text-selector"></span>
            </div>
            <div class="qq-upload-button-selector qq-upload-button">
                <div>Upload a file</div>
            </div>
            <span class="qq-drop-processing-selector qq-drop-processing">
                <span>Processing dropped files...</span>
                <span class="qq-drop-processing-spinner-selector qq-drop-processing-spinner"></span>
            </span>
            <ul class="qq-upload-list-selector qq-upload-list" role="region" aria-live="polite" aria-relevant="additions removals">
                <li>
                    <span role="status" class="qq-upload-status-text-selector qq-upload-status-text"></span>
                    <div class="qq-progress-bar-container-selector qq-progress-bar-container">
                        <div role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" class="qq-progress-bar-selector qq-progress-bar"></div>
                    </div>
                    <span class="qq-upload-spinner-selector qq-upload-spinner"></span>
                    <div class="qq-thumbnail-wrapper">
                        <img class="qq-thumbnail-selector" qq-max-size="120" qq-server-scale>
                    </div>
                    <button type="button" class="qq-upload-cancel-selector qq-upload-cancel">X</button>
                    <button type="button" class="qq-upload-retry-selector qq-upload-retry">
                        <span class="qq-btn qq-retry-icon" aria-label="Retry"></span>
                        Retry
                    </button>

                    <div class="qq-file-info">
                        <div class="qq-file-name">
                            <span class="qq-upload-file-selector qq-upload-file"></span>
                            <span class="qq-edit-filename-icon-selector qq-edit-filename-icon" aria-label="Edit filename"></span>
                        </div>
                        <input class="qq-edit-filename-selector qq-edit-filename" tabindex="0" type="text">
                        <span class="qq-upload-size-selector qq-upload-size"></span>
                        <button type="button" class="qq-btn qq-upload-delete-selector qq-upload-delete">
                            <span class="qq-btn qq-delete-icon" aria-label="Delete"></span>
                        </button>
                        <button type="button" class="qq-btn qq-upload-pause-selector qq-upload-pause">
                            <span class="qq-btn qq-pause-icon" aria-label="Pause"></span>
                        </button>
                        <button type="button" class="qq-btn qq-upload-continue-selector qq-upload-continue">
                            <span class="qq-btn qq-continue-icon" aria-label="Continue"></span>
                        </button>
                    </div>
                </li>
            </ul>

            <dialog class="qq-alert-dialog-selector">
                <div class="qq-dialog-message-selector"></div>
                <div class="qq-dialog-buttons">
                    <button type="button" class="qq-cancel-button-selector">Close</button>
                </div>
            </dialog>

            <dialog class="qq-confirm-dialog-selector">
                <div class="qq-dialog-message-selector"></div>
                <div class="qq-dialog-buttons">
                    <button type="button" class="qq-cancel-button-selector">No</button>
                    <button type="button" class="qq-ok-button-selector">Yes</button>
                </div>
            </dialog>

            <dialog class="qq-prompt-dialog-selector">
                <div class="qq-dialog-message-selector"></div>
                <input type="text">
                <div class="qq-dialog-buttons">
                    <button type="button" class="qq-cancel-button-selector">Cancel</button>
                    <button type="button" class="qq-ok-button-selector">Ok</button>
                </div>
            </dialog>
        </div>
    </script>

<script>
    var jsonFilesdata;
    var currentlyLodedFolder = "";
    $(document).ready(function () {
        $("#NavigationHeader ul").append('<li id="DAM" class="menuButton cartButton color"><a href="/uStore/Home?DAM=true">DAM</a></li>');
        var isAdmin = true;
       
        var jsondata = <%=DamProxyPage.GetFolderTree()%>;
        $('#jstree').jstree({
            'core': {
                "multiple": false,
                "check_callback": true,
                strings: {
                    'New node': 'New Folder'
                },
                data: jsondata
            },
            'plugins': ["contextmenu", /*"dnd",*/ "search", "state", "types", "unique"],
            contextmenu: { items: context_menu }
        }).on('create_node.jstree', function (e, data) {
            createFolder(data.node.parent + '/' + data.node.text);
        }).on('rename_node.jstree', function (e, data) {
            var folderFrom = data.node.parent + "/" + data.old;
            var folderTo = data.node.parent + '/' + data.text;

            if (folderFrom != folderTo) {
                renameFolder(folderFrom, folderTo);
                $('#jstree').jstree(true).set_id(data.node, folderTo);
                data.node.children_d.forEach(function (childId) {
                    var childNode = $('#jstree').jstree(true).get_node(childId);
                    $('#jstree').jstree(true).set_id(childNode, childNode.parent + '/' + childNode.text);
                });
            }
        }).on("select_node.jstree", function (e, data) {
            console.log("select_node");
            console.log(data);
            //if (data.node.id != currentlyLodedFolder) {
            //    //Load the files data of the selected folder    

            populateData(data.node.id);
            //console.log("currentlyLodedFolder");
            //console.log(currentlyLodedFolder);
            currentlyLodedFolder = data.node.id;

            //} 
        }).on("state_ready.jstree", function (e, data) {
            console.log("state_ready.jstree");
            console.log(data);
        });

        var tree = $('#jstree').jstree(true);
        function context_menu(node) {
            var items = {
                "Create": {
                    "separator_before": false,
                    "separator_after": false,
                    "label": "Create",
                    "action": function (obj) {
                        var $node = tree.create_node(node);
                        tree.edit($node);
                    }
                },
                "Rename": {
                    "separator_before": false,
                    "separator_after": false,
                    "label": "Rename",
                    "action": function (obj) {
                        tree.edit(node, null, function () {
                        });
                    }
                },
                "Delete": {
                    "separator_before": true,
                    "separator_after": false,
                    "label": "Delete",
                    "action": function (obj) {
                        if (confirm('Are you sure to delete this folder?')) {
                            deleteAsset(node.original.id);
                            tree.delete_node(node);
                        }
                    }
                }
            };

            if (!isAdmin) {
                delete items.Delete;
                delete items.Rename;
                delete items.Create;
            }
            else {
                if (node.id == '/red rooster') {
                    delete items.Delete;
                    delete items.Rename;
                }
            }

            return items;
        }





        function getFolders() {
            $.ajax({
                type: "POST",
                url: "/DAMProxy.aspx/GetFolderTree",
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function (data) {
                    jsondata = [];
                    jsondata = data.d.slice();
                    console.log(data.d.slice());
                },
                async: false

            });
        }

        function renameFolder(folderFrom, folderTo) {
            $.ajax({
                type: "POST",
                url: "/DAMProxy.aspx/RenameFolder",
                data: "{'folderFrom':'" + folderFrom + "', 'folderTo':'" + folderTo + "'}",
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function (data) {

                },
                async: false

            });
        }

        function createFolder(folderFullPath) {
            console.log('called');
            $.ajax({
                type: "POST",
                url: "/DAMProxy.aspx/CreateFolder",
                data: "{'folderFullPath':'" + folderFullPath + "'}",
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function (data) {

                },
                error: function (data) {

                    console.log('error');
                    console.log(data);
                },
                async: false

            });
        }


        function getFiles(folderPath) {
            $.ajax({
                type: "POST",
                url: "/DAMProxy.aspx/GetFiles",
                data: "{'folderPath':'" + folderPath + "'}",
                dataType: "json",
                contentType: "application/json; charset=utf-8",

                success: function (data) {

                    console.log(data);
                    jsonFilesdata = JSON.parse(data.d);

                },
                error: function () {

                },
                async: false

            });
        }


        function populateData(folderPath) {
            getFiles(folderPath);
            //console.log(jsonFilesdata);
            $("#filesTable").dataTable(
                {
                    destroy: true,
                    "data": jsonFilesdata,
                    "aoColumnDefs": [
                        {

                            "aTargets": [0],
                            "bSortable": false,
                            "data": "type",

                            "mRender": function (data) {
                                var fname = "pdf";
                                if (data != "pdf") {
                                    fname = "image";
                                }

                                return '<img height="50px" width="50px" src="/Images/' + fname + '.png"/>';

                            }
                        },
                        {
                            "data": "name",
                            "aTargets": [1]
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

                                return "<a href=\"#\" onclick=\"confirmationDelete('/" + data + "');\">Del</a>";
                            }
                        },
                        {
                            "sTitle": "",
                            "aTargets": [5],
                            "sType": "string",
                            "bSortable": false,

                            "mRender": function (data) {
                                return "<a href=\"#\" onclick=\"downloadFile('/" + data + "');\">Download</a>";;
                            }
                        }

                    ]
                });
        }
    });

    function confirmationDelete(folderPath) {
        if (confirm("Are you sure you want to delete this file?"))
            deleteAsset(folderPath, true);
    }

    function deleteAsset(path, isFile = false) {
        if (isFile) {
            path = currentlyLodedFolder + path;
        }
        $.ajax({
            type: "POST",
            url: "/DAMProxy.aspx/Delete",
            data: "{'path':'" + path + "'}",
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            success: function (data) {
            },
            async: true
        });
    }
    //  

    function downloadFile(path) {
        path = "/Red Rooster/Smitha/masterpage back.txt";
        $.ajax({
            type: "POST",
            url: "/DAMProxy.aspx/DownloadFile",
            data: "{'filePath':'" + path + "'}",
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            success: function (data) {
                console.log(data);
            },
            async: true
        });
    }

    function upload() {
        console.log('called');
        var data = new FormData();
        data.append('file-0', $('#file')[0].files[0]);
        //$.each($('#file')[0].files, function (i, file) {
        //    data.append('file-0', $('#file')[0].files[0]));
        //});
        // console.log($('#file')[0].files[0]);
        //$.ajax({
        //    url: '/DAMProxy.aspx/UploadFile',
        //   // data: data,
        //    cache: false,
        //    contentType: false,
        //    processData: false,
        //    method: 'POST',
        //    type: 'POST', // For jQuery < 1.9
        //    success: function (data) {

        //  console.log(data);
        //    },
        //    error: function(error) {
        //        console.log(error);
        //    }
        //});

        $.ajax({
            type: "POST",
            url: "/DAMProxy.aspx/UploadFile",
            cache: false,
            contentType: false,
            processData: false,
            method: 'POST',
            contentType: false,
            success: function(data) {
                console.log(data);
            },
            async: true
        });


     


    }

    function upload2() {

        var fileUpload = $("#file").get(0);
        var files = fileUpload.files;

        var data = new FormData();
        for (var i = 0; i < files.length; i++) {
            data.append(files[i].name, files[i]);
        }

        var options = {};
        options.url = "FileUploadHandler.ashx?folderPath=" + currentlyLodedFolder;
        options.type = "POST";
        options.data = data;
        options.contentType = false;
        options.processData = false;
        options.success = function (result) { alert(result); };
        options.error = function (err) { alert(err.statusText); };

        $.ajax(options);

        evt.preventDefault();

        
    }
</script>


<script>
    //$('#fine-uploader-gallery').fineUploader({
    //    template: 'qq-template-gallery',
    //    request: {
    //        endpoint: '/DAMProxy.aspx/UploadFile'
    //    },
    //    validation: {

    //        //allowedExtensions: ['jpeg', 'jpg', 'gif', 'png']
    //    }
    //});
</script>

<%--     <script type="text/javascript">
         $(function () {

             var jsondata = [
                 { "id": "ajson1", "parent": "#", "text": "Simple root node" },
                 { "id": "ajson2", "parent": "#", "text": "Root node 2" },
                 { "id": "ajson3", "parent": "ajson2", "text": "Child 1" },
                 { "id": "ajson4", "parent": "ajson2", "text": "Child 2" },
             ];

             createJSTree(jsondata);
         });

         function createJSTree(jsondata) {
             $('#jstree').jstree({
                 "core": {
                     "check_callback": true,
                     'data': jsondata

                 },
                 "plugins": ["contextmenu"],
                 "contextmenu": {
                     "items": function ($node) {
                         var tree = $("#jstree").jstree(true);
                         return {
                             "Create": {
                                 "separator_before": false,
                                 "separator_after": true,
                                 "label": "Create",
                                 "action": false,
                                 "submenu": {
                                     "File": {
                                         "seperator_before": false,
                                         "seperator_after": false,
                                         "label": "File",
                                         action: function (obj) {
                                             $node = tree.create_node($node, { text: 'New File', type: 'file', icon: 'glyphicon glyphicon-file' });
                                             tree.deselect_all();
                                             tree.select_node($node);
                                         }
                                     },
                                     "Folder": {
                                         "seperator_before": false,
                                         "seperator_after": false,
                                         "label": "Folder",
                                         action: function (obj) {
                                             $node = tree.create_node($node, { text: 'New Folder', type: 'default' });
                                             tree.deselect_all();
                                             tree.select_node($node);
                                         }
                                     }
                                 }
                             },
                             "Rename": {
                                 "separator_before": false,
                                 "separator_after": false,
                                 "label": "Rename",
                                 "action": function (obj) {
                                     tree.edit($node);
                                 }
                             },
                             "Remove": {
                                 "separator_before": false,
                                 "separator_after": false,
                                 "label": "Remove",
                                 "action": function (obj) {
                                     tree.delete_node($node);
                                 }
                             }
                         };
                     }
                 }
             });
         }
    </script>--%>


</body>
</html>