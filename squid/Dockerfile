FROM alpine:3.21

# 安装 Squid、Apache 工具（htpasswd）以及其它工具
RUN apk add --no-cache squid apache2-utils bash gettext

# 复制配置模板和启动脚本
COPY template.conf /template.conf
COPY entrypoint.sh /entrypoint.sh

# 设置环境变量
ENV PROXY_USERS="squid:squid123"
ENV PORT=3128

# 给 entrypoint 脚本可执行权限
RUN chmod +x /entrypoint.sh

# 配置容器启动时执行 entrypoint.sh
CMD [ "/entrypoint.sh" ]
