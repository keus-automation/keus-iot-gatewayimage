#!/bin/bash -e

cd ./files/
rm -rf keus-iot-code.tar.gz
wget -O keus-iot-code.tar.gz "$BUNDLE_URL"
cd ../

on_chroot << EOF
    apt-get update
    apt-get upgrade -y
    rm -rf /root/n
    curl -L https://git.io/n-install | bash -s -- -y
    source /root/.bashrc
    n 16.13.0
    n prune
    npm config set user 0
    npm config set unsafe-perm true
    npm install pm2 zx checksum -g
    cd /opt
    mkdir -p /opt/keus-iot-code
    mkdir -p /opt/keus-iot-code/redis-bins
    pm2 install pm2-logrotate
    pm2 kill
EOF


# wget -O mongod https://keus-resources.s3.ap-south-1.amazonaws.com/monogo-3.6-rpi-64bit/mongod
# wget -O mongorestore https://keus-resources.s3.ap-south-1.amazonaws.com/keus-iot-tools/mongodb-tools/mongorestore
# wget -O mongodump https://keus-resources.s3.ap-south-1.amazonaws.com/keus-iot-tools/mongodb-tools/mongodump
install -m 777 files/mongod "${ROOTFS_DIR}/opt/keus-iot-code/"
install -m 777 files/mongodump "${ROOTFS_DIR}/opt/keus-iot-code/"
install -m 777 files/mongorestore "${ROOTFS_DIR}/opt/keus-iot-code/"

# wget -O redis-arm64-pi.tar.gz https://keus-resources.s3.ap-south-1.amazonaws.com/keus-iot-tools/redis-builds-pi64/redis-arm64-pi.tar.gz
install -m 777 files/redis-arm64-pi.tar.gz "${ROOTFS_DIR}/opt/keus-iot-code/redis-bins/"

# wget -O crontab.file https://keus-resources.s3.ap-south-1.amazonaws.com/keus-iot-tools/crontab.file
# wget -O code-updater.sh https://keus-resources.s3.ap-south-1.amazonaws.com/keus-iot-tools/code-updater.sh
# wget -O install-grpc-checker.sh https://keus-resources.s3.ap-south-1.amazonaws.com/keus-iot-tools/install-grpc-checker.sh
install -m 777 files/crontab.file "${ROOTFS_DIR}/opt/"
install -m 777 files/code-updater.sh "${ROOTFS_DIR}/opt/"
install -m 777 files/install-grpc-checker.sh "${ROOTFS_DIR}/opt/"
install -m 777 files/keus-iot-code.tar.gz "${ROOTFS_DIR}/opt/"

on_chroot << EOF
    source /root/.bashrc
    cd /opt/
    tar -xzvf keus-iot-code.tar.gz

    mkdir -p /opt/keus-iot-code/storage/
    mkdir -p /opt/keus-iot-code/logs/
    mkdir -p /opt/keus-iot-code/redis-bins/
    mkdir -p /opt/keus-iot-code/keus-iot-gateway/src/remote_files/ac
    mkdir -p /opt/keus-iot-code/keus-iot-gateway/src/remote_files/amp
    mkdir -p /opt/keus-iot-code/keus-iot-gateway/src/remote_files/fan
    mkdir -p /opt/keus-iot-code/keus-iot-gateway/src/remote_files/pr
    mkdir -p /opt/keus-iot-code/keus-iot-gateway/src/remote_files/tv

    cd /opt/keus-iot-code/
    chmod 777 /opt/keus-iot-code/mongodump
    chmod 777 /opt/keus-iot-code/mongorestore
    chmod 777 /opt/keus-iot-code/mongod
    
    cd /opt/keus-iot-code/redis-bins/
    tar -xzvf redis-arm64-pi.tar.gz
    chmod 777 ./redis-server ./redistimeseries.so ./librejson.so
    
    cd /opt
    chmod 777 /opt/code-updater.sh
    chmod 777 install-grpc-checker.sh
    crontab /opt/crontab.file

    curl -fsSL https://tailscale.com/install.sh | sh

    cd /opt/keus-iot-code/
    echo "Main gateway mode image"

    pm2 start ecosystem.maingateway.config.js all

    pm2 startup
    pm2 save
    pm2 kill
EOF
