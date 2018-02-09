using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Dropbox.Api;

namespace DAM_User_Control
{
    public class DropboxFiles
    {
        private string assetName;
        private string assetType;
        private string fileSize;
        private string assetSize;
        private string imageURL;

        public string ImageURL
        {
            get { return imageURL; }
            set { imageURL = value; }
        }

        public string AssetName
        {
            get { return assetName; }
            set { assetName = value; }
        }
        public string AssetType
        {
            get { return assetType; }
            set { assetType = value; }
        }
        public string FileSize
        {
            get { return fileSize; }
            set { fileSize = value; }
        }
        public string AssetSize
        {
            get { return assetSize; }
            set { assetSize = value; }
        }
        
    }

}