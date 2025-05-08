#!/bin/sh

/etc/openvpn/setup/newserver.sh

mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi

DEFAULT_CONF="/etc/openvpn/setup/openvpn.conf"
OPENVPN_CONF="/etc/openvpn/openvpn.conf"
if [ ! -f "$OPENVPN_CONF" ]; then
    if [ "$USE_DEFAULT_CONF" == "1" ] && [ -f "$DEFAULT_CONF" ]; then
        echo "使用默认配置: $DEFAULT_CONF"
        cat $DEFAULT_CONF > $OPENVPN_CONF
    else
        echo "使用k8s生成模式"
        /etc/openvpn/setup/gen-k8s-conf.sh
    fi
fi

exec openvpn --config /etc/openvpn/openvpn.conf