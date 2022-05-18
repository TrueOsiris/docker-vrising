FROM ghcr.io/linuxserver/baseimage-mono:focal
FROM cm2network/steamcmd:latest

# set version label
LABEL maintainer="Tim Chaubet"

# set environment variables
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"

COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]
