[![CircleCI](https://circleci.com/gh/ysugimoto/lua-resty-grpc-gateway.svg?style=svg)](https://circleci.com/gh/ysugimoto/lua-resty-grpc-gateway)

# lua-resty-grpc-gateway

This package provides request transformation between REST &lt;-&gt; gRPC with [Openresty](https://openresty.org/).

## Motivation

Nginx supports `grpc-web` proxy since version 1.13.0, and Openresty 1.15.8.1 uses Nginx core 1.15.8.

But it cannot proxy with REST interface, so we'd like to support it with minimum Lua script support like [grpc-gateway](https://github.com/grpc-ecosystem/grpc-gateway).

This just work for simple gateway, so you don't bound by golang. You can choose gRPC backend which built with any language!

For grpc-web detail, see [grpc-web Repository](https://github.com/grpc/grpc-web).

## Requirement

- Openresty 1.15.8.1 or later

## Installation

You can install via `luarocks`.

```
luarocks install lua-resty-grpc-gateway
```

## Important for gRPC-Web proxy

Note that nginx grpc gateway accepts only `grpcweb` mode, not `grpcwebtext`.
So usually you should compile protobuf with `--grpc-web_out=import_style=xxx,mode=grpcweb:$OUT_DIR`.

But this package also support `grpcwebtext` mode for simply using gRPC-Web proxy :v: If you want to use this mode, use polyfill.

See [polyfill-grpc-web-text-mode](https://github.com/ysugimoto/lua-resty-grpc-gateway#polyfill-grpc-web-text-mode) section.

## Usage for simple gRPC-Web gateway

This is same as nginx's example. see [nginx documentation](https://www.nginx.com/blog/nginx-1-13-10-grpc/)

## Usage for REST to gRPC

In order to transform from REST to gRPC completely, you need to use three of hook points:

- `access_by_lua_*` to transform REST to gRPC request format
- `body_filter_by_lua_* ` to transform from gRPC binary response to JSON format
- `header_filter_by_lua_*` add `Content-Type: application/json` response header

### nginx.conf

```lua
## 0. prepare proto file import_paths
init_by_lua_block {
  PROTOC_IMPORT_PATHS = {
    "/usr/local/include"
  }
}

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
        ngx.log(ngx.ERR, ("transform request error: %s"):format(err))
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
        ngx.log(ngx.ERR, ("transform response error: %s"):format(err))
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

## Import paths

One of important thing, in this package, you should define `import_paths` which is set when load exteral/additional proto files in your proto file.

For instance:

```protobuf
syntax = "proto3";

package helloworld;

// import dependent proto file
import "google/protobuf/timestamp.proto";

service Greeter {
  rpc SayHello (HelloRequest) returns (HelloReply) {}
}

message HelloRequest {
  string name = 1;
}

message HelloReply {
  string message = 1;
  // message which defiened at imported package
  google.protobuf.Timestamp reply_at = 2;
}
```

import `google/protobuf/timestamp.proto` and use `google.protobuf.Timestamp` message struct on above. Then, you need to defined import_path by following ways:

#### define `PROTOC_IMPORT_PATHS` as global table

This package will use if `PROTOC_IMPORT_PATHS` variable is declared as global. we recommend that `init_by_lua_block` is good for you.

```lua
init_by_lua_block {
  PROTOC_IMPORT_PATHS = {
    "/usr/local/include",
    ...
  }
}
```

#### pass extra import_path to `protoc.new`

If you add more import_paths for specific package or temporarily, you can pass second or after argument on `protoc.new`.

```lua
local p = protoc.new("/etc/proto/helloworld.proto", "/usr/local/include", ...)
...
```

These two cases will works fine. imported packages resolved automatically by following import_paths. [Example](https://github.com/ysugimoto/lua-resty-grpc-gateway/tree/master/example) also uses import statment, please check it.

## CORS support

This package includes sending CORS headers for grpc-web request from other origin.

```
local cors = require("grpc-gateway.cors")
cors("http://localhost:8080") -- or cors() to set "*"
```

## Polyfill grpc-web-text mode

When you compiled protobuf with `--grpc-web_out=import_style=xxx,mode=grpcwebtext:$OUT_DIR`, grpc-web will reqeust as grpc-web-text mode.

In default, nginx can proxy only `application/grpc-web+proto` which means request body will come as binary,
but nginx cannot proxy `application/grpc-web-text` Content-Type because request body will come as base64-encoded string, then it cannot decode in nginx itself.

So this package also provide a tiny polyfill:

```lua
location / {
  access_by_lua_block {
    local polyfill = require("grpc-gateway.polyfill")
    polyfill()
  }

  grpc_pass localhost:9000;
}
```

By calling `polyfill()` , grpc-web-text mode will be succeed to proxy to backend.

## Supported types and definitions

lua-resty-grpc presently supports the following definitions in a given proto file. Other definitions have not been explicitly tested.

This project follows the canonical encoding from JSON to gRPC see [json-mapping](https://developers.google.com/protocol-buffers/docs/proto3#json) for a guide on how to encode your inputs for use with this plugin.

### Scalar types
* string
* int32/64

```protobuf
syntax = "proto3";

package helloworld;

service Greeter {
  rpc SayHello (HelloRequest) returns (HelloReply) {}
}

message HelloRequest {
  string name = 1;
  int64 age = 2;
}
```

```
GET /?name=test&age=30
```

OR 

```
POST /
Content-Type: application/json

{"name":"test","age":30}
```

### Arrays (repeated label)
```protobuf
syntax = "proto3";

package helloworld;

service Greeter {
  rpc SayHello (HelloRequest) returns (HelloReply) {}
}

message HelloRequest {
  repeated int32 grades =1;
}
```
The corresponding POST request is as follows:

```
POST /
Content-Type: application/json
{"grades":[97,98,99]}
```

### Nested message types

Since everything in gRPC is built using the `message` construct, naturally we want to be able to define several and then nest them to create more complex messages.

```protobuf
syntax = "proto3";
package helloworld;

service Greeter {
  rpc SayHello (HelloRequest) returns (HelloReply) {}
}

message HelloRequest {
  repeated ComplexMsg ex = 2;
}

message ComplexMsg {
  string displayName = 1;
  YetAnotherNestedMsg foo = 2;
}
```

The corresponding POST request is as follows:

```
POST /
Content-Type: application/json
{"ex":[{"displayName":"test", "foo":{"grades":[1,2,3]}}, {"displayName":"test2","foo":{"grades":[97,98,99]}}]}
```


### Enum
```protobuf
syntax = "proto3";

enum ColorType {
    RED = 0;
    GREEN = 1;
    BLUE = 2;
}

message HelloRequest {
  ColorType color = 1;
}
```

Note: you can use either the enumerated value as a `String` or it's equivalent `Int`. For example: `GREEN` or `1`. If you use a value that is not defined by the enum, the lua-resty-grpc package simply ignores it. 

The corresponding GET and POST requests to the gateway using an `enum` is as follows.

```
GET /?color=GREEN
```

OR

```
GET /?color=1
```

```
POST /
Content-Type: application/json

{"color":"BLUE"}
```

OR

```
POST /
Content-Type: application/json

{"color":2}
```

## Testing using cURL


For quick testing of the lua-resty-grpc-gateway once it is up and running

GET

Given the following proto file

```protobuf
syntax = "proto3";

package helloworld;

import "google/protobuf/timestamp.proto";

service Greeter {
  rpc SayHello (HelloRequest) returns (HelloReply) {}
}

message HelloRequest {
  string displayName = 1;
}

message HelloReply {
  string message = 1;
  google.protobuf.Timestamp reply_at = 2;
}
```

`curl -vv http://localhost:9000/rest?displayName=gRPCTest`

POST

Given the following proto file

```protobuf
syntax = "proto3";

package helloworld;

import "google/protobuf/timestamp.proto";

service Greeter {
  rpc SayHello (HelloRequest) returns (HelloReply) {}
}

enum Color {
  RED = 0;
  BLUE = 1;
  GREEN = 2;
}

message HelloRequest {
  string displayName = 1;
  repeated ComplexMsg ex = 2; /** Example of nested message type**/
  repeated string jobs = 3;
  Color color = 4; /**Example of a enum**/
}

message ComplexMsg {
  string displayName = 1;
  YetAnotherNestedMsg foo = 2;
}

message YetAnotherNestedMsg {
  repeated int32 grades = 1;
}

message HelloReply {
  string message = 1;
  google.protobuf.Timestamp reply_at = 2;
}
```

`curl -vv -H "Content-Type: application/json" -d '{"displayName":"grpc-rest", "ex":[{"displayName":"test", "foo":{"grades":[1,2,3]}}, {"displayName":"test2","foo":{"grades":[97,98,99]}}], "jobs":["A","B"], "color":"GREEN"}' "http://localhost:9000/rest"`

## Known limitations

The underlying lua-protobuf library is used to encode and decode the lua tables, as such anything that this library does not support consequently this package can not support it either. 

One currently known limitation is the use of annotations/options in the proto files. Specfically inside the `rpc`

## License

MIT

## Contributors

- [ysugimoto](https://github.com/ysugimoto)
- [kgoguevgoget](https://github.com/kgoguevgoget)


