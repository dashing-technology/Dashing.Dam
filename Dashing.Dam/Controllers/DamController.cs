using System;
using Dashing.Dam.Models;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.Caching;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;
using Dropbox.Api;
using Dropbox.Api.Files;


namespace Dashing.Dam.Controllers
{
    public class DamController : ApiController
    {
       

        [HttpGet]
        public IHttpActionResult GetFolders(
            string token,
            string rootFolderPath)
        {
            var result = BuildFolderStructure(token, rootFolderPath);
            return Ok(result);
        }
        [HttpGet]
        [Route("api/Dam/Delete")]
        public IHttpActionResult Delete(
            string token,
            string path )
        {
            
            try
            {
                using (var dbx = new DropboxClient(token))
                {
                    DeleteResult result = dbx.Files.DeleteV2Async(path).Result;
                }

                return Ok();
            }
            catch (Exception e)
            {
                return BadRequest(e.Message);
            }
        }

        [HttpPost]
        public IHttpActionResult RenameFolder(
            string folderFrom, string folderTo, string token)
        {
            try
            {
                using (var dbx = new DropboxClient(token))
                {
                    var result = dbx.Files.MoveV2Async(folderFrom, folderTo).Result;

                }
                return Ok();
            }
            catch (Exception e)
            {
                return BadRequest(e.Message);
            }
        }
        [HttpPost]
        [Route("api/Dam/MoveFolder")]
        public IHttpActionResult MoveFolder(
            string folderFrom, string folderTo, string token)
        {
            try
            {
                using (var dbx = new DropboxClient(token))
                {
                    var result = dbx.Files.MoveV2Async(folderFrom, folderTo).Result;
                }
                return Ok();
            }
            catch (Exception e)
            {
                return BadRequest(e.Message);
            }
        }

        [HttpPost]
        [Route("api/Dam/CreateFolder")]
        public IHttpActionResult CreateFolder(
            string folderFullPath, string token)
        {
            try
            {
                using (var dbx = new DropboxClient(token))
                {
                   var result= dbx.Files.CreateFolderV2Async(folderFullPath).Result;
                    

                }
                return Ok();
            }
            catch (Exception e)
            {
                return BadRequest(e.Message);
            }
        }

        private List<Folder> BuildFolderStructure(string token,string folderName)
        {
            List<Folder> folders = null;
            if (!string.IsNullOrEmpty(folderName))
            {
                using (var dbx = new DropboxClient(token))
                {
                    //var test  = dbx.Files.ListFolderAsync(folderName,true).Result.Entries;
                    folders = dbx.Files.ListFolderAsync(folderName,true).Result.Entries
                        .Where(f=>f.IsFolder==true)
                        .Select(entry =>new Folder()
                            {
                                Id = entry.PathLower,
                                Parent = Path.GetDirectoryName(entry.PathLower)==@"\"?"#": Path.GetDirectoryName(entry.PathLower).Replace(@"\","/"),
                                Text = entry.AsFolder.Name
                            })
                        .ToList();
                }
            }

            return folders;
        }
        private List<Models.File> GetFilesByFolder(string token, string folderPath)
        {
            List<Models.File> files = null;
             if (!string.IsNullOrEmpty(folderPath))
             {
                using (var dbx = new DropboxClient(token))
                {
                    var format = new ThumbnailFormat();
                    var size = new ThumbnailSize();
                    files = dbx.Files.ListFolderAsync(folderPath).Result.Entries
                        .Where(f => f.IsFile == true)
                        .Select(entry => new Models.File()
                        {
                            Name = entry.Name,
                            Size = Decimal.Round(Convert.ToDecimal((entry.AsFile.Size / 1024f) / 1024f), 4),
                            Type = entry.Name.Substring(entry.Name.LastIndexOf('.')).ToLower(),
                            Id = entry.AsFile.Id,
                            FilePath = entry.AsFile.PathLower
                            //Thumbnail= Convert.ToBase64String(dbx.Files.GetThumbnailAsync(folderPath+"/"+entry.Name, format.AsJpeg, size.AsW64h64).Result.GetContentAsByteArrayAsync().Result)


                        })
                .ToList();
               

                }

            }
            return files;
        }

        [HttpGet]
        [Route("api/Dam/GetFiles")]
        public IHttpActionResult GetFiles(string token,
            string folderPath)
        {
            List<Models.File> result = GetFilesByFolder(token, folderPath);
            return Ok(result);
        }
      

        [HttpGet]
        [Route("api/Dam/GetDownloadLink")]
        public IHttpActionResult GetDownloadLink(string filePath, string token)
        {
            using (var dbx = new DropboxClient(token))
            {
                var downloadLink = "";
                try
                {
                    var response = dbx.Sharing.CreateSharedLinkWithSettingsAsync(filePath).Result;
                    downloadLink = response.Url.Replace("dl=0", "dl=1");
                }
                catch (Exception e)
                {
                    try
                    {
                        var result = dbx.Sharing.ListSharedLinksAsync(filePath).Result;
                        if (result?.Links?.Count > 0)
                        {
                            downloadLink = result.Links[0].Url.Replace("dl=0","dl=1");
                        }
                    }
                    catch (Exception exception)
                    {
                        return BadRequest(exception.Message);
                    }
                }

                return Ok(downloadLink);

            }
        }

        [HttpPost]
        [Route("api/Dam/UploadFile")]
        public async Task<IHttpActionResult> UploadFile(string fileName, string token)
        {
            Stream stream = null;
            try
            {
                stream = HttpContext.Current.Request.InputStream;
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                
            }
            
           
            try
            {
                FileMetadata result = null;
                using (var dbx = new DropboxClient(token))
                {
                    CommitInfo info = new CommitInfo(path: fileName) { };


                    result = await dbx.Files.UploadAsync(info, stream);
                }
                return Ok(result);
            }
            catch (Exception e)
            {
                return BadRequest(e.Message);
            }
        }

    }
}
