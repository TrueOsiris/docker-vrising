FROM cm2network/steamcmd:root as base-amd64
RUN apt-get update && \
    apt-get install -y \
      wine \
      wine64

FROM --platform=arm64 sonroyaalmerol/steamcmd-arm64:root as base-arm64
COPY install.sh /install.sh
RUN /install.sh
RUN rm /install.sh

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

COPY start.sh /start.sh

USER steam
VOLUME ["/mnt/vrising/server", "/mnt/vrising/persistentdata"]
CMD ["/start.sh"]
