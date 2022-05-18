#!/bin/bash
s=/mnt/vrising/server
p=/mnt/vrising/persistentdata
cd "$s"
set SteamAppId=`cat $s/steam_appid.txt`
echo "Starting mono ..."
echo "SteamAppId set to $SteamAppId"
echo " "
#VRisingServer.exe -persistentDataPath .\save-data -serverName "My V Rising Server" -saveName "world1" -logFile ".\logs\VRisingServer.log"

/usr/bin/tail -f /var/log/dpkg.log

