<%@ WebHandler Language="C#" Class="FileUploadHandler" %>

using System;
using System.IO;
using System.Net;
using System.Web;

public class FileUploadHandler : IHttpHandler
{
    //string BaseDamUrl = @"http://dashingdam20180209100733.azurewebsites.net/api/Dam/";
    static string BaseDamUrl = @"http://192.168.100.228/DashingDAM/api/Dam/";
    //static string BaseDamUrl = @"http://localhost:60201/api/Dam/";
    static string Token = "lpGPoFMIcGAAAAAAAAAAEqsb7NxYp_GcmMt2ED09HFIoupHrdw9qMz1HJ0qoa7Id";
    public void ProcessRequest(HttpContext context)
    {
		 var folderPath="";
        if (context.Request.Files.Count > 0)
        {
            try
            {
                WebClient client = new WebClient();
                HttpFileCollection files = context.Request.Files;
				folderPath=HttpUtility.UrlEncode(context.Request["folderPath"]);
                for (int i = 0; i < files.Count; i++)
                {
                    HttpPostedFile file = files[i];
                    string fname = System.IO.Path.GetFileName(file.FileName);
                    var binaryReader = new BinaryReader(file.InputStream);
                    var fileData = binaryReader.ReadBytes(file.ContentLength);
                    var apiUrl = string.Format("{0}/UploadFile?fileName={1}/{2}&token={3}",BaseDamUrl,folderPath,fname,Token);
                    client.UploadData(apiUrl, fileData);
                }
                context.Response.ContentType = "text/plain";
                context.Response.Write("No exception!!! File(s) Uploaded Successfully!");
            }
            catch (Exception e)
            {
                context.Response.Write("Error file upload" + e.Message);
            }

        }


    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}