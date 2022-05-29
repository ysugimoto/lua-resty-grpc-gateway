"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var helloworld_grpc_web_pb_1 = require("./helloworld/helloworld_grpc_web_pb");
var helloworld_pb_1 = require("./helloworld/helloworld_pb");
var client = new helloworld_grpc_web_pb_1.GreeterClient("http://localhost:9000", null, null);
var request = new helloworld_pb_1.HelloRequest();
request.setDisplayname("grpc-web with gateway");
client.sayHello(request, {}, function (err, resp) {
    if (err) {
        console.error(err.message);
        return;
    }
    var paragraph = document.createElement("p");
    paragraph.textContent = resp.getMessage();
    document.body.appendChild(paragraph);
});
