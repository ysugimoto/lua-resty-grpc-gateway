FROM openresty/openresty:1.21.4.1-0-centos

ARG PROTOC_VERSION="3.20.1"
ARG TARGETOS

RUN yum install gcc git -y

COPY ./helloworld.proto /etc/proto/helloworld.proto

## install basic google's protobuf files
RUN PROTOC=protoc-${PROTOC_VERSION}-${TARGETOS}-$(uname -m | sed 's/.\{2\}$/_&/').zip && \  
    cd /opt && \
    curl -OL https://github.com/google/protobuf/releases/download/v${PROTOC_VERSION}/${PROTOC} && \
    unzip -o ${PROTOC} -d /usr/local/protoc && \
    rm -f ${PROTOC} && \
    find /usr/local/protoc -type d -exec chmod 755 {} \; && \
    find /usr/local/protoc/include -type f -exec chmod 644 {} \;

RUN luarocks install lua-resty-grpc-gateway
RUN luarocks install serpent