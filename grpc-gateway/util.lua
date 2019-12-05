local pb = require("pb")
local json
if not os.getenv("LUAUNIT") then
  json = require("cjson")
end

local _M = {}

_M.file_exists = function(file)
  local fp = io.open(file, "r")
  if fp then
    fp:close()
    return true
  end
  return false
end

_M.find_method = function(proto, service, method)
  local protos = proto.get_loaded_proto()
  for k, loaded in pairs(protos) do
    if type(loaded) == "boolean" then
      ngx.log(ngx.ERR, k)
    end
    local package = loaded.package
    for _, s in ipairs(loaded.service or {}) do
      if ("%s.%s"):format(package, s.name) == service then
        for _, m in ipairs(s.method) do
          if m.name == method then
            return m
          end
        end
      end
    end
  end

  return nil
end

-- Responsible for filling the default_values table during the inital request
-- This should be called only once
_M.populate_default_values = function()
  local default_values = {}
  if ngx.req.get_method() == "POST" then
    if string.find(ngx.req.get_headers()["Content-Type"] or "", "application/json") then
      default_values = json.decode(ngx.req.get_body_data())
    else
      default_values = ngx.req.get_post_args()
    end
  else
    default_values = ngx.req.get_uri_args()
  end
  return default_values
end

-- Converts the incomming value based on the protobuf field type
local function set_value_type(name, kind, request_table)
  local prefix = kind:sub(1, 3)
  if prefix == "str" then
    return request_table[name] or nil
  elseif prefix == "int" then
    if request_table[name] then
      return tonumber(request_table[name])
    else
      return nil
    end
  end
  return nil
end

_M.map_message = function(field, default_values)
  if not pb.type(field) then
    return nil, ("Field %s is not defined"):format(field)
  end

  local request = {}
  for name, _, field_type,_,lbl in pb.fields(field) do
    -- Find the actual type of field (enum,message, or map)
    local _,_, actualType = pb.type(field_type)

    if field_type:sub(1, 1) == "." then
      
      -- If a request contains nested messages and make use of the 'repeated' protobuf label we may have to iterate over each inner element 
      -- For each pair of key/values in the table we will recurse and set the correct type of the data i.e string or int and construct the lua request table as normal
      if lbl == "repeated" then
        request[name] = {}
        for _,value in ipairs(default_values[name] or {}) do
         sub, err = _M.map_message(field_type, value)
         if err then
           return nil, err
         end
         table.insert(request[name],sub)
       end
      -- Add support for a enum type, if the default values[name] contains a enum value that is non-existant in the enum definition from the proto file we simply ignore it
      -- Note that enum values can be either string or int from the json that is passed in.
      elseif actualType == "enum" then
        local value = pb.enum(field_type,default_values[name])
        if value ~= nil then
          request[name] = value
        end
     else
       sub, err = _M.map_message(field_type, default_values[name] or {})
       if err then
         return nil, err
       end
       request[name] = sub
     end
    else
      request[name] = set_value_type(name,field_type,default_values) or default_values[name]  or nil
    end
  end
  return request, nil
end

return _M
