using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;

namespace Dashing.Dam.Models
{
    public class File
    {
        public string Name { get; set; }
        public decimal Size { get; set; }
        public string Type { get; set; }
        public string FilePath { get; set; }


        public string Id { get; set; }
        public string Thumbnail { get; set; }
    }
}