#!/bin/bash
s=/mnt/vrising/server
p=/mnt/vrising/persistentdata
d=/mnt/vrising/persistentdata/dotnet
echo " "
echo "Downloading and installing .NET SDK 6.0.300 and core runtime..."
echo " "
mkdir "$d" 2>/dev/null
chmod -R 777 "$d" 2>/dev/null
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
cd /tmp
rm -R /tmp/* 2>/dev/null
if [ ! -f "$d/dotnet" ]; then
	### ARM ###
	#wget https://download.visualstudio.microsoft.com/download/pr/2a6f82fe-0ae8-4867-9664-c8d012301a9a/496da28497b7c7f62151e9837eb5db6f/dotnet-sdk-6.0.300-linux-musl-arm64.tar.gz
	#wget https://download.visualstudio.microsoft.com/download/pr/8ba7087e-4513-41e5-8359-a4bcd2a3661f/e6828f0d8cf1ecc63074c9ff57685e27/aspnetcore-runtime-6.0.5-linux-arm64.tar.gz
	### x64 ###
	wget https://download.visualstudio.microsoft.com/download/pr/dc930bff-ef3d-4f6f-8799-6eb60390f5b4/1efee2a8ea0180c94aff8f15eb3af981/dotnet-sdk-6.0.300-linux-x64.tar.gz
	wget https://download.visualstudio.microsoft.com/download/pr/a0e9ceb8-04eb-4510-876c-795a6a123dda/6141e57558eddc2d4629c7c14c2c6fa1/aspnetcore-runtime-6.0.5-linux-x64.tar.gz

	### ARM ###
	#tar zxf dotnet-sdk-6.0.300-linux-musl-arm64.tar.gz -C "$d"
	#tar zxf aspnetcore-runtime-6.0.5-linux-arm64.tar.gz -C "$d"
	### x64 ###
	tar zxf dotnet-sdk-6.0.300-linux-x64.tar.gz -C "$d"
	tar zxf aspnetcore-runtime-6.0.5-linux-x64.tar.gz -C "$d"
fi
rm -R /tmp/* 2>/dev/null
export DOTNET_ROOT=$d
export PATH=$PATH:$d
mkdir -p /root/.steam 2>/dev/null
chmod -R 777 /root/.steam 2>/dev/null
mkdir "$p/Settings" 2>/dev/null
if [ ! -f "$p/Settings/ServerGameSettings.json" ]; then
        echo "$p/Settings/ServerGameSettings.json not found. Copying default file."
        cp "$s/VRisingServer_Data/StreamingAssets/Settings/ServerGameSettings.json" "$p/Settings/" 2>&1
fi
if [ ! -f "$p/Settings/ServerHostSettings.json" ]; then
        echo "$p/Settings/ServerHostSettings.json not found. Copying default file."
        cp "$s/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json" "$p/Settings/" 2>&1
fi
echo " "
echo "Updating V-Rising Dedicated Server files..."
echo " "
/usr/bin/steamcmd +force_install_dir "$s" +login anonymous +app_update 1829350 +quit
echo "steam_appid: "`cat $s/steam_appid.txt`
echo " "
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
/usr/bin/tail -f /var/log/dpkg.log

