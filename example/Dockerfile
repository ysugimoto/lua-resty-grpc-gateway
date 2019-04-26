FROM openresty/openresty:1.15.8.1rc1-xenial

RUN apt-get update -qq && \
    apt-get install -y vim telnet

RUN mkdir -p /var/log/nginx
RUN mkdir /etc/proto
COPY ./helloworld.proto /etc/proto/helloworld.proto
RUN luarocks install lua-resty-grpc-gateway
