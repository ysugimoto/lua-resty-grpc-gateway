# Example of lua-resty-grpc-gateway

This is grpc-web gateway example with helloworld.

## Requirements

- Go (gRPC backend app)
- nodejs (gRPC frontend app)
- protoc related commands:
  - [protobuf](https://github.com/protocolbuffers/protobuf/releases)
  - [protoc-gen-grpc-web](https://github.com/grpc/grpc-web/releases)
  - [protoc-gen-go-grpc](https://github.com/grpc/grpc-go)
  - [protoc-gen-go](https://github.com/protocolbuffers/protobuf-go)
- Docker and docker-compose

## How to build

### Build protbuf and backend app

```
make all
```

### Run backend and gateway container via docker-compose

```
docker-compose up -d --build
```

The gateway container run on `:9000`, and you cannot access to backend app without gateway.

### Run client server

Client uses simple grpc-web interface.

```
cd client
yarn install
yarn start
```

The client app will start on `:8080`, and will open browser automatically.
If grpc-web request sent successfully (maybe it's not due to browser implementation), you can see `Hello, grpc-web with gateway!` message in content.

### Get gRPC response via REST interface

gateway container also accepts REST interface:

```
curl -vv -H "Content-Type: application/json" -d '{"displayName":"grpc-rest", "ex":[{"displayName":"test", "foo":{"grades":[1,2,3]}}, {"displayName":"test2","foo":{"grades":[97,98,99]}}], "jobs":["A","B"], "color":"BLUE"}' "http://localhost:9000/rest"
>> {"reply_at":{"seconds":1575473082,"nanos":0},"message":"Hello, grpc-rest!"}
```

This response is made through the gateway as REST, proxy to backend with gRPC request, and transform to JSON.
