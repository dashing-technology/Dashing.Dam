<%@ Page Language="C#" AutoEventWireup="true" ClassName="DamProxyPage"%>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Web.Script.Serialization" %>
<%@ Import Namespace="System.Web.Services" %>

<!DOCTYPE html>
<script language="c#" runat="server">

    static string BaseDamUrl = @"http://192.168.100.228/DashingDAM/api/Dam/";
    //static string BaseDamUrl = @"http://dashingdam20180209100733.azurewebsites.net/api/Dam/";
    //static string BaseDamUrl = @"http://localhost:60201/api/Dam/";
    //To make this more secure move the token setting to a session variable in the master page

    static string RootFolder = "/Red Rooster";
    [WebMethod]
    public static string GetFolderTree()
    {

        var token = HttpContext.Current.Session["DbxToken"];

        string result = "";
        if (token != null)
        {
            string apiUrl =  string.Format("?token={0}&rootFolderPath={1}", token, RootFolder);
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
    public static string Delete(string path)
    {
        if (path.Trim().ToLower() == RootFolder.Trim().ToLower())
        {
            return "Can not delete root folder: " + RootFolder;
        }
        var token = HttpContext.Current.Session["DbxToken"];
        string result = "";
        if (token != null)
        {
            try
            {
                WebClient client = new WebClient();
                string apiUrl = string.Format("Delete?token={0}&path={1}", token, path);
                client.Headers.Add("Content-Type:application/json");
                client.Headers.Add("Accept:application/json");
                result = client.DownloadString(BaseDamUrl + apiUrl); //URI 
                
               
            }
            catch (Exception e)
            {
                result = e.Message;
            }

        }
        return result;
    }

    [WebMethod]
    public static string RenameFolder(string folderFrom,string folderTo)
    {
        if (folderFrom.Trim().ToLower() == RootFolder.Trim().ToLower())
        {
            return "Can not delete roo folder: " + RootFolder;
        }
        var token = HttpContext.Current.Session["DbxToken"];
        string result = "";
        if (token != null)
        {
            try
            {
                WebClient client = new WebClient();

                string apiUrl = string.Format("RenameFolder?token={0}&folderFrom={1}&folderTo={2}", token, folderFrom,folderTo);
                client.Headers.Add("Accept:application/json");
                client.UploadString(BaseDamUrl + apiUrl,"");
                result = "Success";
            }
            catch (Exception e)
            {
                result = "Exception:" + e.Message;
            }

        }
        return result;
    }

    [WebMethod]
    public static string CreateFolder(string folderFullPath)
    {
        var token = HttpContext.Current.Session["DbxToken"];
        string result = "";
        if (token != null)
        {
            try
            {
                WebClient client = new WebClient();
                string apiUrl = string.Format("CreateFolder?token={0}&folderFullPath={1}", token,HttpContext.Current.Server.UrlEncode(folderFullPath));
                client.Headers.Add("Accept:application/json");
                string fullUrl = BaseDamUrl +apiUrl;
                client.UploadString(fullUrl,"");
                result = "Success";
            }
            catch (Exception e)
            {
                result = "Exception:" + e.Message;
            }

        }
        return result;
    }

    [WebMethod]
    public static string GetFiles(string folderPath)
    {
        var token = HttpContext.Current.Session["DbxToken"];
        string result = "";
        if (token != null)
        {
            try
            {
                WebClient client = new WebClient();
                string apiUrl = string.Format("GetFiles?token={0}&folderPath={1}", token, folderPath);
                //if (apiUrl != "")
                //{
                //    return BaseDamUrl+apiUrl;
                //}

                //client.Headers["Content-Type"] = "application/json";
                client.Headers.Add("Accept:application/json");
                client.Headers.Add("Content-Type:application/json");
                result=client.DownloadString(BaseDamUrl+apiUrl);
                //result = "Success";
            }
            catch (Exception e)
            {
                result = e.Message + "Token:" + token + ",FolderPath:" + folderPath;
            }

        }
        return result;
    }

    [WebMethod]
    public static string GetDownloadLink(string filePath)
    {
        var token = HttpContext.Current.Session["DbxToken"];
        string result = "";
        if (token != null)
        {
            try
            {
                WebClient client = new WebClient();
                string apiUrl = string.Format("GetDownloadLink?token={0}&filePath={1}", token, filePath);
                //client.Headers["Content-Type"] = "application/json";
                client.Headers.Add("Accept:application/json");
                client.Headers.Add("Content-Type:application/json");
                result= client.DownloadString(BaseDamUrl+apiUrl).Replace("\"","");
            }
            catch (Exception e)
            {
                result = e.Message;
            }

        }
        return result;
    }

    [WebMethod]
    public static string UploadFile()
    {
        var token = HttpContext.Current.Session["DbxToken"];
        string result = "";
        if (token != null)
        {
            try
            {
                WebClient client = new WebClient();
                string apiUrl = string.Format("GetDownloadLink?token={0}&filePath={1}", token, "");
                //client.Headers["Content-Type"] = "application/json";
                client.Headers.Add("Accept:application/json");
                client.Headers.Add("Content-Type:application/json");
                result= client.DownloadString(BaseDamUrl+apiUrl).Replace("\"","");
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

