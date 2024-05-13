#!/bin/bash

s=/mnt/vrising/server
p=/mnt/vrising/persistentdata

ARCH=$(dpkg --print-architecture)

if [ -z "$SERVERNAME" ]; then
	SERVERNAME="trueosiris-V"
fi
if [ -z "$WORLDNAME" ]; then
	WORLDNAME="world1"
fi

InstallServer() {
  if [ "$ARCH" == "arm64" ] && [ "${ARM_COMPATIBILITY_MODE,,}" = true ]; then
    ORIG_DEBUGGER=$DEBUGGER
    export DEBUGGER="/usr/bin/qemu-i386-static"

    # Arbitrary number to avoid CPU_MHZ warning due to qemu and steamcmd
    export CPU_MHZ=2000
  fi

  echo " "
  echo "Updating V-Rising Dedicated Server files..."
  echo " "
  unbuffer /home/steam/steamcmd/steamcmd.sh \
    +@sSteamCmdForcePlatformType windows \
    +@sSteamCmdForcePlatformBitness 64 \
    +force_install_dir "$s" \
    +login anonymous \
    +app_update 1829350 validate \
    +quit

  if [ "$ARCH" == "arm64" ] && [ "${ARM_COMPATIBILITY_MODE,,}" = true ]; then
    unset CPU_MHZ
    export DEBUGGER=$ORIG_DEBUGGER
  fi
}

if [ ! -f $s/VRisingServer.exe ]; then
  InstallServer
fi
echo "steam_appid: "`cat $s/steam_appid.txt`


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
mkdir -p "$p/Settings"
if [ ! -f "$p/Settings/ServerGameSettings.json" ]; then
  echo "$p/Settings/ServerGameSettings.json not found. Copying default file."
  cp "$s/VRisingServer_Data/StreamingAssets/Settings/ServerGameSettings.json" "$p/Settings/" 2>&1
fi
if [ ! -f "$p/Settings/ServerHostSettings.json" ]; then
  echo "$p/Settings/ServerHostSettings.json not found. Copying default file."
  cp "$s/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json" "$p/Settings/" 2>&1
fi

# Checks if log file exists, if not creates it
# Needed for fresh install
if ! [ -f "${p}/VRisingServer.log" ]; then
  echo "Creating ${p}/VRisingServer.log"
  touch $p/VRisingServer.log
fi

cd "$s"
echo "Starting V Rising Dedicated Server with name $SERVERNAME"
echo " "
echo "Launching wine64 V Rising"
echo " "

STARTCOMMAND=("xvfb-run")
if [ "$ARCH" == "arm64" ]; then
  STARTCOMMAND+=("/usr/local/bin/box64" "/usr/local/bin/wine64")
else
  STARTCOMMAND+=("/usr/lib/wine/wine64")
fi

STARTCOMMAND+=("/mnt/vrising/server/VRisingServer.exe")
STARTCOMMAND+=("-persistentDataPath" "$p")
STARTCOMMAND+=("-serverName" "$SERVERNAME")
STARTCOMMAND+=("-saveName" "$WORLDNAME")
STARTCOMMAND+=("-logFile" "$p/VRisingServer.log")
#if [ -z $GAMEPORT ]; then
#  STARTCOMMAND+=("-gamePort $GAMEPORT")
#fi
#if [ -z $QUERYPORT ]; then
#  STARTCOMMAND+=("-queryPort $QUERYPORT")
#fi

rm -f /tmp/.X99-lock

echo "${STARTCOMMAND[*]}"
"${STARTCOMMAND[@]}" &

ServerPID=$!

# Tail log file and waits for Server PID to exit
/usr/bin/tail -n 0 -f $p/VRisingServer.log &
wait $ServerPID
