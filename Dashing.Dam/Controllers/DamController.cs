using System;
using Dashing.Dam.Models;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Caching;
using System.Threading.Tasks;
using System.Web.Http;
using Dropbox.Api;



namespace Dashing.Dam.Controllers
{
    public class DamController : ApiController
    {
        List<Folder> folders = new List<Folder>();

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
            BuildFolderStructure(token, rootFolderPath);
            //MemoryCache.Default.Add(token + rootFolderPath, folders, DateTimeOffset.UtcNow.AddHours(5));
            return Ok(folders);
            //}

        }


        private void BuildFolderStructure(string token,string folderName,string parentId = "#")
        {
            if (!string.IsNullOrEmpty(folderName))
            {
                using (var dbx = new DropboxClient(token))
                {
                    var topLevelFolders = dbx.Files.ListFolderAsync(folderName).Result;
                    foreach (var entry in topLevelFolders.Entries.Where(folder => folder.IsFolder))
                    {
                        folders.Add(new Folder(){Id = entry.AsFolder.Id,Parent = parentId, Text = entry.AsFolder.Name});
                        BuildFolderStructure(token,entry.PathDisplay,entry.AsFolder.Id);
                    }
                }
            }
        }
    }
}
