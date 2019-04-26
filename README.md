# lua-resty-grpc-gateway

This package provides request transformation between REST &lt;-&gt; gRPC with [Openresty](https://openresty.org/).

## Motivation

Nginx supports `grpc-web` proxy since version 1.13.0, and Openresty 1.5.8.1rc1 uses Nginx core 1.15.8.

But it cannot proxy with REST interface, so we'd like to support it with minimum Lua script support like [grpc-gateway](https://github.com/grpc-ecosystem/grpc-gateway).

This just work for simple gateway, so you don't bound by golang. You can choose gRPC backend which built with any language!

For grpc-web detail, see [grpc-web Repository](https://github.com/grpc/grpc-web).

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

This is same as nginx's example. see [nginx documentation](https://www.nginx.com/blog/nginx-1-13-10-grpc/)

## Usage for REST to gRPC

In order to trasnform from REST to gRPC completely, you need to use three of hook points:

- `access_by_lua_*` to transform REST to gRPC request format
- `body_filter_by_lua_* ` to transform from gRPC binary response to JSON format
- `header_filter_by_lua_*` add `Content-Type: application/json` response header

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

See complete [example](https://github.com/ysugimoto/lua-resty-grpc-gateway/tree/master/example) for actual working.

## Request transforming

```lua
-- load protobuf wrapper and request transformer
local proto = require("grpc-gateway.proto")
local request = require("grpc-gateway.request")

-- First, instantiate protobuf wrapper with destination pb file
local p, err = proto.new("/path/to/proto.file")
if err then
  print(err) -- err is not null if file not found or something
end

-- Second, instatiate request with protobuf instance
local r = request.new(p)

-- Third, call transform() method. transform() method arguments are:
--   first argument is service name (contains package name if you defined)
--   second argument is RPC method name
-- In this case, package will transform to helloworld.Greeter/SayHello request format of HelloRequest
err = r:transform("helloworld.Greeter", "SayHello")
if err then
  print(err) -- err is not null if failed to transform request
end
```

REST to gRPC request transformation supports `GET` and `POST` request methods, it means gRPC message is built from either of:

- `GET`: use query string
- `POST`: use post fields
- `JSON POST`: use decoded JSON request body

For instance:

```
message HelloRequest {
  string name = 1;
}
```

For above message structure, `name` field will be assigned by either of following way:

```
GET /?name=example
```

```
POST /

name=example
```

```
POST /
Content-Type: application/json

{"name":"example"}
```

You *DO NOT* specify all fields as empty, otherwise gateway will respond error.

```
GET /
>> error
```

## Response transforming

```lua
-- load protobuf wrapper and response transformer
local proto = require("grpc-gateway.proto")
local response = require("grpc-gateway.response")

-- First, instantiate protobuf wrapper with destination pb file
local p, err = proto.new("/path/to/proto.file")
if err then
  print(err) -- err is not null if file not found or something
end

-- Second, instatiate response with protobuf instance
local r = response.new(p)

-- Third, call transform() method as same as request:
--   first argument is service name (contains package name if you defined)
--   second argument is RPC method name
-- In this case, package will transform to helloworld.Greeter/SayHello response format of HelloReply
err = r:transform("helloworld.Greeter", "SayHello")
if err then
  print(err) -- err is not null if failed to transform response
end
```

And, to pass a request to gRPC backend, nginx need to set `Content-Type` as `application/grpc`, then this header will be kept to REST response.

To avoid it, you need to swap this header on `header_filter_by_lua_*` phase:

```lua
header_filter_by_lua_block {
  ngx.header["Content-Type"] = "application/json"
}
```

Otherwise, REST HTTP response's `Content-Type` becomes `application/grpc`. Normally it's a bad way of process response (e.g. show download dialog on browser)

## CORS support

This package includes sending CORS headers for grpc-web request from other origin.

```
local cors = require("grpc-gateway.cors")
cors("http://localhost:8080") -- or cors() to set "*"
```

## License

MIT

## Author

Yoshiaki Sugimoto


