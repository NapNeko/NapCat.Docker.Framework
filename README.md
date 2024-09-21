# NapCat.Docker.Framerwrok
NapCat Framerwork适配LinuxDocker项目 By Mlikiowa

[DockerHub](https://hub.docker.com/r/mlikiowa/napcat-framerwork-docker)

## Support Platform/Arch
- [x] Linux/Amd64
- [x] Linux/Arm64

## More
5900 Vnc 可以通过这个端口通过vnc协议连接

6081 NoVnc 可以通过这个端口在网页连接NTQQ

6099 可以通过这个端口远程配置NapCat 密钥在NTQQ的设置里面napcat页面里token=xxxxxxx的字符串 xxxxxxx为默认密码 需要修改前往docker容器 在plugin里面修改webui.json

```
docker run -d \
-e VNC_PASSWD=vncpasswd \
-p 5900:5900 \
-p 6081:6081 \
-p 3000:3000 \
-p 3001:3001 \
-p 6099:6099 \
--name napcatf \
--restart=always \
mlikiowa/napcat-framerwork-docker:latest
```
