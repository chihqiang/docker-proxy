#!/bin/bash

# 设置 Easy-RSA 目录
OPENVPN_CERTS_PATH="/etc/openvpn/certs"

# 进入目录前检查路径是否存在
if [ ! -d "$OPENVPN_CERTS_PATH" ]; then
  echo "❌ 目录 $OPENVPN_CERTS_PATH 不存在，请检查路径是否正确。"
  exit 1
fi

cd "$OPENVPN_CERTS_PATH" || exit 1

# 交互式获取客户端名称
read -rp "请输入要生成的客户端名称（例如 client1）: " CLIENT_NAME
if [ -z "$CLIENT_NAME" ]; then
  echo "❌ 客户端名称不能为空。"
  exit 1
fi

# 交互式获取服务器 IP 地址
read -rp "请输入 VPN 服务器的公网 IP 地址: " SERVER_IP
if [ -z "$SERVER_IP" ]; then
  echo "❌ IP 地址不能为空。"
  exit 1
fi

# 确认提示
echo "🔧 正在为客户端 '$CLIENT_NAME' 创建配置文件，服务器 IP 为 '$SERVER_IP'..."
sleep 1

# 生成客户端证书
EASYRSA_BATCH=1 ./easyrsa build-client-full "$CLIENT_NAME" nopass

# 检查证书是否生成成功
if [ ! -f "pki/private/${CLIENT_NAME}.key" ] || [ ! -f "pki/issued/${CLIENT_NAME}.crt" ]; then
  echo "❌ 客户端证书或私钥生成失败。"
  exit 1
fi

# 检查 ta.key 是否存在
if [ ! -f "ta.key" ]; then
  echo "❌ 未找到 ta.key，无法生成客户端配置。请确认已生成并放置于 $OPENVPN_CERTS_PATH"
  exit 1
fi

# 生成 .ovpn 文件
OVPN_FILE="pki/${CLIENT_NAME}.ovpn"
cat > "$OVPN_FILE" <<EOF
client
nobind
dev tun
remote ${SERVER_IP} 1194 tcp

redirect-gateway def1
persist-key
persist-tun
verb 3
key-direction 1

<key>
$(cat pki/private/${CLIENT_NAME}.key)
</key>
<cert>
$(cat pki/issued/${CLIENT_NAME}.crt)
</cert>
<ca>
$(cat pki/ca.crt)
</ca>
<tls-auth>
$(cat ta.key)
</tls-auth>
EOF

realpath_ovpn="$OPENVPN_CERTS_PATH/$OVPN_FILE"

# 提示结果
echo
echo "📦 [预览] 以下是生成的 ${CLIENT_NAME}.ovpn 配置内容："
echo "------------------------------------------------------------"
cat "$OVPN_FILE"
echo "------------------------------------------------------------"
echo "✅ [完成] 客户端配置文件已生成：$realpath_ovpn"
echo "📁 你可以将该文件导入 OpenVPN 客户端进行连接。"

echo "▶️ 测试连接命令示例："
echo "openvpn --config $(realpath "$realpath_ovpn")"
echo