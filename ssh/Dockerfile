FROM ubuntu:22.04
# 安装必要的软件和SSH服务
RUN apt-get update && \ 
    apt-get install -y openssh-server sudo git git-svn subversion vim sudo curl jq net-tools iputils-ping ca-certificates dnsutils && \
    mkdir /var/run/sshd
# 允许 SSH 访问
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# 可进入容器 passwd root 允许root进行登陆访问
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
# 设置 SSH 用户和密码的环境变量
ENV SSH_USER=ubuntu
ENV SSH_PASSWORD=123456
# 将bin目录下可执行文件添加到/usr/local/bin下
# 复制容器启动时运行的入口脚本
COPY entrypoint.sh /entrypoint.sh
# 为入口脚本赋予可执行权限
RUN chmod +x /entrypoint.sh
# 开放端口
EXPOSE 22
# 启动SSH服务
CMD [ "/entrypoint.sh" ]
# Use SIGQUIT instead of default SIGTERM to cleanly drain requests
STOPSIGNAL SIGQUIT
