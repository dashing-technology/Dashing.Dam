using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebApplication12
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            //for (int i = 0; i < 1000; i++)
            //{
            //    var randomSalt = Regex.Replace(System.Web.Security.Membership.GeneratePassword(64, 0), @"[^a-f0-9]", m => "").Substring(0, 8);
            //    Response.Write(randomSalt + "<br />");
            //}
            
        }

        private string GetRandomHexNumber(int digits)
        {
            Random random = new Random();
            byte[] buffer = new byte[digits / 2];
            random.NextBytes(buffer);
            string result = String.Concat(buffer.Select(x => x.ToString("X2")).ToArray());
            if (digits % 2 == 0)
                return result;
            return result + random.Next(16).ToString("X");
        }
    }
}