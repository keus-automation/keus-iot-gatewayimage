#!/bin/bash

cd /opt

FILE_MINI=/opt/keus-iot-code/storage/multigatewaymode.json
if [ -f "$FILE_MINI" ]; then
    echo "$FILE_MINI exists."

    touch /opt/grpc-checker-cron-installed
else
    echo "Main Gateway ... set grpc checker cron"
    FILE=/opt/grpc-checker-cron-installed
    if [ -f "$FILE" ]; then
      echo "$FILE exists."
    else
      grpcRandomStart=$(( ( RANDOM % 30 )  + 1 ))
      grpcRandomNext=$((grpcRandomStart + 30))

      echo "$grpcRandomStart,$grpcRandomNext * * * * pm2 restart grpc_checker > /opt/grpc_checker_cron.log  2>&1" >> crontab.file
      crontab crontab.file
      touch /opt/grpc-checker-cron-installed
    fi
fi
