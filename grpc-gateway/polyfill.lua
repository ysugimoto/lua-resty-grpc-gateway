return function()
  -- nginx's gRPC proxy supports only grpcweb protocol whose request body accepts only binary proto format.
  -- So if user requests with 'Content-Type: application/grpc-web-text', we need to decode request body as binary.
  if ngx.req.get_headers()["Content-Type"] == "application/grpc-web-text" then
    ngx.req.read_body()
    local body = ngx.req.get_body_data()
    local decoded, err = ngx.decode_base64(body)
    if err then
      ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
      ngx.say("Failed to decode base64 body for grpc-web-text protocol")
      ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
      return
    end
    ngx.req.set_body_data(decoded)
  end
end
