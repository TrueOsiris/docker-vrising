FROM cm2network/steamcmd:root-bookworm
LABEL maintainer="Tim Chaubet"
#VOLUME ["/home/steam/vrising/server", "/home/steam/vrising/persistentdata"]
EXPOSE 9876/udp
# Expose 9876/tcp if using RCON. See RCON_PORT Env variable
EXPOSE 9876
EXPOSE 9877/udp

# Let the user change the user and group ID
ARG STEAM_USER_UID="1000"
ARG STEAM_USER_GID="1000"
ARG SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.29/supercronic-linux-amd64
ARG SUPERCRONIC=supercronic-linux-amd64
ARG SUPERCRONIC_SHA1SUM=cd48d45c4b10f3f0bfdd3a57d054cd05ac96812b

ENV SERVER_DATA_PATH="/home/steam/vrising/server" \
    PERSISTENT_DATA_PATH="/home/steam/vrising/persistentdata" \
    HOST_SETTINGS_NAME="My Docker V-Rising Server" \
    HOST_SETTINGS_DESCRIPTION="V Rising Server hosted by Docker" \
    HOST_SETTINGS_PASSWORD="" \
    HOST_SETTINGS_MAX_CONNECTED_USERS="10" \
    HOST_SETTINGS_MAX_CONNECTED_ADMINS="4" \
    HOST_SETTINGS_SERVER_ADMIN_LIST="" \
    HOST_SETTINGS_SERVER_FPS="30" \
    HOST_SETTINGS_RCON_ENABLE="false" \
    HOST_SETTINGS_RCON_PASSWORD="Ch8ng3m3Pl3@s3!" \
    HOST_SETTINGS_RCON_PORT="9876" \
    HOST_SETTINGS_AUTOSAVE_COUNT="40" \
    HOST_SETTINGS_AUTOSAVE_INTERVAL="120" \
    HOST_SETTINGS_LISTEN_ON_STEAM="true" \ 
    HOST_SETTINGS_LISTEN_ON_EOS="true" \
    GAME_SETTINGS_PRESET="" \
    GAME_SETTINGS_DIFFICULTY="Normal" \
    LIST_ON_MASTER_SERVER="true" \
    SERVER_IP="127.0.0.1" \
    SAVE_NAME="world1" \
    GAME_PORT="9876" \
    QUERY_PORT="9877" \
    DEBUG_ENV="true" \
    LOGDAYS="30" \
    OVERRIDE_CONFIG="false" \
    TZ="Europe/Brussels"

COPY --chown=${STEAM_USER_UID}:${STEAM_USER_GID} --chmod=744 files /home/steam/files/
COPY src/debian.sources /etc/apt/sources.list.d/debian.sources

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# hadolint ignore=DL3008
RUN DEBIAN_FRONTEND=noninteractive \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    supervisor \
    cron \
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
    rm -rf /var/lib/apt/lists/* && \
    usermod -u "${STEAM_USER_UID}" steam && groupmod -g "${STEAM_USER_GID}" steam && \
    chmod +x /home/steam/files/scripts/* && \
    curl -fsSLO "$SUPERCRONIC_URL" && \
    echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - && \
    chmod +x "$SUPERCRONIC" && \
    mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" && \
    ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic && \
    chown -R "${STEAM_USER_UID}:${STEAM_USER_GID}" /home/steam

USER steam

CMD ["/home/steam/files/scripts/entrypoint.sh"]
HEALTHCHECK --start-period=180s \
    CMD /bin/bash /home/steam/files/scripts/healthcheck.sh
