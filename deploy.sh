#!/bin/bash
s=/mnt/vrising/server
p=/mnt/vrising/persistentdata
/usr/bin/steamcmd +force_install_dir "$s" +login anonymous +app_update 1829350 +quit
echo "steam_appid: "`cat $s/steam_appid.txt`
echo " "
if [ ! -f "$p/ServerGameSettings.json" ]; then
	echo "$p/ServerGameSettings.json not found. Copying default file."
	cp "$s/VRisingServer_Data/StreamingAssets/Settings/ServerGameSettings.json" "$p/" 2>&1
fi
if [ ! -f "$p/ServerHostSettings.json" ]; then
	echo "$p/ServerHostSettings.json not found. Copying default file."
	cp "$s/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json" "$p/" 2>&1
fi
cd "$s"
set SteamAppId=`cat $s/steam_appid.txt`
echo "Starting V Rising Dedicated Server - PRESS CTRL-C to exit"
echo "SteamAppId set to $SteamAppId"
echo " "
exit 0
