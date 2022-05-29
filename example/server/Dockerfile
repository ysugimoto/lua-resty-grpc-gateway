FROM alpine:3.16.0

LABEL maintainer="Yoshiaki Sugimoto <sugimoto@wnotes.net>"

COPY ./app /app
RUN chmod +x /app

EXPOSE 50001

CMD ["/app"]
