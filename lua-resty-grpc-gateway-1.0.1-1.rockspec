package = "lua-resty-grpc-gateway"
version = "1.0.1-1"
source = {
   url = "git+ssh://git@github.com/ysugimoto/lua-resty-grpc-gateway.git",
   tag = "v1.0.1"
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
      ["grpc-gateway.proto"] = "lib/proto.lua",
      ["grpc-gateway.request"] = "lib/request.lua",
      ["grpc-gateway.response"] = "lib/response.lua",
      ["grpc-gateway.util"] = "lib/util.lua",
      ["grpc-gateway.cors"] = "lib/cors.lua"
   }
}
