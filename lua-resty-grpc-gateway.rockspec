package = "lua-resty-grpc-gateway"
version = "<TAG>-1"
source = {
   url = "git://github.com/ysugimoto/lua-resty-grpc-gateway.git",
   tag = "v<TAG>"
}
description = {
   homepage = "https://github.com/ysugimoto/lua-resty-grpc-gateway",
   license = "MIT",
   maintainer = "ysugimoto",
   summary = "Libray for transforming REST to gPRC request on Openresty"
}
dependencies = {
  "lua >= 5.1",
  "lua-protobuf"
}
build = {
   type = "builtin",
   modules = {
      ["grpc-gateway.proto"] = "grpc-gateway/proto.lua",
      ["grpc-gateway.request"] = "grpc-gateway/request.lua",
      ["grpc-gateway.response"] = "grpc-gateway/response.lua",
      ["grpc-gateway.util"] = "grpc-gateway/util.lua",
      ["grpc-gateway.cors"] = "grpc-gateway/cors.lua",
      ["grpc-gateway.polyfill"] = "grpc-gateway/polyfill.lua"
   }
}
