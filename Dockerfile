FROM ghcr.io/linuxserver/baseimage-mono:focal

# set version label
LABEL maintainer="Tim Chaubet"

# set environment variables
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"


