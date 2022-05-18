#!/bin/bash
#if [ -z /mnt/vrising/VRisingServer.exe ]; then
/home/steam/steamcmd/steamcmd.sh +force_install_dir /mnt/vrising +login anonymous +app_update 1829350 +quit
#fi
echo "steam_appid: "`cat /mnt/vrising/steam_appid.txt`
if [ -z /mnt/vrising/ServerGameSettings.json ]; then
	cp /mnt/vrising/VRisingServer_Data/StreamingAssets/Settings/ServerGameSettings.json /mnt/vrising
fi
if [ -z /mnt/vrising/ServerHostSettings.json ]; then
	cp /mnt/vrising/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json /mnt/vrising
fi
/usr/bin/tail -f /var/log/dpkg.log

