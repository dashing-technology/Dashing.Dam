<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm1.aspx.cs" Inherits="DAM_User_Control.WebForm1" %>
<%@ Register TagPrefix="gldXmpExt" TagName="eWayExt" Src="~/DAMFilesList.ascx" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <gldXmpExt:eWayExt runat="server" ID="eWay" />
        </div>
    </form>
</body>
</html>
