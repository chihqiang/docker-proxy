#!/usr/bin/env sh

echo "Set SSH connection account: ${SSH_USER}, connection password: ${SSH_PASSWORD}"
USER_FILE="/var/run/${SSH_USER}.user"
# 检查用户文件是否存在
if [ -f "${USER_FILE}" ]; then
    echo "User ${SSH_USER} already exists. Skipping setup."
else
    useradd -m -d /home/${SSH_USER} -s /bin/bash ${SSH_USER}
    echo "${SSH_USER}:${SSH_PASSWORD}" | chpasswd
    # echo "AllowUsers ${SSH_USER}" >> /etc/ssh/sshd_config
    echo "${SSH_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    echo "${SSH_USER}:${SSH_PASSWORD}" | base64 > "${USER_FILE}"
fi
echo "start ssh ...."
/usr/sbin/sshd -D -e