import * as grpcWeb from "grpc-web"
import { GreeterClient } from "./helloworld/helloworld_grpc_web_pb"
import { HelloRequest, HelloReply } from "./helloworld/helloworld_pb"

const client = new GreeterClient("http://localhost:9000", null, null)
const request = new HelloRequest()
request.setName("grpc-web with gateway")

client.sayHello(request, {}, (err: grpcWeb.Error, resp: HelloReply) => {
  if (err) {
    console.error(err.message)
    return
  }
  const paragraph = document.createElement("p")
  paragraph.textContent = resp.getMessage()
  document.body.appendChild(paragraph)
})
