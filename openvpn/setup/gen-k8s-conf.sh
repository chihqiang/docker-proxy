#!/bin/sh

# 将 CIDR（如 24）转换为子网掩码（如 255.255.255.0）
cidr2mask() {
    local cidr=$1 mask=""
    for i in 1 2 3 4; do
        if [ "$cidr" -ge 8 ]; then
            mask="$mask.255"
            cidr=$((cidr - 8))
        elif [ "$cidr" -gt 0 ]; then
            mask="$mask.$((256 - 2 ** (8 - cidr)))"
            cidr=0
        else
            mask="$mask.0"
        fi
    done
    echo "${mask#.}"
}

# 将 CIDR 地址（如 192.168.1.123/24）转换为网络地址（如 192.168.1.0）
cidr2net() {
    local ip mask i=0 netOctets=""
    ip="${1%/*}"
    mask="${1#*/}"

    IFS='.' read -r o1 o2 o3 o4 <<EOF
$ip
EOF

    for octet in $o1 $o2 $o3 $o4; do
        i=$((i + 1))
        if [ "$i" -le $((mask / 8)) ]; then
            netOctets="$netOctets.$octet"
        elif [ "$i" -eq $((mask / 8 + 1)) ]; then
            bits=$((mask % 8))
            blocksize=$((256 >> bits))
            netpart=$(( (octet / blocksize) * blocksize ))
            netOctets="$netOctets.$netpart"
        else
            netOctets="$netOctets.0"
        fi
    done

    echo "${netOctets#.}"
}

# 获取外网默认路由对应的接口和 IP
intAndIP="$(ip route get 8.8.8.8 2>/dev/null | awk '/8.8.8.8/ {print $5 "-" $7}')"
int="${intAndIP%-*}"
ip="${intAndIP#*-}"

# 获取 CIDR 地址（如 192.168.1.123/24）
cidr="$(ip addr show dev "$int" | awk -vip="$ip" '$0 ~ ip {print $2}')"

# 计算网络地址和子网掩码
NETWORK="$(cidr2net "$cidr")"
NETMASK="$(cidr2mask "${cidr#*/}")"

# 获取 DNS 和搜索域
DNS=$(grep -v '^#' /etc/resolv.conf | awk '/^nameserver/ {print $2}')
SEARCH=$(grep -v '^#' /etc/resolv.conf | awk '/^search/ {$1=""; print $0}')


# 生成 push 配置片段
gen_push_options() {
    for domain in $SEARCH; do
        printf 'push "dhcp-option DOMAIN-SEARCH %s"\n' "$domain"
    done

    printf 'push "route %s %s"\n' "$NETWORK" "$NETMASK"

    for dns in $DNS; do
        printf 'push "dhcp-option DNS %s"\n' "$dns"
    done
}

CONFIG_FILE="/etc/openvpn/openvpn.conf"
if [ ! -e "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" <<EOF
port 1194
proto tcp
dev tun
ca /etc/openvpn/certs/pki/ca.crt
cert /etc/openvpn/certs/pki/issued/server.crt
key /etc/openvpn/certs/pki/private/server.key
dh /etc/openvpn/certs/pki/dh.pem
topology subnet
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
keepalive 10 120
persist-key
persist-tun
user nobody
group nogroup
cipher AES-256-CBC
auth SHA256
tls-version-min 1.2
status /tmp/openvpn-status.log
verb 4
$(gen_push_options)
EOF

    echo "OpenVPN 配置已生成: $CONFIG_FILE"
fi