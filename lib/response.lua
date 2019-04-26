local pb = require("pb")
local json = require("cjson")
local util = require("grpc-gateway.util")

local _M = {}

_M.new = function(proto)
  local instance = {}
  instance.transform = function(self, service, method)
    local m = util.find_method(proto, service, method)
    if not m then
      return ("Undefined service method: %s/%s"):format(service, method)
    end

    local buffer = ngx.ctx.response_buffer or ""
    buffer = buffer .. ngx.arg[1]
    if ngx.arg[2] then
      local decoded = pb.decode(m.output_type, buffer)
      local response = json.encode(decoded)
      ngx.arg[1] = response
    else
      -- buffering
      ngx.ctx.response_buffer = buffer
      ngx.arg[1] = ""
    end
  end

  return instance
end

return _M
