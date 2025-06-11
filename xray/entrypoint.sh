#!/usr/bin/env sh

if [ ! -e "/etc/xray/config.json" ]; then
    cat > /etc/xray/config.json <<EOF
{
  "inbounds": [{
    "port":  ${XRAY_VMESS_PORT},
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "${XRAY_CLIENT_ID}",
          "level": 1
        }
      ]
    }
  }],
  "outbounds": [{
    "protocol": "freedom",
    "settings": {}
  }]
}
EOF

  echo "Start default configuration, enable port: ${XRAY_VMESS_PORT}, client id: ${XRAY_CLIENT_ID}"
fi


/usr/bin/xray -config /etc/xray/config.json