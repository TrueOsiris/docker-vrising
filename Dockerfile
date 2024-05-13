FROM cm2network/steamcmd:root as base-amd64
RUN apt-get update && \
    apt-get install -y \
      wine \
      wine64 \
      xserver-xorg \
      xvfb \
      expect

FROM --platform=arm64 sonroyaalmerol/steamcmd-arm64:root as base-arm64
COPY install.sh /install.sh
RUN /install.sh
RUN apt-get install -y \
      xserver-xorg \
      xvfb \
      expect

# Weird bug that causes the first wineboot to hang. So lets create it first and just kill wineboot directly
# If this doesn't long enough some crypto issues pop up. Missing certificates, missing randomness source
RUN su steam -c "timeout 30 xvfb-run /usr/local/bin/box64 /usr/local/bin/wine64 /usr/local/bin/wineboot -f || echo 0"

ARG TARGETARCH=
FROM base-${TARGETARCH}
ARG DEBIAN_FRONTEND="noninteractive"

LABEL maintainer="Tim Chaubet" \
  name="TrueOsiris/docker-vrising" \
  github="https://github.com/TrueOsiris/docker-vrising" \
  dockerhub="https://hub.docker.com/r/trueosiris/vrising" \
  org.opencontainers.image.authors="Tim Chaubet" \
  org.opencontainers.image.source="https://github.com/TrueOsiris/docker-vrising"

COPY init.sh /init.sh
COPY start.sh /start.sh

ENV PUID=1000 \
    PGID=1000 \
    TZ=UTC \
    ARM_COMPATIBILITY_MODE=false \

VOLUME ["/mnt/vrising/server", "/mnt/vrising/persistentdata"]
CMD ["/init.sh"]
