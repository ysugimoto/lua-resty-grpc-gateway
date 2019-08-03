.PHONY: proto all helloworld.proto prepare docker

all: proto server

proto: helloworld.proto

clean:
	rm server/helloworld/*.go
	rm client/helloworld/*

prepare:
	if [ ! -d "server/helloworld" ]; then mkdir -p server/helloworld; fi
	if [ ! -d "client/helloworld" ]; then mkdir -p client/helloworld; fi

helloworld.proto: prepare
	protoc -I. helloworld.proto \
		--go_out=plugins=grpc:./server/helloworld \
		--grpc-web_out=import_style=commonjs+dts,mode=grpcweb:./client/helloworld \
		--js_out=import_style=commonjs:./client/helloworld

server: proto
	cd server && \
		CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o app

docker:
	docker-compose up -d --build
