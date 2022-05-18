FROM ghcr.io/linuxserver/baseimage-mono:focal
FROM cm2network/steamcmd:latest
USER root
LABEL maintainer="Tim Chaubet"
ARG DEBIAN_FRONTEND="noninteractive"
COPY start.sh /start.sh
RUN chmod +x /start.sh
VOLUME ["/mnt/vrising/server", "/mnt/vrising/persistentdata"]
CMD ["/start.sh"]
