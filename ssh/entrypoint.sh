#!/usr/bin/env sh

echo "Set SSH connection account: ${SSH_USER}, connection password: ${SSH_PASSWORD}"
USER_FILE="/var/run/${SSH_USER}.user"

# 检查用户文件是否存在
if [ -f "${USER_FILE}" ]; then
    echo "User ${SSH_USER} already exists. Skipping setup."
else
    # 注意 if 条件 [ ] 和 != 之间要有空格
    if [ "${SSH_USER}" != "root" ]; then
        useradd -m -d /home/${SSH_USER} -s /bin/bash ${SSH_USER}
        echo "${SSH_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    fi

    echo "${SSH_USER}:${SSH_PASSWORD}" | chpasswd
    echo "${SSH_USER}:${SSH_PASSWORD}" | base64 > "${USER_FILE}"
fi

echo "start ssh ...."
exec /usr/sbin/sshd -D -e
