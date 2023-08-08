FROM openresty/openresty:1.21.4.1-3-jammy

RUN apt-get update \
    && apt-get install gcc git -y

## install basic google's protobuf files
ARG PROTOC_VERSION="21.6"
ARG TARGETOS
ARG TARGETARCH

# normalize architechture
RUN case "${TARGETARCH}" in \
        "amd64" ) DOCKER_ARCH="x86_64"   ;; \
        "arm/v7") DOCKER_ARCH="arm_hf"   ;; \
        "arm64" ) DOCKER_ARCH="aarch_64" ;; \
        *       ) DOCKER_ARCH=""         ;; \
    esac && \
    PROTOC=protoc-${PROTOC_VERSION}-${TARGETOS}-${DOCKER_ARCH}.zip \
    && cd /tmp \
    && curl -fSL https://github.com/google/protobuf/releases/download/v${PROTOC_VERSION}/${PROTOC} -o ${PROTOC} \
    && unzip -d /usr/local ${PROTOC} \
    && chmod -R 655 /usr/local/include && chmod -R 755 /usr/local/bin/ \
    && rm -rf ${PROTOC}

RUN luarocks install lua-protobuf
RUN luarocks install serpent

