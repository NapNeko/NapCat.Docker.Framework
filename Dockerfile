FROM phusion/baseimage:jammy-1.0.2

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV VNC_PASSWD=vncpasswd

# 安装必要的软件包
RUN apt-get update && apt-get install -y \
    openbox \
    curl \
    unzip \
    x11vnc \
    xvfb \
    fluxbox \
    supervisor \
    libnotify4 \
    libnss3 \
    xdg-utils \
    libsecret-1-0 \
    libgbm1 \
    libasound2 \
    fonts-wqy-zenhei \
    git \
    gnutls-bin && \    
    apt autoremove -y && \
    apt clean && \
    rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/* && \

    # 安装novnc
    git config --global http.sslVerify false && \
    git config --global http.postBuffer 1048576000 && \
    cd /opt && git clone https://github.com/novnc/noVNC.git && \
    cd /opt/noVNC/utils && git clone https://github.com/novnc/websockify.git && \
    cp /opt/noVNC/vnc.html /opt/noVNC/index.html
