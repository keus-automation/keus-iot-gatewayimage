#!/bin/bash -e

echo "This is env variable ${KEUS_MAIN_GATEWAY} ${TIMEZONE_DEFAULT}"

if [ "${KEUS_MAIN_GATEWAY}" == "YES" ] 
then 

on_chroot << EOF
    source /root/.bashrc

    echo "${KEUS_MAIN_GATEWAY}"

    cd /opt/keus-iot-code/
    echo "Main gateway mode image"
    pm2 start ecosystem.maingateway.config.js all

    pm2 startup
    pm2 save
    pm2 kill
EOF

else

on_chroot << EOF
    source /root/.bashrc

    cd /opt/keus-iot-code/
    echo "Mini gateway mode image"
    touch /opt/keus-iot-code/storage/multigatewaymode.json
    pm2 start ecosystem.minigateway.config.js all

    pm2 startup
    pm2 save
    pm2 kill
EOF

fi