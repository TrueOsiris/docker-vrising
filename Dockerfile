FROM cm2network/steamcmd:root-bookworm
LABEL maintainer="Panromir <panromir@gmail.com>"
#VOLUME ["/home/steam/vrising/server", "/home/steam/vrising/persistentdata"]
EXPOSE 9876/udp
# Expose 9876/tcp if using RCON. See RCON_PORT Env variable
EXPOSE 9876
EXPOSE 9877/udp

ENV SERVER_DATA_PATH="/home/steam/vrising/server" \
    PERSISTENT_DATA_PATH="/home/steam/vrising/persistentdata" \
    HOST_SETTINGS_NAME="My Docker V-Rising Server" \
    HOST_SETTINGS_DESCRIPTION="V Rising Server hosted by Docker" \
    HOST_SETTINGS_PASSWORD="" \
    HOST_SETTINGS_MAX_CONNECTED_USERS="10" \
    HOST_SETTINGS_MAX_CONNECTED_ADMINS="4" \
    HOST_SETTINGS_SERVER_ADMIN_LIST="12345678,234567891" \
    HOST_SETTINGS_SERVER_FPS="30" \
    HOST_SETTINGS_RCON_ENABLE="true" \
    HOST_SETTINGS_RCON_PASSWORD="Ch8ng3m3Pl3@s3!" \
    HOST_SETTINGS_RCON_PORT="9876" \
    HOST_SETTINGS_AUTOSAVE_COUNT="40" \
    HOST_SETTINGS_AUTOSAVE_INTERVAL="120" \
    HOST_SETTINGS_LISTEN_ON_STEAM="false" \ 
    HOST_SETTINGS_LISTEN_ON_EOS="false" \
    GAME_SETTINGS_PRESET="StandardPvP" \
    GAME_SETTINGS_DIFFICULTY="Normal" \
    LIST_ON_MASTER_SERVER="true" \
    SERVER_IP="127.0.0.1" \
    SAVE_NAME="default_world" \
    GAME_PORT="9876" \
    QUERY_PORT="9877" \
    STEAM_USER_UID="1000" \
    STEAM_USER_GID="1000" \
    DEBUG_ENV="true"

COPY --chown=steam:steam --chmod=744 files /home/steam/files/
COPY src/debian.sources /etc/apt/sources.list.d/debian.sources

# hadolint ignore=DL3008
RUN DEBIAN_FRONTEND=noninteractive \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    gettext-base \
    procps \
    wine \
    wine32 \
    wine64 \
    winbind \
    xvfb \
    xauth \
    mingw-w64 \
    screen && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* &&\
    chmod +x /home/steam/files/scripts/* 

USER steam

CMD ["/home/steam/files/scripts/entrypoint.sh"]
HEALTHCHECK --start-period=180s \
    CMD /bin/bash /home/steam/files/scripts/healthcheck.sh
