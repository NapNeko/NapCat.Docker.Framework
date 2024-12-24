FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    VNC_PASSWD=vncpasswd \
    TZ=Asia/Shanghai

COPY LoadLiteLoader.js LiteLoaderQQNT-inner.zip start.sh /root/
RUN apt-get update && apt-get install -y \
    openbox \
    xorg \
    dbus-user-session \
    curl \
    unzip \
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
    apt autoremove -y && \
    apt clean && \
    rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/* && \
    mkdir -p ~/.vnc && \
    chmod +x /root/start.sh && \ 
    echo "${TZ}" > /etc/timezone && \ 
    ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    apt autoremove -y && \
    apt clean && \
    rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*  && \
    # 安装novnc
    git config --global http.sslVerify false && \
    git config --global http.postBuffer 1048576000 && \
    cd /opt && git clone https://github.com/novnc/noVNC.git && \
    cd /opt/noVNC/utils && git clone https://github.com/novnc/websockify.git && \
    cp /opt/noVNC/vnc.html /opt/noVNC/index.html && \
    #安装QQ
    arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    curl -o linuxqq.deb https://dldir1.qq.com/qqfile/qq/QQNT/63c751e8/linuxqq_3.2.15-30899_${arch}.deb && \
    dpkg -i linuxqq.deb && apt-get -f install -y && rm linuxqq.deb && \
    chmod 777 /opt/QQ/ && \
    #安装LiteLoaderQQNT
    mv /root/LiteLoaderQQNT-inner.zip /tmp/LiteLoaderQQNT.zip && \
    #curl -L -o /tmp/LiteLoaderQQNT.zip https://github.com/LiteLoaderQQNT/LiteLoaderQQNT/archive/f3711f41cc5c22fa6384264345aad45e1fd1c8f2.zip && \
    mkdir -p /opt/QQ/resources/app/LiteLoader && \
    # 移动文件/root/LoadLiteLoader.js到/opt/QQ/resources/app/LoadLiteLoader.js
    mv /root/LoadLiteLoader.js /opt/QQ/resources/app/LoadLiteLoader.js && \
    # /opt/QQ/resources/app/package.json执行下面的替换
    #   "main": "./application/app_launcher/index.js",
    #   "main": "./LoadLiteLoader.js",
    sed -i 's/"main": ".\/application.asar\/app_launcher\/index.js"/"main": ".\/LoadLiteLoader.js"/' /opt/QQ/resources/app/package.json && \
    # 下载
    curl -L -o /tmp/NapCat.zip https://github.com/NapNeko/NapCatQQ/releases/download/$(curl -Ls "https://api.github.com/repos/NapNeko/NapCatQQ/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')/NapCat.Framework.zip && \
    chmod +x ~/start.sh && \
    \
    echo "[supervisord]" > /etc/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisord.conf && \
    echo "[program:qq]" >> /etc/supervisord.conf && \
    echo "command=qq --no-sandbox" >> /etc/supervisord.conf && \
    echo 'environment=DISPLAY=":1"' >> /etc/supervisord.conf

VOLUME ["/opt/QQ/resources/app/LiteLoader"]
CMD ["/bin/bash", "-c", "startx & sh /root/start.sh"]
