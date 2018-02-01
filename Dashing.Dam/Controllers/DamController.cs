using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace Dashing.Dam.Controllers
{
    public class DamController : ApiController
    {
        [HttpGet]
        public IHttpActionResult GetFolders()
        {
            return Ok(12345647);
        }
    }
}
