FROM ubuntu:20.04 as ubuntu-base

ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt-get -qqy update \
    && apt-get -qqy --no-install-recommends install \
        sudo \
        supervisor \
        xvfb x11vnc novnc websockify \
        dbus-x11 \
        xfce4 \
        firefox \
        terminator \
        htop \
        gnupg2 \
        software-properties-common \
        curl \
        git \
        wget \
        unzip \
        xfonts-intl-chinese \
        fonts-wqy-microhei \  
        ibus-pinyin \
        ibus \
        ibus-clutter \
        ibus-gtk \
        ibus-gtk3 \
        python3-pip \
        python3-setuptools \
        g++ \
        ssh \
        locales \
        socat \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN cp /usr/share/novnc/vnc.html /usr/share/novnc/index.html

COPY scripts/* /opt/bin/
COPY supervisord.conf /etc/supervisor/

# Relaxing permissions for other non-sudo environments
RUN mkdir -p /var/run/supervisor /var/log/supervisor \
    && chmod -R 777 /opt/bin/ /var/run/supervisor /var/log/supervisor /etc/passwd \
    && chgrp -R 0 /opt/bin/ /var/run/supervisor /var/log/supervisor \
    && chmod -R g=u /opt/bin/ /var/run/supervisor /var/log/supervisor

# Creating base directory for Xvfb
RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

CMD ["/opt/bin/entry_point.sh"]

#============================
# Utilities
#============================
FROM ubuntu-base as ubuntu-utilities

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ffmpeg \
        remmina remmina-plugin-rdp remmina-plugin-secret \
        obs-studio \
    && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt install -qqy --no-install-recommends ./google-chrome-stable_current_amd64.deb \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN dpkg-reconfigure locales
RUN wget --no-check-certificate -c https://golang.org/dl/go1.16.3.linux-amd64.tar.gz \
    && tar -C /usr/local -xvzf go1.*.tar.gz \
    && export PATH=$PATH:/usr/local/go/bin

RUN git clone https://github.com/vlakhani28/bbht.git \
    && chmod +x bbht/install.sh \
    && ./bbht/install.sh \
    && mv bbht/run-after-go.sh /root/tools \
    && chmod +x /root/tools/run-after-go.sh

#============================
# GUI
#============================
FROM ubuntu-utilities as ubuntu-ui

ENV SCREEN_WIDTH=1280 \
    SCREEN_HEIGHT=720 \
    SCREEN_DEPTH=24 \
    SCREEN_DPI=96 \
    DISPLAY=:99 \
    DISPLAY_NUM=99 \
    UI_COMMAND=/usr/bin/startxfce4

# RUN apt-get update -qqy \
#     && apt-get -qqy install \
#         xserver-xorg xserver-xorg-video-fbdev xinit pciutils xinput xfonts-100dpi xfonts-75dpi xfonts-scalable kde-plasma-desktop

RUN apt-get update -qqy \
    && apt-get -qqy install --no-install-recommends \
        dbus-x11 xfce4 \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/* 
