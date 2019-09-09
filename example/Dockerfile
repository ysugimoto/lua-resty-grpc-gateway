FROM openresty/openresty:1.15.8.1rc1-xenial

ARG PROTOC_VERSION="3.9.0"

RUN apt-get update -qq && \
    apt-get install -y vim telnet git

RUN mkdir -p /var/log/nginx
RUN mkdir /etc/proto
COPY ./helloworld.proto /etc/proto/helloworld.proto

## install basic google's protobuf files
RUN cd /opt && \
    curl -OL https://github.com/google/protobuf/releases/download/v3.9.0/protoc-${PROTOC_VERSION}-linux-x86_64.zip && \
    unzip -o protoc-${PROTOC_VERSION}-linux-x86_64.zip -d /usr/local/protoc

RUN luarocks install lua-resty-grpc-gateway
RUN luarocks install serpent