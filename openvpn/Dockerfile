FROM alpine:3.21

# 安装 OpenVPN 所需的依赖，包括 openssl（加密）、easy-rsa（证书管理）、openvpn（VPN 服务）、iptables（防火墙）、bash（脚本支持）
RUN apk add --no-cache openssl easy-rsa openvpn iptables bash

ADD setup /etc/openvpn/setup
RUN find /etc/openvpn/setup -type f -name "*.sh" -exec chmod +x {} \;

# 复制容器启动时运行的入口脚本
COPY entrypoint.sh /entrypoint.sh
# 为入口脚本赋予可执行权限
RUN chmod +x /entrypoint.sh

ENV USE_DEFAULT_CONF=1
# 设置容器的工作目录为 /etc/openvpn（后续运行命令会在该目录执行）
WORKDIR /etc/openvpn
# 向外暴露容器的 1194 端口
EXPOSE 1194
# 容器启动后默认执行 /entrypoint.sh 脚本（通常用于启动 OpenVPN 服务）
CMD [ "/entrypoint.sh" ]
# 设置容器的停止信号为 SIGQUIT，确保优雅退出（适用于 openvpn）
STOPSIGNAL SIGQUIT
