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

    local chunk, eof = ngx.arg[1], ngx.arg[2]
    local buffered = ngx.ctx.buffered
    if not buffered then
      buffered = {}
      ngx.ctx.buffered = buffered
    end
    if chunk ~= "" then
      buffered[#buffered + 1] = chunk
      ngx.arg[1] = nil
    end

    if eof then
      ngx.ctx.buffered = nil
      local buffer = table.concat(buffered)
      -- Important:
      -- Strip first 5 bytes from response body to make sure pb.decode() works correctly
      -- But if request comes from gRPC-Web, this bytes are necessary for client...
      if not ngx.req.get_headers()["X-Grpc-Web"] then
        buffer = string.sub(buffer, 6)
      end

      local decoded = pb.decode(m.output_type, buffer)
      local response = json.encode(decoded)
      ngx.arg[1] = response
    end
  end

  return instance
end

return _M
