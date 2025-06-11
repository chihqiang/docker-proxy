FROM alpine:3.21

RUN apk update && apk add --no-cache dante-server bash shadow

ENV PORT=1080
ENV USER_NAME=dante
ENV USER_PASS=dante123

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD [ "/entrypoint.sh" ]