FROM openresty/openresty:1.21.4.1-0-centos

RUN yum install gcc git bsdtar -y

## install basic google's protobuf files
ARG PROTOC_VERSION="21.1"
ARG TARGETOS
ARG TARGETARCH

# normalize architechture
RUN case "${TARGETARCH}" in \
        "amd64" ) DOCKER_ARCH="x86_64"   ;; \
        "arm/v7") DOCKER_ARCH="arm_hf"   ;; \
        "arm64" ) DOCKER_ARCH="aarch_64" ;; \
        *       ) DOCKER_ARCH=""         ;; \
    esac && \
    PROTOC=protoc-${PROTOC_VERSION}-${TARGETOS}-${DOCKER_ARCH}.zip && \
    curl -Ls https://github.com/google/protobuf/releases/download/v${PROTOC_VERSION}/${PROTOC} | \
    bsdtar -xvf- -C /usr/local/ && \
    chmod -R 644 /usr/local/include/ && chmod -R 755 /usr/local/bin/
  
RUN luarocks install lua-protobuf
RUN luarocks install serpent

