#!/bin/bash
s=/mnt/vrising/server
p=/mnt/vrising/persistentdata
echo "Setting timezone to $TZ"
echo $TZ > /etc/timezone 2>&1
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime 2>&1
dpkg-reconfigure -f noninteractive tzdata 2>&1
if [ ! -z $UID ]; then
	usermod -u $UID docker 2>&1
fi 
if [ ! -z $GID ]; then
	groupmod -g $GID docker 2>&1
fi
if [ -z $SERVERNAME ]; then
	SERVERNAME="trueosiris-V"
fi
if [ -z $WORLDNAME ]; then
	WORLDNAME="world1"
fi
game_port=""
if [ ! -z $GAMEPORT ]; then
	game_port=" -gamePort $GAMEPORT"
fi
query_port=""
if [ ! -z $QUERYPORT ]; then
	query_port=" -queryPort $QUERYPORT"
fi
mkdir -p /root/.steam 2>/dev/null
chmod -R 777 /root/.steam 2>/dev/null
echo " "
echo "Updating V-Rising Dedicated Server files..."
echo " "
/usr/bin/steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "$s" +login anonymous +app_update 1829350 validate +quit
echo "steam_appid: "`cat $s/steam_appid.txt`

echo " "
if ! grep -o 'avx[^ ]*' /proc/cpuinfo; then
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
cd "$s"
echo "Starting V Rising Dedicated Server with name $SERVERNAME"
echo "Trying to remove /tmp/.X0-lock"
rm /tmp/.X0-lock 2>&1
echo " "
echo "Starting Xvfb"
Xvfb :0 -screen 0 1024x768x16 &
echo "Launching wine64 V Rising"
echo " "
DISPLAY=:0.0 wine64 /mnt/vrising/server/VRisingServer.exe -persistentDataPath $p -serverName "$SERVERNAME" -saveName "$WORLDNAME" -logFile "$p/VRisingServer.log" "$game_port" "$query_port" 2>&1
/usr/bin/tail -f /mnt/vrising/persistentdata/VRisingServer.log

