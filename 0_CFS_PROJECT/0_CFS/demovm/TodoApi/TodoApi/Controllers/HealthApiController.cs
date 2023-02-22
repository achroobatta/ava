using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace WebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class HealthApiController : ControllerBase
    {
       private static readonly string str = "{ \"Api_Resp\": \"Success Health/Probe from WebAPI\"  }";

        private readonly ILogger<HealthApiController> _logger;

        public HealthApiController(ILogger<HealthApiController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public string Get()
        {
                  return str;
        }
    }
}
