-- This module is used for sending common CORS response header.
return function(origin)
  if not origin then
    origin = "*"
  end

  -- Pre-flight response
  if ngx.req.get_method() == "OPTIONS" then
    ngx.header["Access-Control-Allow-Origin"] = origin
    ngx.header["Access-Control-Allow-Methods"] = "GET,POST,OPTIONS"
    ngx.header["Access-Control-Allow-Headers"] = "Keep-Alive,Cache-Control,Content-Type,Content-Transfer-Encoding,X-User-Agent,X-Grpc-Web"
    ngx.header["Access-Control-Max-Age"] = 1728000
    ngx.header["Content-Type"] = "text/plain; charset=utf-8"
    ngx.header["Content-Length"] = 0
    ngx.exit(ngx.HTTP_NO_CONTENT)
    return
  end

  -- Actual POST request
  ngx.header["Access-Control-Allow-Origin"] = origin
  ngx.header["Access-Control-Allow-Methods"] = "GET,POST,OPTIONS"
  ngx.header["Access-Control-Allow-Headers"] = "Keep-Alive,Cache-Control,Content-Type,Content-Transfer-Encoding,X-User-Agent,X-Grpc-Web"
  ngx.header["Access-Control-Expose-Headers"] = "X-User-Agent,X-Grpc-Web,Grpc-Message,Grpc-Status"
end
