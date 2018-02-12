using System;
using Dashing.Dam.Models;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.Caching;
using System.Threading.Tasks;
using System.Web.Http;
using Dropbox.Api;
using Dropbox.Api.Files;


namespace Dashing.Dam.Controllers
{
    public class DamController : ApiController
    {
       

        [HttpGet]
        public IHttpActionResult GetFolders(
            string token = "lpGPoFMIcGAAAAAAAAAAEqsb7NxYp_GcmMt2ED09HFIoupHrdw9qMz1HJ0qoa7Id",
            string rootFolderPath = "/Red Rooster")
        {

            //var ca = db.tblTags;
            //memCache.Add("tag", ca, DateTimeOffset.UtcNow.AddMinutes(5));
            //return db.tblTags;
            //var cachedFolders = MemoryCache.Default.Get(token + rootFolderPath);
            //if (cachedFolders != null)
            //{
            //    return Ok((List<Folder>)cachedFolders);
            //}
            //else
            //{
            var result = BuildFolderStructure(token, rootFolderPath);
            //MemoryCache.Default.Add(token + rootFolderPath, folders, DateTimeOffset.UtcNow.AddHours(5));
            return Ok(result);
            //}

        }
        [HttpDelete]
        public IHttpActionResult DeleteFolder(
            string token = "lpGPoFMIcGAAAAAAAAAAEqsb7NxYp_GcmMt2ED09HFIoupHrdw9qMz1HJ0qoa7Id",
            string folderPath = "/Red Rooster")
        {
            DeleteResult result = null;
            try
            {
                using (var dbx = new DropboxClient(token))
                {
                    result = dbx.Files.DeleteV2Async(folderPath).Result;

                }

                return Ok();
            }
            catch (Exception e)
            {
                return BadRequest();
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
        [HttpGet]
        [Route("GetFiles")]
        public List<Models.File> GetFiles(string token, string folderPath)
        {
            List<Models.File> files = null;
            List<Models.File> fileMetadata = null;

            if (!string.IsNullOrEmpty(folderPath))
            {

                using (var dbx = new DropboxClient(token))
                {
                    // var test = dbx.Files.GetThumbnailAsync(folderPath).Result;
                    files = dbx.Files.ListFolderAsync(folderPath).Result.Entries
                        .Where(f => f.IsFile == true)
                        .Select(entry => new Models.File()
                        {
                            Name = entry.Name,
                            Size = entry.AsFile.Size,
                            Type = entry.Name.Substring(entry.Name.Length - 3)


                        })
                        .ToList();
                }
            }
            // foreach (var file in files)
            //{
            //    using (var dbx = new DropboxClient(token))
            //    {
            //        var thumb = dbx.Files.GetThumbnailAsync(folderPath + "/" + file.Name).Result.Response.AsFile;
            //            //files.ty

            //            //.Where(f => f.IsFile == true)
            //            //.Select(entry => new Models.File()
            //            //{
            //            //    Name = entry.Name,
            //            //    Size = entry.AsFile.Size,
            //            //})
            //            //.ToList();
            //    }
            //}
            return files;


        }
    }
}
