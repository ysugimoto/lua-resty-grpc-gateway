package main

import (
	"context"
	"fmt"
	"log"
	"net"

	"helloworld"

	"google.golang.org/grpc"
)

type Server struct{}

func (s *Server) SayHello(ctx context.Context, req *helloworld.HelloRequest) (*helloworld.HelloReply, error) {
	name := req.GetName()
	return &helloworld.HelloReply{
		Message: fmt.Sprintf("Hello, %s!", name),
	}, nil
}

func main() {
	conn, err := net.Listen("tcp", ":9000")
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	server := grpc.NewServer()
	helloworld.RegisterGreeterServer(server, &Server{})
	server.Serve(conn)
}
