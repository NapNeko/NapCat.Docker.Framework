#!/bin/bash

mkdir -p /opt/QQ/resources/app/LiteLoader/plugins/NapCat

# 安装 LiteLoader
if [ ! -f "/opt/QQ/resources/app/LiteLoader/package.json" ]; then
    unzip /tmp/LiteLoaderQQNT.zip -d /opt/QQ/resources/app/LiteLoader/
fi

# 安装 NapCat
if [ ! -f "/opt/QQ/resources/app/LiteLoader/plugins/NapCat/manifest.json" ]; then
    unzip /tmp/NapCat.zip -d /opt/QQ/resources/app/LiteLoader/plugins/NapCat/
fi

chmod 777 /tmp &
rm -rf /run/dbus/pid &
rm /tmp/.X1-lock &
mkdir -p /var/run/dbus &
dbus-daemon --config-file=/usr/share/dbus-1/system.conf --print-address &
Xvfb :1 -screen 0 1080x760x16 &
fluxbox &
x11vnc -display :1 -noxrecord -noxfixes -noxdamage -forever -rfbauth ~/.vnc/passwd &
x11vnc -storepasswd $VNC_PASSWD ~/.vnc/passwd &
export DISPLAY=:1
# --disable-gpu 不加入
exec supervisord