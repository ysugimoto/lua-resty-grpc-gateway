local pb = require("pb")
local bit = require("bit")
local util = require("grpc-gateway.util")

local _M = {}

-- grpc-gateway.request is used for request transforming from REST to gRPC.
-- The request transforming steps are:
--   1. Force set request method as POST
--   2. Set request path to /[gRPC Service]/[gRPC Method]
--   3. Drop all query strings
--   4. Set request body as gRPC encoded binary stream
--
-- This module shoud be used on `access_by_lua_*` phase
_M.new = function(proto)
  local instance = {}
  instance.transform = function(self, service, method, default_values)
    -- Find service method from loaded proto definitions
    local m = util.find_method(proto, service, method)
    if not m then
      return ("Undefined service method: %s/%s"):format(service, method)
    end

    -- Ensure erquest body has been read
    ngx.req.read_body()
    -- Create an internal lua table containing the raw userdata which will be used for processing
    local default_values = util.populate_default_values()
    -- Build request binary as method input type from request data (query string, post body, or JSON body)
    local encoded = pb.encode(m.input_type, util.map_message(m.input_type, default_values or {}))
    local size = string.len(encoded)
    -- Prepend gRPC specific prefix data
    -- request is compressed (always 0)
    -- request body size (4 bytes)
    local prefix = {
      string.char(0),
      string.char(bit.band(bit.rshift(size, 24), 0xFF)),
      string.char(bit.band(bit.rshift(size, 16), 0xFF)),
      string.char(bit.band(bit.rshift(size, 8), 0xFF)),
      string.char(bit.band(size, 0xFF))
    }
    local message = table.concat(prefix, "") .. encoded
    -- Transform request
    ngx.req.set_method(ngx.HTTP_POST)
    ngx.req.set_uri(("/%s/%s"):format(service, method), false)
    ngx.req.set_uri_args({})
    ngx.req.init_body(string.len(message))
    ngx.req.set_body_data(message)
    return nil
  end

  return instance
end

return _M
