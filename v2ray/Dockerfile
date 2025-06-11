FROM golang:alpine AS builder
RUN apk add git
RUN git clone https://github.com/v2fly/v2ray-core.git app && \
    cd app && git checkout $(git tag --sort=-creatordate | head -n 1) && \
    CGO_ENABLED=0 GOOS=linux go build -v -trimpath -ldflags "-s -w -buildid=" -o v2ray ./main

FROM alpine:3.21
ENV V2RAY_VMESS_PORT=10086
ENV V2RAY_CLIENT_ID=b831381d-6324-4d53-ad4f-8cda48b30811
ENV TZ=Asia/Shanghai
RUN apk add --no-cache wget tzdata ca-certificates
COPY --from=builder /go/app/v2ray /usr/bin/v2ray
RUN chmod +x /usr/bin/v2ray

RUN mkdir -p /var/log/v2ray /usr/share/v2ray /etc/v2ray/
RUN wget -O /usr/share/v2ray/geosite.dat https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat
RUN wget -O /usr/share/v2ray/geoip-only-cn-private.dat https://github.com/v2fly/geoip/releases/latest/download/geoip-only-cn-private.dat
RUN wget -O /usr/share/v2ray/geoip.dat https://github.com/v2fly/geoip/releases/latest/download/geoip.dat

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

WORKDIR /etc/v2ray

EXPOSE ${V2RAY_VMESS_PORT}

CMD [ "/entrypoint.sh" ]

STOPSIGNAL SIGQUIT