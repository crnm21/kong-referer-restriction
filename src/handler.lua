local BasePlugin = require "kong.plugins.base_plugin"
local checks = require "kong.plugins.kong-referer-restriction.checks"

local HttpFilterHandler = BasePlugin:extend()


-- handle redirect after ip-restriction, bot-detection, cors - but before jwt and other authentication plugins
-- see https://docs.konghq.com/0.14.x/plugin-development/custom-logic/
HttpFilterHandler.PRIORITY = 1002


function HttpFilterHandler:new()
  HttpFilterHandler.super.new(self, "kong-referer-restriction")
end

function HttpFilterHandler:access(conf)
  HttpFilterHandler.super.access(self)

  if not checks.is_allowed_referer(ngx.req.get_headers()["Referer"], conf.allowed_referer_patterns) then
    return kong.response.exit(403, "Access Forbidden", {
      ["Content-Type"] = "text/plain",
      ["WWW-Authenticate"] = "Basic"
    })
  end
end

return HttpFilterHandler
