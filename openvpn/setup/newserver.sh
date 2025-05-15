#!/bin/bash

# 设置 Easy-RSA 证书目录
OPENVPN_CERTS_PATH="/etc/openvpn/certs"
FILE_SERVER_CRT="${OPENVPN_CERTS_PATH}/pki/issued/server.crt"

# 如果 cert 目录不存在，则创建
if [ ! -d "$OPENVPN_CERTS_PATH" ]; then
  echo "[*] 目录 $OPENVPN_CERTS_PATH 不存在，正在创建..."
  mkdir -p "$OPENVPN_CERTS_PATH"
fi

cd "$OPENVPN_CERTS_PATH" || exit 1

# 如果未找到 server 证书，则执行初始化和生成
if [ ! -f "$FILE_SERVER_CRT" ]; then
  echo "[*] 未找到服务器证书，开始生成所需文件..."

  # 拷贝 Easy-RSA 脚本（确保 Easy-RSA 安装位置正确）
  cp -R /usr/share/easy-rsa/* "$OPENVPN_CERTS_PATH"

  # 初始化 PKI 目录
  ./easyrsa init-pki

  # 批量创建 CA（无密码）
  ./easyrsa --batch build-ca nopass

  # 创建服务器证书（无密码）
  ./easyrsa --batch build-server-full server nopass

  # 生成 Diffie-Hellman 参数
  ./easyrsa gen-dh

  # 生成 ta.key 用于 tls-auth
  openvpn --genkey --secret ta.key

  echo "[✓] 所有证书和密钥生成完毕"
else
  echo "[✓] 已存在 server.crt，跳过证书生成"
fi
