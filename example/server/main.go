package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"time"

	pb "github.com/ysugimoto/lua-resty-grpc-gateway/helloworld"

	"github.com/davecgh/go-spew/spew"
	"github.com/golang/protobuf/ptypes/timestamp"
	"google.golang.org/grpc"
)

type Server struct {
	pb.UnimplementedGreeterServer
}

func (s *Server) SayHello(ctx context.Context, req *pb.HelloRequest) (*pb.HelloReply, error) {
	spew.Dump(req)
	name := req.GetDisplayName()
	log.Printf("name: %s\n", name)
	return &pb.HelloReply{
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
	pb.RegisterGreeterServer(server, &Server{})
	server.Serve(conn)
}
