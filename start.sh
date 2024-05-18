#!/bin/bash
s=/mnt/vrising/server
p=/mnt/vrising/persistentdata

term_handler() {
    echo "Shutting down Server"

    PID=$(pgrep -f "^${s}/VRisingServer.exe")
    if [[ -z $PID ]]; then
    	echo "Could not find VRisingServer.exe pid. Assuming server is dead..."
  	else
	    kill -n 15 "$PID"
	    wait "$PID"
    fi
    wineserver -k
    sleep 1
    exit
}

cleanup_logs() {
    echo "Cleaning up logs older than $LOGDAYS days"
    find "$p" -name "*.log" -type f -mtime +$LOGDAYS -exec rm {} \;
}

trap 'term_handler' SIGTERM

if [ -z "$LOGDAYS" ]; then
    LOGDAYS=30
fi
if [[ -n $UID ]]; then
	usermod -u "$UID" docker 2>&1
fi 
if [[ -n $GID ]]; then
	groupmod -g "$GID" docker 2>&1
fi
if [ -z "$SERVERNAME" ]; then
	SERVERNAME="trueosiris-V"
fi
override_savename=""
if [[ -n "$WORLDNAME" ]]; then
	override_savename="-saveName $WORLDNAME"
fi
game_port=""
if [[ -n $GAMEPORT ]]; then
	game_port=" -gamePort $GAMEPORT"
fi
query_port=""
if [[ -n $QUERYPORT ]]; then
	query_port=" -queryPort $QUERYPORT"
fi

cleanup_logs

mkdir -p /root/.steam 2>/dev/null
chmod -R 777 /root/.steam 2>/dev/null
echo " "
echo "Updating V-Rising Dedicated Server files..."
echo " "
/usr/bin/steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "$s" +login anonymous +app_update 1829350 validate +quit
printf "steam_appid: "
cat "$s/steam_appid.txt"

echo " "
if ! grep -q -o 'avx[^ ]*' /proc/cpuinfo; then
	unsupported_file="VRisingServer_Data/Plugins/x86_64/lib_burst_generated.dll"
	echo "AVX or AVX2 not supported; Check if unsupported ${unsupported_file} exists"
	if [ -f "${s}/${unsupported_file}" ]; then
		echo "Changing ${unsupported_file} as attempt to fix issues..."
		mv "${s}/${unsupported_file}" "${s}/${unsupported_file}.bak"
	fi
fi

echo " "
mkdir "$p/Settings" 2>/dev/null
if [ ! -f "$p/Settings/ServerGameSettings.json" ]; then
        echo "$p/Settings/ServerGameSettings.json not found. Copying default file."
        cp "$s/VRisingServer_Data/StreamingAssets/Settings/ServerGameSettings.json" "$p/Settings/" 2>&1
fi
if [ ! -f "$p/Settings/ServerHostSettings.json" ]; then
        echo "$p/Settings/ServerHostSettings.json not found. Copying default file."
        cp "$s/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json" "$p/Settings/" 2>&1
fi

# Checks if log file exists, if not creates it
current_date=$(date +"%Y%m%d-%H%M")
logfile="$current_date-VRisingServer.log"
if ! [ -f "${p}/$logfile" ]; then
        echo "Creating ${p}/$logfile"
        touch "$p/$logfile"
fi

cd "$s" || { echo "Failed to cd to $s"; exit 1; }
echo "Starting V Rising Dedicated Server with name $SERVERNAME"
echo "Trying to remove /tmp/.X0-lock"
rm /tmp/.X0-lock 2>&1
echo " "
echo "Starting Xvfb"
Xvfb :0 -screen 0 1024x768x16 &
echo "Launching wine64 V Rising"
echo " "
v() {
	DISPLAY=:0.0 wine64 /mnt/vrising/server/VRisingServer.exe -persistentDataPath $p -serverName "$SERVERNAME" "$override_savename" -logFile "$p/$logfile" "$game_port" "$query_port" 2>&1 &
}
v
# Gets the PID of the last command
ServerPID=$!

# Tail log file and waits for Server PID to exit
/usr/bin/tail -n 0 -f "$p/$logfile" &
wait $ServerPID
