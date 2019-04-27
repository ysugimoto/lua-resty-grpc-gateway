local function log(level, message)
  print(level, message)
end

return function(method, queries, posts, headers)
  local req = {
    get_method = function() return method end,
    get_post_args = function() return posts or {} end,
    get_uri_args = function() return queries or {} end,
    get_body_data = function() return "" end,
    get_headers = function() return headers or {} end
  }
  return {
    req = req,
    log = log,
    arg = {},
    header = {}
  }
end


