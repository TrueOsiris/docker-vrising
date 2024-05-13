#!/bin/bash
term_handler() {
    echo "Shutting down Server"

    PID=$(pgrep -f "^${s}/VRisingServer.exe")
    kill -n 15 $PID
    wait $PID
    wineserver -k
    sleep 1
    exit
}

if [[ "$(id -u)" -eq 0 ]] && [[ "$(id -g)" -eq 0 ]]; then
    if [[ "${PUID}" -ne 0 ]] && [[ "${PGID}" -ne 0 ]]; then
        echo "EXECUTING USERMOD"
        usermod -o -u "${PUID}" steam
        groupmod -o -g "${PGID}" steam
        chown -R steam:steam /mnt/vrising /home/steam/
    else
        echo "Running as root is not supported, please fix your PUID and PGID!"
        exit 1
    fi
elif [[ "$(id -u)" -eq 0 ]] || [[ "$(id -g)" -eq 0 ]]; then
   echo "Running as root is not supported, please fix your user!"
   exit 1
fi

trap 'term_handler' SIGTERM

if [[ "$(id -u)" -eq 0 ]]; then
    su steam -c /start.sh &
else
    /start.sh &
fi

# Process ID of su
killpid="$!"
wait "$killpid"
