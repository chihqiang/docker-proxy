#!/bin/sh

EASY_RSA_LOC="/etc/openvpn/certs"
cd $EASY_RSA_LOC

# 获取所有客户端证书，排除服务端证书
echo "以下是所有已签发的客户端证书："
counter=1
CLIENTS=""
for client in ${EASY_RSA_LOC}/pki/issued/*.crt; do
  client_name=$(basename "$client" .crt)
  # 排除服务端证书（假设服务端证书为 server.crt）
  if [ "$client_name" != "server" ]; then
    echo "$counter) $client_name"
    CLIENTS="$CLIENTS$counter:$client_name"$'\n'
    counter=$((counter + 1))
  fi
done

# 检查是否有客户端证书
if [ -z "$CLIENTS" ]; then
  echo "没有可吊销的客户端证书。"
  exit 1
fi

# 提示用户选择吊销证书
read -p "请输入要吊销的证书序号： " CHOICE

# 检查输入是否有效
if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 1 ] || ! echo "$CLIENTS" | grep -q "^$CHOICE:"; then
  echo "无效的选择，请重新输入一个有效的序号。"
  exit 1
fi

# 获取选择的客户端证书名称
CLIENT_NAME=$(echo "$CLIENTS" | grep "^$CHOICE:" | cut -d':' -f2)

# 吊销选中的证书
EASYRSA_BATCH=1 ./easyrsa revoke "$CLIENT_NAME"
./easyrsa gen-crl
cp ${EASY_RSA_LOC}/pki/crl.pem ${EASY_RSA_LOC}
chmod 644 ${EASY_RSA_LOC}/crl.pem

echo "客户端证书 $CLIENT_NAME 已成功吊销。"
