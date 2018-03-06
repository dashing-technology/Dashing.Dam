var jsonFilesdata;
var currentlyLodedFolder = "";
var storeStylePath = "";
var isAdminUser = false;
function InitializeDam(isAdmin, jsondata, stylePath) {
    //$("#NavigationHeader ul").append('<li id="DAM" class="menuButton cartButton color"><a href="/uStore/Home?DAM=true">DAM</a></li>');
    storeStylePath = stylePath;
    isAdminUser = isAdmin;
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
        $('#jstree').jstree(true).set_id(data.node, data.node.parent + '/' + data.node.text);

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
            currentlyLodedFolder = folderTo;
        }
    }).on("select_node.jstree", function (e, data) {
        if (data.node.id != currentlyLodedFolder) {

            populateData(data.node.id);

            currentlyLodedFolder = data.node.id;

        }
    }).on("state_ready.jstree", function (e, data) {

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
                    swal({
                        title: "Folder Deletion",
                        text: "Are you sure you want to delete this Folder?",
                        icon: "warning",
                        buttons: true,
                        dangerMode: true,
                    })
                        .then((willDelete) => {
                            if (willDelete) {
                                deleteAsset(node.original.id);
                                currentlyLodedFolder = node.parent;
                                tree.delete_node(node);
                                $('#jstree').jstree('select_node', currentlyLodedFolder);
                                populateData(currentlyLodedFolder);

                            }
                        });

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
            url: storeStylePath + "/DAMProxy.aspx/GetFolderTree",
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            success: function (data) {
                jsondata = [];
                jsondata = data.d.slice();

            },
            async: false

        });
    }

    function renameFolder(folderFrom, folderTo) {
        $.ajax({
            type: "POST",
            url: storeStylePath + "/DAMProxy.aspx/RenameFolder",
            data: "{'folderFrom':'" + folderFrom + "', 'folderTo':'" + folderTo + "'}",
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            success: function (data) {

            },
            async: false

        });
    }

    function createFolder(folderFullPath) {

        $.ajax({
            type: "POST",
            url: storeStylePath + "/DAMProxy.aspx/CreateFolder",
            data: "{'folderFullPath':'" + folderFullPath + "'}",
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            success: function (data) {
                currentlyLodedFolder = folderFullPath;
                jsonFilesdata = [];
                LoadTable();
            },
            error: function (data) {
                swal("Error", data, "error");
            },
            async: false
        });
    }
}
function getFiles(folderPath) {

    $.ajax({
        type: "POST",
        url: storeStylePath + "DAMProxy.aspx/GetFiles",
        data: "{'folderPath':'" + folderPath + "'}",
        dataType: "json",
        contentType: "application/json; charset=utf-8",

        success: function (data) {

            jsonFilesdata = JSON.parse(data.d);

        },
        error: function (err) {

        },
        async: false

    });
}

function populateData(folderPath) {
    getFiles(folderPath);
    LoadTable();
}

function LoadTable() {



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
                        var fname = "";

                        switch (data) {

                            case '.pdf':
                                fname = "pdf";
                                break;
                            case '.doc':
                            case '.docx':
                                fname = "docx";
                                break;

                            case '.txt':
                                fname = "txt";
                                break;
                            case '.xlsx':
                                fname = "excel";
                                break;

                            default:
                                fname = "image";
                                break;


                        }

                        return '<img height="50px" width="50px" src="' + storeStylePath + 'Images/' + fname + '.png"/>';

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
                        if (isAdminUser) {
                            return "<a href=\"#\" onclick=\"confirmationDelete('" +
                                data +
                                "');\"><img height=\"20px\" width=\"20px\" src=\" " +
                                storeStylePath +
                                "Images/delete.png\"/></a>";
                        }
                        return "";
                    }
                },
                {
                    "sTitle": "",
                    "aTargets": [5],
                    "sType": "string",
                    "bSortable": false,
                    "data": "name",
                    "mRender": function (data) {
                        return "<a href=\"#\" onclick=\"downloadFile(this,'/" + data + "');\"><img height=\"20px\" width=\"20px\" src=\"" + storeStylePath + "Images/download.png\"/></a>";;
                    }
                }

            ]
        });
}

function confirmationDelete(folderPath) {
    swal({
        title: "File Deletion",
        text: "Are you sure you want to delete this file?",
        icon: "warning",
        buttons: true,
        dangerMode: true,
    })
        .then((willDelete) => {
            if (willDelete) {
                deleteAsset(folderPath, true);
            }
        });
}

function deleteAsset(assetName, isFile = false) {
    var path = assetName;
    if (isFile) {
        path = currentlyLodedFolder + "/" + assetName;

    }
    $.ajax({
        type: "POST",
        url: storeStylePath + "/DAMProxy.aspx/Delete",
        data: "{'path':'" + path + "'}",
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            if (isFile) {
                var index = jsonFilesdata.map(function (f) { return f.name }).indexOf(assetName);
                jsonFilesdata.splice(index, 1);
                LoadTable();
            }
        },
        async: true
    });
}
//  

function downloadFile(element, path) {
    path = currentlyLodedFolder + path;
    $.ajax({
        type: "POST",
        url: storeStylePath + "/DAMProxy.aspx/GetDownloadLink",
        data: "{'filePath':'" + path + "'}",
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {

            element.href = data.d;

        },
        async: false
    });
}

function upload(evt) {
    // options.url = storeStylePath + "/FileUploadHandler.ashx?folderPath=" + currentlyLodedFolder;
    var fileUpload = $("#image_uploads").get(0);
    var files = fileUpload.files;
    var data = new FormData();
    for (var i = 0; i < files.length; i++) {
        //if (validFileSize(files[i].size))
        data.append(files[i].name, files[i]);
    }

    var options = {};
    options.url = storeStylePath + "/FileUploadHandler.ashx?folderPath=" + currentlyLodedFolder;
    options.type = "POST";
    options.data = data;
    options.contentType = false;
    options.processData = false;
    $('.loader').show();
    options.success = function (result) { console.log(result); populateData(currentlyLodedFolder); $('.loader').hide(); swal("Success", "File uploaded successfully!", "success"); };
    options.error = function (err) { swal("Error", err.statusText, "error"); $('.loader').hide(); };
    $.ajax(options);

}
function updateImageDisplay() {
    $("#filePreviewTable tr").remove();
    var input = $("#image_uploads").get(0);
    var preview = $("#preview");

    var table = $('#filePreviewTable');
    //var filePreviewTable = $('#filePreviewTable');
    var curFiles = input.files;
    //while (filePreviewTable.firstChild) {

    //    filePreviewTable.removeChild(filePreviewTable.firstChild);
    //}
    if (curFiles.length === 0) {

        var para = document.createElement('p');
        para.textContent = 'No files currently selected for upload';
        preview.append(para);
    }
    else {

        for (var i = 0; i < curFiles.length; i++) {
            //if (validFileSize(curFiles[i].size)) {
            var imgSrc = storeStylePath + "/Images/image.png";

            switch (curFiles[i].type) {

                case 'application/pdf':
                    imgSrc = storeStylePath + "/Images/pdf.png";
                    break;
                case 'application/msword':
                case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
                    imgSrc = storeStylePath + "/Images/docx.png";
                    break;
                
                   

                case 'text/plain':
                    imgSrc = storeStylePath + "/Images/txt.png";
                    break;
                case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
                    imgSrc = storeStylePath + "/Images/excel.png";
                    break;
                default:
                    imgSrc = window.URL.createObjectURL(curFiles[i]);
                    break;


            }




            table.append('<tr><td><img src="' + imgSrc + '" height="80px" width="80px" align="center"/></td><td>' + curFiles[i].name + '</td><td>' + returnFileSize(curFiles[i].size) + '</td></tr>');
            // }
        }
    }

}
function validFileSize(fileSize) {

    if (fileSize <= 99999999) {
        return true;
    }

    return false;
}


function returnFileSize(number) {

    return (number / 1048576).toFixed(4) + ' MB';

}

function openPopup() {

    $("#divpreview").dialog({
        title: "Upload Files",
        closeOnEscape: true,
        maxWidth: 600,
        maxHeight: 500,
        width: 600,
        height: 500,
        buttons: [
            {
                text: "Upload",
                click: function () {
                    upload();

                    $("#filePreviewTable tr").remove();
                    $("#divpreview").dialog("close");

                }

            }
        ]

    });
    return false;
}
