# syntax=docker/dockerfile:1
# check=skip=SecretsUsedInArgOrEnv
FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive \
    VNC_PASSWD=vncpasswd \
    TZ=Asia/Shanghai

RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

RUN apt-get update && apt-get install -y --no-install-recommends \
    openbox \
    xorg \
    libatspi2.0-0 \
    dbus-user-session \
    curl \
    aria2 \
    unzip \
    libgtk-3-0 \
    xvfb \
    supervisor \
    libnotify4 \
    libnss3 \
    xdg-utils \
    libsecret-1-0 \
    ffmpeg \
    libgbm1 \
    libasound2 \
    fonts-wqy-zenhei \
    git \
    gnutls-bin \
    tzdata \
    fluxbox \
    x11vnc && \
    mkdir -p ~/.vnc && \
    echo "${TZ}" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    # 安装novnc
    git config --global http.sslVerify false && \
    git config --global http.postBuffer 1048576000 && \
    cd /opt && git clone https://github.com/novnc/noVNC.git && \
    cd /opt/noVNC/utils && git clone https://github.com/novnc/websockify.git && \
    cp /opt/noVNC/vnc.html /opt/noVNC/index.html && \
    # 最终清理
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*#安装QQ
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    aria2c --check-certificate=false -x16 -s16 -o linuxqq.deb "https://dldir1.qq.com/qqfile/qq/QQNT/18039323/linuxqq_3.2.21-41857_${arch}.deb" && \
    dpkg -i linuxqq.deb && apt-get -f install -y --no-install-recommends && \
    rm linuxqq.deb && \
    chmod 777 /opt/QQ/

ARG TARGETARCH
COPY lib/${TARGETARCH} /lib/${TARGETARCH}

COPY start.sh /root/start.sh

RUN chmod +x /root/start.sh && \
    useradd --no-log-init -d /app napcat && \
    mkdir /app && \
    # 下载并解压 NapCat 到镜像内，然后查找 nativeLoader.cjs，构建时将其写入 supervisord environment
    curl -k -L -o /tmp/NapCat.zip https://github.com/NapNeko/NapCatQQ/releases/download/$(curl -Ls "https://api.github.com/repos/NapNeko/NapCatQQ/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')/NapCat.Framework.zip || true && \
    if [ -f /tmp/NapCat.zip ]; then unzip -o /tmp/NapCat.zip -d /app/napcat || true; fi && \
    NAPCAT_MAIN_PATH=$(find /app/napcat -type f -name nativeLoader.cjs -print -quit 2>/dev/null || true) && \
    echo "[supervisord]" > /etc/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisord.conf && \
    echo "[program:qq]" >> /etc/supervisord.conf && \
    echo "command=qq --no-sandbox" >> /etc/supervisord.conf && \
    echo "user=napcat" >> /etc/supervisord.conf && \
    echo "stdout_logfile=/dev/stdout" >> /etc/supervisord.conf && \
    echo "stdout_logfile_maxbytes=0" >> /etc/supervisord.conf && \
    echo "stderr_logfile=/dev/stderr" >> /etc/supervisord.conf && \
    echo "stderr_logfile_maxbytes=0" >> /etc/supervisord.conf && \
    echo "environment=HOME=\"/app\",DISPLAY=\":1\",LD_PRELOAD=\"/lib/${TARGETARCH}/libnapiloader.so\",NAPCAT_MAIN_PATH=\"${NAPCAT_MAIN_PATH}\"" >> /etc/supervisord.conf && \
    rm -f /tmp/NapCat.zip

CMD ["/bin/bash", "-c", "startx & sh /root/start.sh"]
