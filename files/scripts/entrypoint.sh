#!/bin/bash
set -eu

echo " "
echo " ================================================================ " 
echo " Welcome to V Rising Docker                                       "
echo " This Server is running a Wine Session                            "
echo " Please refer to the documentation to see config options          "
echo " ================================================================ " 
echo " "

# Print Environment when debugging
if [[ "$DEBUG_ENV" == "true" ]]; then
        echo " "
        echo " ================================================================ " 
        echo " Showing Environment Variables                                    "
        echo " ================================================================ " 
        echo " "
        env
fi

term_handler() {
        echo " "
        echo " ================================================================ " 
        echo " Shutting Down Server due to Termination Signal                   "
        echo " ================================================================ " 
        echo " "
        
	if ! ps -q "$(cat /home/steam/server.pid)" -o state --no-headers | grep -q -v "D|R|S"; then
		echo "Could not find VRisingServer.exe pid. Assuming server is dead..."
	else
                echo "Shutting server down gracefully..."
		kill -n 15 "$(cat /home/steam/server.pid)"
		wait "$(cat /home/steam/server.pid)"
	fi
	wineserver -k
	sleep 1
	exit
}

trap 'term_handler' SIGTERM SIGINT

echo " "
echo " ================================================================ " 
echo " Creating folders and installing Gameserver                       "
echo " ================================================================ " 
echo " "

mkdir -v -p "$SERVER_DATA_PATH"
mkdir -v -p "$PERSISTENT_DATA_PATH"
/home/steam/steamcmd/steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir "$SERVER_DATA_PATH" +login anonymous +app_update 1829350 validate +quit

echo "steam_appid: $(cat "${SERVER_DATA_PATH}"/steam_appid.txt)"

echo " "
echo " ================================================================ " 
echo " Checking AVX CPU Support                                         "
echo " ================================================================ " 
echo " "

if grep -q -o 'avx[^ ]*' /proc/cpuinfo; then
	unsupported_file="VRisingServer_Data/Plugins/x86_64/lib_burst_generated.dll"
	echo "AVX or AVX2 not supported; Check if unsupported ${unsupported_file} exists"
	if [ -f "$SERVER_DATA_PATH/${unsupported_file}" ]; then
		echo "Changing ${unsupported_file} as attempt to fix issues..."
		mv "$SERVER_DATA_PATH/${unsupported_file}" "$SERVER_DATA_PATH/${unsupported_file}.bak"
	fi
else 
        echo "CPU supporting AVX, continuing..."
fi

echo " "
echo " ================================================================ " 
echo " Creating Config Files                                            "
echo " ================================================================ " 
echo " "

mkdir -p "$PERSISTENT_DATA_PATH/Settings"

if [[ "${OVERRIDE_CONFIG}" == "true" ]]; then
	echo "Replacing config files. If you want to change this behaviour, set OVERRIDE_CONFIG to false"
	envsubst < /home/steam/files/config_templates/ServerGameSettings.json.template > "$PERSISTENT_DATA_PATH/Settings/ServerGameSettings.json" 
	envsubst < /home/steam/files/config_templates/ServerHostSettings.json.template > "$PERSISTENT_DATA_PATH/Settings/ServerHostSettings.json" 
elif [[ "${OVERRIDE_CONFIG}" == "false" ]]; then
	if [[ ! -f "$PERSISTENT_DATA_PATH/Settings/ServerGameSettings.json" ]]; then
		echo "Couldn't find $PERSISTENT_DATA_PATH/Settings/ServerGameSettings.json, creating..."
		envsubst < /home/steam/files/config_templates/ServerGameSettings.json.template > "$PERSISTENT_DATA_PATH/Settings/ServerGameSettings.json"
	fi
	if [[ ! -f "$PERSISTENT_DATA_PATH/Settings/ServerHostSettings.json" ]]; then
		echo "Couldn't find $PERSISTENT_DATA_PATH/Settings/ServerHostSettings.json, creating..."
		envsubst < /home/steam/files/config_templates/ServerHostSettings.json.template > "$PERSISTENT_DATA_PATH/Settings/ServerHostSettings.json"
	fi
fi

echo " "
echo " ================================================================ " 
echo " Creating Cron Files                                            "
echo " ================================================================ " 
echo " "

envsubst < /home/steam/files/scripts/cleanlogs.sh.template > /home/steam/files/scripts/cleanlogs.sh 
chmod +x /home/steam/files/scripts/cleanlogs.sh 

# Checks if log file exists, if not creates it
echo " "
echo " ================================================================ " 
echo " Creating Log File                                                "
echo " ================================================================ " 
echo " "

logfile="VRisingServer.log"
if ! [ -f "$PERSISTENT_DATA_PATH/$logfile" ]; then
        echo "Creating $PERSISTENT_DATA_PATH/$logfile"
        touch "$PERSISTENT_DATA_PATH"/"$logfile"
        echo "$PERSISTENT_DATA_PATH/$logfile" > /home/steam/currentlog_path.txt 
fi
echo "$PERSISTENT_DATA_PATH/$logfile" > /home/steam/currentlog_path.txt 


cd "$SERVER_DATA_PATH"

echo " "
echo " ================================================================ " 
echo " Starting Server via Wine                                         "
echo " ================================================================ " 
echo " "

v() {
        xvfb-run \
	--auto-servernum \
	--server-args='-screen 0 640x480x24:32' \
	wine "$SERVER_DATA_PATH"/VRisingServer.exe -persistentDataPath "$PERSISTENT_DATA_PATH" -serverName "$HOST_SETTINGS_NAME" -saveName "$SAVE_NAME" -logFile "$PERSISTENT_DATA_PATH"/"$logfile" "$GAME_PORT" "$QUERY_PORT" 2>&1 &
}
v
# Gets the PID of the last command
ServerPID=$!
echo "Server PID is $ServerPID"
echo "$ServerPID" > /home/steam/server.pid

# Tail log file and waits for Server PID to exit
/usr/bin/tail -n 0 -f "$PERSISTENT_DATA_PATH"/"$logfile" &
wait $ServerPID
