#!/bin/bash

# Basic environment and X services (LiteLoader removed)
chmod 777 /tmp &
chmod +777 /opt/QQ &

rm -rf /run/dbus/pid &
rm /tmp/.X1-lock &
mkdir -p /var/run/dbus &
export DISPLAY=:1
dbus-daemon --config-file=/usr/share/dbus-1/system.conf --print-address &
Xvfb :1 -screen 0 1920x1080x16 &
fluxbox &
x11vnc -display :1 -noxrecord -noxfixes -noxdamage -forever -rfbauth ~/.vnc/passwd &
nohup /opt/noVNC/utils/novnc_proxy --vnc localhost:5900 --listen 6081 --file-only &
x11vnc -storepasswd $VNC_PASSWD ~/.vnc/passwd &

: ${NAPCAT_GID:=1000}
: ${NAPCAT_UID:=1000}
usermod -o -u ${NAPCAT_UID} napcat
groupmod -o -g ${NAPCAT_GID} napcat
usermod -g ${NAPCAT_GID} napcat
chown -R ${NAPCAT_UID}:${NAPCAT_GID} /app
chown -R ${NAPCAT_UID}:${NAPCAT_GID} /opt/QQ

exec supervisord
