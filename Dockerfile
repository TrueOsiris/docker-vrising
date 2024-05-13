FROM cm2network/steamcmd:root as base-amd64
RUN apt-get update && \
    apt-get install -y \
      wine \
      wine64

FROM --platform=arm64 sonroyaalmerol/steamcmd-arm64:root as base-arm64
COPY install.sh /install.sh
RUN /install.sh
RUN rm /install.sh
# Weird bug that causes the first wineboot to fail. So lets create it first and just kill wineboot directly
RUN su steam -c "/usr/local/bin/box64 /usr/local/bin/wine64 /usr/local/bin/wineboot -f -p 10 || echo 0" ;
#   su steam -c "WINE="/usr/local/bin/box86 /usr/loca/bin/wine" WINEPREFIX=/home/steam/.wine winetricks wininet=native"


LABEL maintainer="Tim Chaubet" \
  name="TrueOsiris/docker-vrising" \
  github="https://github.com/TrueOsiris/docker-vrising" \
  dockerhub="https://hub.docker.com/r/trueosiris/vrising" \
  org.opencontainers.image.authors="Tim Chaubet" \
  org.opencontainers.image.source="https://github.com/TrueOsiris/docker-vrising"

ARG TARGETARCH=

FROM base-${TARGETARCH}
ARG DEBIAN_FRONTEND="noninteractive"

RUN apt-get update && \
    apt-get install -y \
      xserver-xorg \
      xvfb \
      expect

RUN rm -rf /var/lib/apt/lists/* && \
  apt clean && \
  apt autoremove -y

COPY init.sh /init.sh
COPY start.sh /start.sh

ENV PUID=1000 \
    PGID=1000 \
    TZ=UTC \
    ARM_COMPATIBILITY_MODE=false \
    BOX86_NOBANNER=1

VOLUME ["/mnt/vrising/server", "/mnt/vrising/persistentdata"]
CMD ["/init.sh"]
