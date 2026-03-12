FROM --platform=linux/amd64 ubuntu:24.04 AS base
LABEL maintainer="Davide Mirtillo"
ARG DEBIAN_FRONTEND="noninteractive"

# 1. Install base dependencies and setup locales
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-utils \
        software-properties-common \
        tzdata \
        wget \
        ca-certificates \
        locales && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# 2. Setup WineHQ and i386
FROM base AS wine-setup
ARG WINE_VERSION="11.0.0.0~noble-1"
RUN mkdir -pm755 /etc/apt/keyrings && \
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        winehq-stable=${WINE_VERSION} \
        wine-stable=${WINE_VERSION} \
        wine-stable-amd64=${WINE_VERSION} \
        wine-stable-i386=${WINE_VERSION} && \
    rm -rf /var/lib/apt/lists/*

# 3. Install latest winetricks from source
FROM wine-setup AS winetricks-setup
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget ca-certificates && \
    (cd "$(mktemp -d)" && \
    echo '#!/bin/sh\n\ncd "$(mktemp -d)"\nwget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks\nwget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks.bash-completion\nchmod +x winetricks\nmv winetricks /usr/bin\nmv winetricks.bash-completion /usr/share/bash-completion/completions/winetricks' > update_winetricks && \
    chmod +x update_winetricks && \
    mv update_winetricks /usr/bin/ && \
    /usr/bin/update_winetricks) && \
    rm -rf /var/lib/apt/lists/*

# 4. Install remaining dependencies and SteamCMD
FROM winetricks-setup AS final
ARG VRISING_BUILD_ID="8148398"
RUN add-apt-repository multiverse && \
    apt-get update && \
    echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections && \
    apt-get install -y --no-install-recommends \
        gdebi-core \
        jq \
        gosu \
        xvfb \
        xserver-xorg \
        winbind \
        libgl1-mesa-dri:i386 \
        libgl1:i386 \
        netcat-openbsd \
        steam \
        steamcmd && \
    # Setup symlinks
    [ -e /usr/bin/steamcmd ] || ln -s /usr/games/steamcmd /usr/bin/steamcmd && \
    [ -e /usr/bin/wine ] || ln -s /opt/wine-stable/bin/wine /usr/bin/wine && \
    # In Wine 11.0, 'wine' is the 64-bit binary. Link it to wine64 for script compatibility.
    [ -e /usr/bin/wine64 ] || ln -s /opt/wine-stable/bin/wine /usr/bin/wine64 && \
    [ -e /usr/bin/wineserver ] || ln -s /opt/wine-stable/bin/wineserver /usr/bin/wineserver && \
    # Create steam user
    useradd -m -s /bin/bash steam && \
    # Clean up
    apt-get purge -y --auto-remove software-properties-common && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Setup the start script
COPY --chmod=755 start.sh /start.sh
RUN sed -i 's/\r$//' /start.sh

HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
  CMD nc -z -u 127.0.0.1 ${QUERYPORT:-9877} || exit 1

ENTRYPOINT ["/start.sh"]
