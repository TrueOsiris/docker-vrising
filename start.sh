#!/bin/bash
#if [ -z /mnt/vrising/VRisingServer.exe ]; then
/home/steam/steamcmd/steamcmd.sh +force_install_dir /mnt/vrising +login anonymous +app_update 1829350 +quit
#fi
echo "steam_appid: "`cat /mnt/vrising/steam_appid.txt`
echo " "
if [ ! -f "/mnt/vrising/ServerGameSettings.json" ]; then
	echo "/mnt/vrising/ServerGameSettings.json not found. Copying default file."
	cp /mnt/vrising/VRisingServer_Data/StreamingAssets/Settings/ServerGameSettings.json /mnt/vrising/ 2>&1
fi
if [ ! -f "/mnt/vrising/ServerHostSettings.json" ]; then
	echo "/mnt/vrising/ServerHostSettings.json not found. Copying default file."
	cp /mnt/vrising/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json /mnt/vrising/ 2>&1
fi
/usr/bin/tail -f /var/log/dpkg.log

