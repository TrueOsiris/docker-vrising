#!/bin/bash
#if [ -z /mnt/vrising/VRisingServer.exe ]; then
s=/mnt/vrising/server
p=/mnt/vrising/persistentdata
/home/steam/steamcmd/steamcmd.sh +force_install_dir "$s" +login anonymous +app_update 1829350 +quit
#fi
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


