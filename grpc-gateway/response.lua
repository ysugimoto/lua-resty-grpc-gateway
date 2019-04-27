local pb = require("pb")
local json = require("cjson")
local util = require("grpc-gateway.util")

local _M = {}

-- grpc-gateway.response is used for convering from gRPC binary response to JSON body.
-- The response transforming steps are:
--   1. Read all response body from gPRC backend
--   2. Decode from specified service method to Lua table
--   3. Encode to JSON
--
-- This module shoud be used on `body_filter_by_lua_*` phase
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
