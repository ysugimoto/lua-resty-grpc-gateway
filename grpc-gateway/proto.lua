local protoc = require("protoc")
local util = require("grpc-gateway.util")

local _M = {}

-- Create proto wrapped instance table
-- This table aims to manage to avoid duplicate loading,
-- deal with each proto in each instance table.
--   @string proto_file - target proto file 
--   @table args - extra append import path
_M.new = function(proto_file, ...)
  -- Check file existence
  if not util.file_exists(proto_file) then
    return nil, ("pb file: %s is not found"):format(proto_file)
  end

  local _p = protoc.new()
  -- default as current directory which placed proto file
  local import_paths = {"."}
  -- use global defined import paths. for example, it defined at init_lua_xxx
  for _, v in ipairs(PROTOC_IMPORT_PATHS or {}) do
    table.insert(import_paths, v)
  end
  -- and also append extra import paths from function arguments
  for _, v in ipairs({...}) do
    table.insert(import_paths, v)
  end
  _p.paths = import_paths
  -- and protoc library should resolve imports automatically.
  _p.include_imports = true

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
