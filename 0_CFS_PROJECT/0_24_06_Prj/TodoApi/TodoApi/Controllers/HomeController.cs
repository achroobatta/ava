using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;

namespace TodoApi.Controllers
{
    [Route("api1/Callapi")]
    public class HomeController : ControllerBase
    {
        [HttpGet]
        public async Task<IActionResult> Callapi()
        {
            using (var client = new HttpClient())
            {

                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Basic", "ZGVtb3VzcjpBZG1pbmlzdHJhdG9yQDg5MA==");
                client.BaseAddress = new Uri("http://52.147.207.80:100/");

                var response = await client.GetAsync("api2/weatherforecast");
            
                var responseContent = response.Content.ReadAsStringAsync().Result;
                response.EnsureSuccessStatusCode();
                return Ok(responseContent);

            
            }
        }
    }
}
