#!/bin/bash -e

on_chroot << EOF
    apt-get update
    apt-get upgrade -y

    curl -L https://git.io/n-install | bash -s -- -y
    source /root/.bashrc

    n 12.16.2
    n prune

    npm config set user 0
    npm config set unsafe-perm true
    npm install pm2@latest -g

    cd /opt
    mkdir -p /opt/keus-iot-code
EOF

# install -v -m 777 files/keus-iot-code-node_modules.tar.gz "${ROOTFS_DIR}/opt/keus-iot-code/"

# on_chroot << EOF
#     cd /opt/keus-iot-code
#     tar -xzvf keus-iot-code-node_modules.tar.gz
#     echo "done unpacking node_modules"
#     echo $PATH
#     export PATH="$PATH:/root/n/bin"
#     echo $PATH
#     echo "installing pm2"
#     yarn global add pm2
#     pm2 install pm2-logrotate
#     pm2 kill
#     mkdir -p /opt/keus-minihub/database/dbfiles/
#     mkdir -p /opt/keus-minihub/database/acfiles/
#     cd /opt/keus-minihub
#     crontab production/crontab.file
#     echo "done installing cron"
# EOF
