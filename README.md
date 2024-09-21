# NapCat.Docker.Framerwrok
NapCat Framerwork适配LinuxDocker项目

5900 Vnc
6081 NoVnc

```
docker run -d \
-e VNC_PASSWD=vncpasswd
-p 5900:5900 \
-p 6081:6081 \
-p 3000:3000 \
-p 3001:3001 \
--name napcatf \
--restart=always \
mlikiowa/napcat-framerwork-docker:latest
```