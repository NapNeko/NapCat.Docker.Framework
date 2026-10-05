# syntax=docker/dockerfile:1
# check=skip=SecretsUsedInArgOrEnv
FROM debian:12-slim

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
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    # LinuxQQ 3.2.32-52194。腾讯会下架旧版本的下载链接，官方 CDN 下不到时改从 GitHub 上的镜像下载
    QQ_FILE="QQ_3.2.32_260812_${arch}_01.deb" && \
    for QQ_URL in "https://qqdl.gtimg.cn/qqfile/QQNT/9.9.33/release/3f89efc5/${QQ_FILE}" \
                  "https://github.com/Rodert/qq-versions/releases/download/qq-packages-20260813-1d08f1d4/${QQ_FILE}"; do \
        rm -f linuxqq.deb linuxqq.deb.aria2; \
        aria2c --check-certificate=false -x16 -s16 -o linuxqq.deb "${QQ_URL}" && break; \
    done && \
    dpkg -i linuxqq.deb && apt-get -f install -y --no-install-recommends && \
    rm linuxqq.deb && \
    chmod 777 /opt/QQ/

ARG TARGETARCH
COPY napi/${TARGETARCH} /lib/${TARGETARCH}

COPY start.sh /root/start.sh

# NapCat.Framework.zip 应由 CI 下载到构建上下文并复制进镜像
COPY NapCat.Framework.zip /tmp/NapCat.zip

RUN chmod +x /root/start.sh && \
    useradd --no-log-init -d /app napcat && \
    mkdir /app && \
    # 直接解压 NapCat.Framework.zip（解压失败将中止构建）
    unzip -o /tmp/NapCat.zip -d /app/napcat && \
    # 简单判断 nativeLoader.cjs 是否存在于 napcat 根目录并设置路径变量
    if [ -f /app/napcat/nativeLoader.cjs ]; then NAPCAT_MAIN_PATH="/app/napcat/nativeLoader.cjs"; else NAPCAT_MAIN_PATH=""; fi && \
    echo "[supervisord]" > /etc/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisord.conf && \
    echo "[program:qq]" >> /etc/supervisord.conf && \
    echo "command=qq --no-sandbox" >> /etc/supervisord.conf && \
    echo "user=napcat" >> /etc/supervisord.conf && \
    echo "stdout_logfile=/dev/stdout" >> /etc/supervisord.conf && \
    echo "stdout_logfile_maxbytes=0" >> /etc/supervisord.conf && \
    echo "stderr_logfile=/dev/stderr" >> /etc/supervisord.conf && \
    echo "stderr_logfile_maxbytes=0" >> /etc/supervisord.conf && \
    echo "environment=HOME=\"/app\",DISPLAY=\":1\",LD_PRELOAD=\"/lib/${TARGETARCH}/libnapiloader.so\",NAPCAT_EXTERNAL_SCRIPT_PATH=\"${NAPCAT_MAIN_PATH}\"" >> /etc/supervisord.conf && \
    rm -f /tmp/NapCat.zip

CMD ["/bin/bash", "-c", "startx & sh /root/start.sh"]
