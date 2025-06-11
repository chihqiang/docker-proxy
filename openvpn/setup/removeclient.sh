#!/bin/sh

# 设置 Easy-RSA 工作目录
OPENVPN_CERTS_PATH="/etc/openvpn/certs"
cd "$OPENVPN_CERTS_PATH" || { echo "❌ 无法进入目录 $OPENVPN_CERTS_PATH"; exit 1; }

# 获取所有客户端证书（排除 server.crt）
echo "以下是所有已签发的客户端证书："
counter=1
CLIENTS=""
for crt_file in "$OPENVPN_CERTS_PATH"/pki/issued/*.crt; do
  client_name=$(basename "$crt_file" .crt)
  if [ "$client_name" != "server" ]; then
    echo "$counter) $client_name"
    CLIENTS="${CLIENTS}${counter}:${client_name}"$'\n'
    counter=$((counter + 1))
  fi
done

# 检查是否存在可吊销的客户端
if [ -z "$CLIENTS" ]; then
  echo "⚠️ 没有可吊销的客户端证书。"
  exit 0
fi

# 用户选择证书
read -rp "请输入要吊销的证书序号: " CHOICE

# 验证输入合法性
if ! echo "$CHOICE" | grep -Eq '^[0-9]+$'; then
  echo "❌ 输入无效，必须为数字。"
  exit 1
fi

CLIENT_NAME=$(echo "$CLIENTS" | grep "^$CHOICE:" | cut -d':' -f2)

if [ -z "$CLIENT_NAME" ]; then
  echo "❌ 没有找到对应的证书，请检查输入。"
  exit 1
fi

# 吊销证书并重新生成 CRL
echo "🔧 正在吊销证书 $CLIENT_NAME ..."
EASYRSA_BATCH=1 ./easyrsa revoke "$CLIENT_NAME"
./easyrsa gen-crl

# 拷贝吊销列表到 OpenVPN 可访问位置
cp -f "$OPENVPN_CERTS_PATH/pki/crl.pem" "$OPENVPN_CERTS_PATH/"
chmod 644 "$OPENVPN_CERTS_PATH/crl.pem"

echo "✅ 客户端证书 $CLIENT_NAME 已成功吊销。"
