FROM golang:alpine AS builder
RUN apk add git
RUN git clone https://github.com/XTLS/Xray-core.git app && \
    cd app && git checkout $(git tag --sort=-creatordate | head -n 1) && \
    GOOS=linux CGO_ENABLED=0 go build -o xray -trimpath -ldflags "-s -w -buildid=" ./main

FROM alpine:3.21
ENV TZ=Asia/Shanghai
ENV XRAY_VMESS_PORT=9000
ENV XRAY_CLIENT_ID=1eb6e917-774b-4a84-aff6-b058577c60a5

RUN apk add --no-cache wget tzdata ca-certificates
COPY --from=builder /go/app/xray /usr/bin/xray
RUN chmod +x /usr/bin/xray

RUN mkdir -p /var/log/xray /usr/share/xray /etc/xray
RUN wget -O /usr/share/xray/geosite.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat
RUN wget -O /usr/share/xray/geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

EXPOSE ${XRAY_VMESS_PORT}

WORKDIR /etc/xray

CMD [ "/entrypoint.sh" ]

STOPSIGNAL SIGQUIT