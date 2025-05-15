## docker（test）

~~~
// 构建镜像
podman build -t zhiqiangwang/proxy:openvpn .
// 运行镜像
// 使用全局代理模式
podman run -it --rm --name openvpn --privileged -e USE_DEFAULT_CONF=1 --device=/dev/net/tun zhiqiangwang/proxy:openvpn
// 使用k8s 自动获取ip进行自动配置
podman run -it --rm --name openvpn --privileged -e USE_DEFAULT_CONF=0 --device=/dev/net/tun zhiqiangwang/proxy:openvpn


//进入容器
podman exec -it openvpn bash
//进入交互式生成ovpn(需要输入客户端名称和ip)
cd /etc/openvpn/setup
./newclient.sh

//测试ovpn是否有效
openvpn --config /etc/openvpn/certs/pki/client1.ovpn

//吊销client(进入交互模式，选择吊销client)
cd /etc/openvpn/setup
./removeclient.sh
~~~

## openvpn.conf

~~~
port 1194                       # OpenVPN 服务监听的端口（改为 1194，常用于伪装 HTTPS 流量）
proto tcp                      # 使用 TCP 协议（更易穿越防火墙）

dev tun                        # 使用 TUN 虚拟网络设备（用于 IP 隧道）

ca /etc/openvpn/certs/pki/ca.crt                        # CA 根证书路径
cert /etc/openvpn/certs/pki/issued/server.crt           # 服务器证书路径
key /etc/openvpn/certs/pki/private/server.key           # 服务器私钥路径
dh /etc/openvpn/certs/pki/dh.pem                        # Diffie-Hellman 参数文件路径

topology subnet                 # 使用子网拓扑结构（更现代的模式）
server 10.8.0.0 255.255.255.0   # 分配给客户端的虚拟 VPN 子网

ifconfig-pool-persist ipp.txt  # 保存客户端的 IP 分配状态，重启后保持一致性

keepalive 10 120               # 保持连接心跳检测：每10秒发送一次 ping，120秒内无响应则断线
persist-key                    # 保持密钥文件在重启时不变
persist-tun                    # 保持 tun 设备不关闭

push "redirect-gateway def1 bypass-dhcp"   # 将客户端的默认网关重定向到 VPN（实现全局代理）
push "dhcp-option DNS 1.1.1.1"             # 给客户端推送 DNS（Cloudflare）
push "dhcp-option DNS 8.8.8.8"             # 给客户端推送 DNS（Google）

user nobody                    # 以低权限用户运行（安全性更高）
group nogroup                  # 以无用户组运行（安全性更高）

cipher AES-256-CBC             # 数据加密算法（AES-256）
auth SHA256                    # HMAC 哈希算法，用于数据完整性验证
tls-version-min 1.2            # 最低 TLS 版本限制为 1.2（增强安全）

status /tmp/openvpn-status.log      # 输出状态信息日志
verb 4                        # 日志详细级别（3为中等，适合调试使用）

~~~

