local protoc = require("protoc")
local util = require("grpc-gateway.util")

local _M = {}

-- Create proto wrapped instance table
-- This table aims to manage to avoid duplicate loading,
-- deal with each proto in each instance table.
_M.new = function(proto_file)
  -- Check file existence
  if not util.file_exists(proto_file) then
    return nil, ("pb file: %s is not found"):format(proto_file)
  end
  local _p = protoc.new()
  -- We'd like to load inside pcall due to prevent duplicate load error
  pcall(function()
    _p:loadfile(proto_file)
  end)
  local instance = {}
  instance.get_loaded_proto = function()
    return _p.loaded
  end
  return instance
end

return _M
