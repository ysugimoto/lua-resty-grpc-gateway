FROM openresty/openresty:1.15.8.1rc1-xenial

ARG PROTOC_VERSION="3.11.0"

RUN apt-get update -qq && \
    apt-get install -y vim telnet git

RUN mkdir -p /var/log/nginx
RUN mkdir /etc/proto
COPY ./helloworld.proto /etc/proto/helloworld.proto

## install basic google's protobuf files
RUN cd /opt && \
    curl -OL https://github.com/google/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip && \
    unzip -o protoc-${PROTOC_VERSION}-linux-x86_64.zip -d /usr/local/protoc && \
    find /usr/local/protoc -type d -exec chmod 755 {} \; && \
    find /usr/local/protoc/include -type f -exec chmod 644 {} \;

RUN luarocks install lua-resty-grpc-gateway
RUN luarocks install serpent