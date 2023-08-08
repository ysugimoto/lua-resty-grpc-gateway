DOCKER_COMPOSE ?= docker compose

all: proto server

clean:
	$(RM) -r server/helloworld
	$(RM) -r client/helloworld

prepare:
	mkdir -p server/helloworld
	mkdir -p client/helloworld

proto: helloworld.proto prepare
	protoc --proto_path=./ $< \
		--go_out=./server/helloworld \
		--go_opt=paths=source_relative \
		--go_opt=M$<=helloworld/ \
		--go-grpc_out=./server/helloworld \
		--go-grpc_opt=paths=source_relative \
		--go-grpc_opt=M$<=helloworld/ \
		--grpc-web_out=import_style=commonjs+dts,mode=grpcweb:./client/helloworld \
		--js_out=import_style=commonjs:./client/helloworld

server: proto
	cd server && \
	CGO_ENABLED=0 go build -o app

docker: proto
	$(DOCKER_COMPOSE) up -d --build

.PHONY: all clean prepare proto server docker
