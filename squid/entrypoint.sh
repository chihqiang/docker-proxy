#!/bin/sh
set -e

PORT=${PORT:-3128}
HOSTNAME=${HOSTNAME:-squid-alpine}

# 写入用户
if [ -n "$PROXY_USERS" ]; then
  USERNAME=$(echo "$PROXY_USERS" | cut -d':' -f1)
  PASSWORD=$(echo "$PROXY_USERS" | cut -d':' -f2)
  echo "[+] Creating passwd file for $USERNAME"
  htpasswd -bc /etc/squid/passwd "$USERNAME" "$PASSWORD"
else
  echo "[-] PROXY_USERS not set"
  exit 1
fi

# 替换配置
export PORT HOSTNAME
envsubst < /template.conf > /etc/squid/squid.conf

# 初始化缓存目录（只做一次）
if [ ! -d /var/cache/squid/00 ]; then
  echo "[+] Initializing cache..."
  squid -N -f /etc/squid/squid.conf -z
fi

# 启动前确保目录权限正确
echo "[+] Setting permissions for log and cache directories..."
mkdir -p /var/cache/squid /var/log/squid
chown -R squid:squid /var/cache/squid /var/log/squid /var/run


# 最终启动（前台、不 fork、不重复）
echo "[+] Starting squid..."
exec squid -f /etc/squid/squid.conf -NYCd 1
