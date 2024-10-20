#!/bin/bash

mkdir -p /opt/QQ/resources/app/LiteLoader/plugins/NapCat

# 安装 LiteLoader
if [ ! -f "/opt/QQ/resources/app/LiteLoader/package.json" ]; then
    unzip /tmp/LiteLoaderQQNT.zip -d /opt/QQ/resources/app/LiteLoader/
fi

# 安装 NapCat
if [ ! -f "/opt/QQ/resources/app/LiteLoader/plugins/NapCat/manifest.json" ]; then
    unzip /tmp/NapCat.zip -d /opt/QQ/resources/app/LiteLoader/plugins/NapCat/
    if [ "$(arch)" = "x86_64" ]; then
        jq '.packetServer = "127.0.0.1:8086"' /opt/QQ/resources/app/LiteLoader/plugins/NapCat/config/napcat.json > /opt/QQ/resources/app/LiteLoader/plugins/NapCat/config/napcat._json && mv /opt/QQ/resources/app/LiteLoader/plugins/NapCat/config/napcat._json /opt/QQ/resources/app/LiteLoader/plugins/NapCat/config/napcat.json
    fi
fi

chmod 777 /tmp &
chmod +777 /opt/QQ &

sed -i 's/"main": ".\/application\/app_launcher\/index.js"/"main": ".\/LoadLiteLoader.js"/' /opt/QQ/resources/app/package.json && \

rm -rf /run/dbus/pid &
rm /tmp/.X1-lock &
mkdir -p /var/run/dbus &
dbus-daemon --config-file=/usr/share/dbus-1/system.conf --print-address &
Xvfb :1 -screen 0 1080x760x16 &
fluxbox &
x11vnc -display :1 -noxrecord -noxfixes -noxdamage -forever -rfbauth ~/.vnc/passwd &
nohup /opt/noVNC/utils/novnc_proxy --vnc localhost:5900 --listen 6081 --file-only &
x11vnc -storepasswd $VNC_PASSWD ~/.vnc/passwd &
export DISPLAY=:1
# 考虑到packet-server的加载时机, 目前选择不使用supervisord
if [ "$(arch)" = "x86_64" ]; then
    /opt/napcat.packet/napcat.packet.linux 2>&1 &
    sleep 2
fi
exec supervisord