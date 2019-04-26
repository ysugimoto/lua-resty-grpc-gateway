.PHONY: proto all helloworld.proto prepare docker

all: proto server client

proto: helloworld.proto

clean:
	rm server/src/helloworld/*.go
	rm client/helloworld/*

prepare:
	if [ ! -d "server/src/helloworld" ]; then mkdir -p server/src/helloworld; fi
	if [ ! -d "client/helloworld" ]; then mkdir -p client/helloworld; fi

helloworld.proto: prepare
	protoc -I. helloworld.proto \
		--go_out=plugins=grpc:./server/src/helloworld \
		--grpc-web_out=import_style=commonjs+dts,mode=grpcweb:./client/helloworld \
		--js_out=import_style=commonjs:./client/helloworld

server: proto
	cd server && \
		GOPATH=$(shell pwd)/server go get google.golang.org/grpc && \
		GOPATH=$(shell pwd)/server go get github.com/golang/protobuf/proto && \
		GOPATH=$(shell pwd)/server go get golang.org/x/sys/unix && \
		GOPATH=$(shell pwd)/server CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o app

docker: all
	docker-compose up -d --build
