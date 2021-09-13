#!/bin/bash -e

on_chroot << EOF
    apt-get update
    apt-get upgrade -y
    rm -rf /root/n
    curl -L https://git.io/n-install | bash -s -- -y
    source /root/.bashrc
    n 12.16.2
    n prune
    npm config set user 0
    npm config set unsafe-perm true
    npm install pm2@latest -g
    cd /opt
    mkdir -p /opt/keus-iot-code
    pm2 install pm2-logrotate
    pm2 kill
EOF

install -m 777 files/mongod "${ROOTFS_DIR}/opt/keus-iot-code/"
install -m 777 files/keus-iot-code.tar.gz "${ROOTFS_DIR}/opt/"

on_chroot << EOF
    source /root/.bashrc
    cd /opt/
    tar -xzvf keus-iot-code.tar.gz

    cd /opt/keus-iot-code/kiott-broker
    npm install --production

    cd /opt/keus-iot-code/kiott-nodeclient
    npm install --production

    cd /opt/keus-iot-code/zigbee-herdsman
    npm install --production

    cd /opt/keus-iot-code/keus-iot-gateway 
    npm install --production

    mkdir -p /opt/keus-iot-code/storage/
    mkdir -p /opt/keus-iot-code/logs/
    mkdir -p /opt/keus-iot-code/keus-iot-gateway/src/remote_files/ac
    mkdir -p /opt/keus-iot-code/keus-iot-gateway/src/remote_files/amp
    mkdir -p /opt/keus-iot-code/keus-iot-gateway/src/remote_files/fan
    mkdir -p /opt/keus-iot-code/keus-iot-gateway/src/remote_files/pr
    mkdir -p /opt/keus-iot-code/keus-iot-gateway/src/remote_files/tv

    cd /opt/keus-iot-code/
    pm2 start ecosystem.maingateway.config.js all
    pm2 startup
    pm2 save
    pm2 kill
EOF

