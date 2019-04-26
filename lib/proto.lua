local protoc = require("protoc")
local util = require("grpc-gateway.util")

local _M = {}

_M.new = function(proto_file)
  if not util.file_exists(proto_file) then
    return nil, ("pb file: %s is not found"):format(proto_file)
  end
  local _p = protoc.new()
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
