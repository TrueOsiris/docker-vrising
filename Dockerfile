USER root
LABEL maintainer="Tim Chaubet"
ARG DEBIAN_FRONTEND="noninteractive"
VOLUME ["/mnt/vrising/server", "/mnt/vrising/persistentdata"]

FROM cm2network/steamcmd:latest AS steamdeploy
COPY deploy.sh /deploy.sh
RUN chmod +x /deploy.sh
RUN deploy.sh

FROM ghcr.io/linuxserver/baseimage-mono:focal
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]
