<%@ Page Language="C#" AutoEventWireup="true" ClassName="DamProxyPage"%>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Web.Script.Serialization" %>
<%@ Import Namespace="System.Web.Services" %>

<!DOCTYPE html>
<script language="c#" runat="server">

    static string BaseDamUrl = @"http://dashingdam20180209100733.azurewebsites.net/api/Dam/";
    //To make this more secure move the token setting to a session variable in the master page

    static string RootFolder = "/Red Rooster";
    [WebMethod]
    public static string GetFolderTree()
    {

        var token = HttpContext.Current.Session["DbxToken"];
        string result = "";
        if (token != null)
        {
            string apiUrl =  string.Format("?token={0}&rootFolder={1}", token, RootFolder);
            WebClient client = new WebClient();
            client.Headers.Add("Content-Type:application/json");
            client.Headers.Add("Accept:application/json");
            result = client.DownloadString(BaseDamUrl + apiUrl); //URI 
        }
        else
        {
            result = "Unauthorized access";
        }

        return result;
    }
   

    [WebMethod]
    public static string DeleteFolder(string folderPath)
    {
        var token = HttpContext.Current.Session["DbxToken"];
        string result = "";
        if (token != null)
        {
            try
            {
                WebClient client = new WebClient();
                string apiUrl = string.Format("DeleteFolder?token={0}&folderPath={1}", token, folderPath);

                //client.Headers["Content-Type"] = "application/json";
                client.Headers.Add("Accept:application/json");
                var values = new NameValueCollection();
                values.Add("token", token.ToString());
                values.Add("folderPath", folderPath);
                client.UploadValues(BaseDamUrl + apiUrl, "DELETE",values);
                result = "Success";
            }
            catch (Exception e)
            {
                result = e.Message;
            }
          
        }
        return result;
    }

</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
<form id="form1" runat="server">
    <div>
    </div>
</form>
</body>
</html>
