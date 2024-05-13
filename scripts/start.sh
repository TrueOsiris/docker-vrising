#!/bin/bash

SERVERNAME=${SERVERNAME:-"trueosiris-V"}
WORLDNAME=${WORLDNAME:-"world1"}

game_port=""
if [ -n "$GAMEPORT" ]; then
	game_port=" -gamePort $GAMEPORT"
fi
query_port=""
if [ -n "$QUERYPORT" ]; then
	query_port=" -queryPort $QUERYPORT"
fi

mkdir -p /root/.steam 2>/dev/null
chmod -R 777 /root/.steam 2>/dev/null

echo " "
echo "Updating V-Rising Dedicated Server files..."
echo " "

/usr/bin/steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "${STEAMAPPSERVER}" +login anonymous +app_update 1829350 validate +quit
echo "steam_appid: $(cat "${STEAMAPPSERVER}"/steam_appid.txt)"

if ! grep -q -o 'avx[^ ]*' /proc/cpuinfo; then
	echo " "
	unsupported_file="VRisingServer_Data/Plugins/x86_64/lib_burst_generated.dll"
	echo "AVX or AVX2 not supported; Check if unsupported ${unsupported_file} exists"
	if [ -f "${STEAMAPPSERVER}/${unsupported_file}" ]; then
		echo "Changing ${unsupported_file} as attempt to fix issues..."
		mv "${STEAMAPPSERVER}/${unsupported_file}" "${STEAMAPPSERVER}/${unsupported_file}.bak"
	fi
fi

if [ ! -d "$LOGSDIR" ]; then mkdir "${STEAMAPPDATA}/Settings"; fi

if [ ! -f "${STEAMAPPDATA}/Settings/ServerGameSettings.json" ]; then
		echo " "
        echo "${STEAMAPPDATA}/Settings/ServerGameSettings.json not found. Copying default file."
        cp "${STEAMAPPSERVER}/VRisingServer_Data/StreamingAssets/Settings/ServerGameSettings.json" "${STEAMAPPDATA}/Settings/"
fi
if [ ! -f "${STEAMAPPDATA}/Settings/ServerHostSettings.json" ]; then
		echo " "
        echo "${STEAMAPPDATA}/Settings/ServerHostSettings.json not found. Copying default file."
        cp "${STEAMAPPSERVER}/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json" "${STEAMAPPDATA}/Settings/"
fi

#Restart cleanup
if [ -f "/tmp/.X0-lock" ]; then 
	echo "Removing /tmp/.X0-lock"
	rm /tmp/.X0-lock 
fi

cd "${STEAMAPPSERVER}" || exit

echo "Starting V Rising Dedicated Server with name $SERVERNAME"
echo " "

echo "Starting Xvfb"
Xvfb :0 -screen 0 1024x768x16 &

echo "Launching wine64 V Rising"
echo " "

# If we dont supply an file for it to log into,
# it will log into console, which is better for us
DISPLAY=:0.0 wine64 "${STEAMAPPSERVER}"/VRisingServer.exe \
	-persistentDataPath "${STEAMAPPDATA}" \
	-serverName "$SERVERNAME" \
	-saveName "$WORLDNAME" "$game_port" "$query_port"
