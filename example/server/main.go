package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"time"

	"github.com/ysugimoto/lua-resty-grpc-gateway/helloworld"

	"github.com/golang/protobuf/ptypes/timestamp"
	"google.golang.org/grpc"
)

type Server struct{}

func (s *Server) SayHello(ctx context.Context, req *helloworld.HelloRequest) (*helloworld.HelloReply, error) {
	name := req.GetName()
	log.Printf("name: %s\n", name)
	return &helloworld.HelloReply{
		Message: fmt.Sprintf("Hello, %s!", name),
		ReplyAt: &timestamp.Timestamp{
			Seconds: time.Now().Unix(),
		},
	}, nil
}

func main() {
	conn, err := net.Listen("tcp", ":50001")
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	server := grpc.NewServer()
	helloworld.RegisterGreeterServer(server, &Server{})
	server.Serve(conn)
}
