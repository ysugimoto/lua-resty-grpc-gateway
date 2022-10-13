FROM golang:alpine3.16 AS builder

LABEL maintainer="Yoshiaki Sugimoto <sugimoto@wnotes.net>"

COPY ./ /build
WORKDIR /build
RUN CGO_ENABLED=0 go build -v -o app
FROM scratch

COPY --from=0 /build/app /opt/app

EXPOSE 50051

CMD ["/opt/app"]