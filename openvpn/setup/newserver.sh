#!/bin/sh

set -e

OPENVPN_CERTS_PATH="/etc/openvpn/certs"
FILE_SERVER_CRT="${OPENVPN_CERTS_PATH}/pki/issued/server.crt"

# 如果 cert 目录不存在，则创建并初始化
if [ ! -d "$OPENVPN_CERTS_PATH" ]; then
  echo "[*] Directory $OPENVPN_CERTS_PATH not found, creating..."
  mkdir -p "$OPENVPN_CERTS_PATH"
fi
cd "$OPENVPN_CERTS_PATH"

# 如果没有 server 证书则生成
if [ ! -f "$FILE_SERVER_CRT" ]; then
  echo "[*] No certs found - generating new ones"
  cp -R /usr/share/easy-rsa/* "$OPENVPN_CERTS_PATH"
  ./easyrsa init-pki
  ./easyrsa --batch build-ca nopass
  ./easyrsa --batch build-server-full server nopass
  ./easyrsa gen-dh
  echo "[✓] Certificates generated"
else
  echo "[✓] Found existing certs - reusing"
fi

