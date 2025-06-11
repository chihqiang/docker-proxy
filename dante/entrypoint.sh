#!/bin/bash

set -e

USER_NAME=${USER_NAME:-"dante"}
USER_PASS=${USER_PASS:-"dante123"}
PORT=${PORT:-"1080"}

# 创建用户
if ! id "$USER_NAME" &>/dev/null; then
  useradd -M -s /sbin/nologin "$USER_NAME"
  echo "$USER_NAME:$USER_PASS" | chpasswd
  echo "Created user: $USER_NAME"
fi

# 获取网卡名（默认 eth0）
IFACE=$(ip route show default | awk '/default/ {print $5}')
echo "Using interface: $IFACE"

# 判断配置文件是否存在
if [ -f /etc/danted.conf ]; then
  echo "/etc/danted.conf exists. Skipping configuration generation."
else
  echo "/etc/danted.conf does not exist. Creating configuration..."

  # 生成配置文件
  cat > /etc/danted.conf <<EOF
logoutput: stderr

internal: 0.0.0.0 port = $PORT
external: $IFACE

socksmethod: username
user.notprivileged: nobody

client pass {
  from: 0.0.0.0/0 to: 0.0.0.0/0
  log: connect disconnect error
}

socks pass {
  from: 0.0.0.0/0 to: 0.0.0.0/0
  protocol: tcp udp
  log: connect disconnect error
}
EOF

  echo "Configuration generated successfully."
fi

# 启动 sockd
exec sockd -f /etc/danted.conf
