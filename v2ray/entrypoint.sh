#!/usr/bin/env sh
if [ ! -e "/etc/v2ray/config.json" ]; then
    cat > /etc/v2ray/config.json <<EOF
{
  "inbounds": [{
    "port": ${V2RAY_VMESS_PORT},
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "${V2RAY_CLIENT_ID}"
        }
      ]
    }
  }],
  "outbounds": [{
    "protocol": "freedom"
  }]
}
EOF

  echo "Start default configuration, enable port: ${V2RAY_VMESS_PORT}, client id: ${V2RAY_CLIENT_ID}"
fi

v2ray run -config /etc/v2ray/config.json

