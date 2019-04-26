# lua-resty-grpc-gateway

This package provides request transformation between REST &lt;-&gt; gRPC with [Openresty](https://openresty.org/).

## Motivation

Nginx supports `grpc-web` proxy since version 1.13.0, and Openresty 1.5.8.1rc1 uses Nginx core 1.15.8.

But it cannot proxy with REST interface, so we'd like to support it with minimum Lua script support like [grpc-gateway](https://github.com/grpc-ecosystem/grpc-gateway).

This just work for simple gateway, so you don't bound by golang. You can choose gRPC backend which built with any language!

## Requirement

- Openresty 1.15.8.1rc1 or later

## Installation

You can install via `luarocks`.

```
luarocks install lua-resty-grpc-gateway
```

## Important

Note that nginx grpc gateway accepts only `grpcweb` mode, not `grpcwebtext`.
So make sure protobuf file is compiled with `--grpc-web_out=import_style=xxx,mode=grpcweb:$OUT_DIR`.

## Usage for simple grpc-web gateway

This is same as nginx's example. see [nginx documentration](https://www.nginx.com/blog/nginx-1-13-10-grpc/)

## Usage for REST to gRPC

In order to trasnform from REST to gRPC completely, need to use three hook points:

- `access_by_lua_*` for transform REST to gRPC request format
- `body_filter_by_lua_* ` for transform from gRPC binary response to JSON format
- `header_filter_by_lua_*` add `Content-Type: application/json` response header

Following code is full of examples:

### nginx.conf

```lua
server {
  listen 80;
  server_name localhost;

  location /some-rest-endpoint {

## 1. Transform request from REST to gRPC
    access_by_lua_block {
      local proto = require("grpc-gateway.proto")
      local grequest = require("grpc-gateway.request")
      local p, err = proto.new("/etc/proto/helloworld.proto")
      if err then
        ngx.log(ngx.ERR, ("proto load error: %s"):format(err))
        return
      end
      local req = grequest.new(p)
      err = req:transform("helloworld.Greeter", "SayHello")
      if err then
        ngx.log(ngx.ERR, ("trasnform request error: %s"):format(err))
        return
      end
    }

## 2. Transform response from gPRC to JSON
    body_filter_by_lua_block {
      local proto = require("grpc-gateway.proto")
      local gresponse = require("grpc-gateway.response")
      local p, err = proto.new("/etc/proto/helloworld.proto")
      if err then
        ngx.log(ngx.ERR, ("proto load error: %s"):format(err))
        return
      end
      local resp = gresponse.new(p)
      err = resp:transform("helloworld.Greeter", "SayHello")
      if err then
        ngx.log(ngx.ERR, ("trasnform request error: %s"):format(err))
        return
      end
    }

## 3. Swap response header to `Content-Type: application/json`
    header_filter_by_lua_block {
      ngx.header["Content-Type"] = "application/json"
    }

    grpc_set_header Content-Type application/grpc;
    grpc_pass localhost:9000;
  }
}
```

### helloworld.proto

```protobuf
syntax = "proto3";

package helloworld;

service Greeter {
  rpc SayHello (HelloRequest) returns (HelloReply) {}
}

message HelloRequest {
  string name = 1;
}

message HelloReply {
  string message = 1;
}
```

See completely [example](https://github.com/ysugimoto/lua-resty-grpc-gateway/tree/master/example) for actual working.

## License

MIT

## Author

Yoshiaki Sugimoto


