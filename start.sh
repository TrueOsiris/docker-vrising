#!/bin/bash

# Configuration paths
s=/mnt/vrising/server
p=/mnt/vrising/persistentdata

# --- PRE-START (Root Operations) ---
if [ "$(id -u)" = '0' ]; then
    echo "Running as root, setting up permissions..."

    # Support for PUID/PGID
    PUID=${PUID:-1000}
    PGID=${PGID:-1000}

    echo "Ensuring steam user matches PUID:PGID ($PUID:$PGID)"
    groupmod -o -g "$PGID" steam
    usermod -o -u "$PUID" steam

    # Ensure directories exist and are owned by steam
    mkdir -p "$s" "$p" "/home/steam/.steam"
    chown -R steam:steam "$s" "$p" "/home/steam"

    # Fix for Xvfb lock if it exists
    rm -f /tmp/.X0-lock

    echo "Switching to steam user and continuing..."
    exec gosu steam "$0" "$@"
fi

# --- RUNTIME (Steam User Operations) ---

term_handler() {
	echo "Shutting down Server"

	PID=$(pgrep -f "^${s}/VRisingServer.exe")
	if [[ -z $PID ]]; then
		echo "Could not find VRisingServer.exe pid. Assuming server is dead..."
	else
		kill -n 15 "$PID"
		wait "$PID"
	fi
	wineserver -k
	sleep 1
	exit
}

cleanup_logs() {
	echo "Cleaning up logs older than $LOGDAYS days"
	find "$p" -name "*.log" -type f -mtime +"$LOGDAYS" -exec rm {} \;
}

trap 'term_handler' SIGTERM

# Default Environment Variables
LOGDAYS=${LOGDAYS:-30}
SERVERNAME=${SERVERNAME:-"vrising-dedicated"}
WORLDNAME=${WORLDNAME:-""}
GAMEPORT=${GAMEPORT:-""}
QUERYPORT=${QUERYPORT:-""}
BRANCH=${BRANCH:-""}

override_savename=""
if [[ -n "$WORLDNAME" ]]; then
	override_savename="-saveName $WORLDNAME"
fi

game_port=""
if [[ -n "$GAMEPORT" ]]; then
	game_port=" -gamePort $GAMEPORT"
fi

query_port=""
if [[ -n "$QUERYPORT" ]]; then
	query_port=" -queryPort $QUERYPORT"
fi

beta_arg=""
if [ -n "$BRANCH" ]; then
  beta_arg=" -beta $BRANCH" 
fi

cleanup_logs

# SteamCMD Update
echo " "
echo "Updating V-Rising Dedicated Server files..."
echo " "

# Phase 1: Update SteamCMD itself to avoid restart loops breaking arguments
echo "Update SteamCMD..."
steamcmd +login anonymous +quit

# Phase 2: Install the game
echo "Installing/Updating V Rising..."
steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "$s" +login anonymous +app_info_update 1 +app_update 1829350 $beta_arg validate +quit

if [ -f "$s/steam_appid.txt" ]; then
    printf "steam_appid: "
    cat "$s/steam_appid.txt"
fi

echo " "
if ! grep -q -o 'avx[^ ]*' /proc/cpuinfo; then
	unsupported_file="VRisingServer_Data/Plugins/x86_64/lib_burst_generated.dll"
	echo "AVX or AVX2 not supported; Check if unsupported ${unsupported_file} exists"
	if [ -f "${s}/${unsupported_file}" ]; then
		echo "Changing ${unsupported_file} as attempt to fix issues..."
		mv "${s}/${unsupported_file}" "${s}/${unsupported_file}.bak"
	fi
fi

# Function to update JSON settings using jq
update_json_settings() {
    local json_file="$1"
    local prefix="$2"
    local tmp_file="${json_file}.tmp"

    if ! command -v jq &> /dev/null; then
        echo "jq not found, cannot update JSON."
        return 1
    fi

    cp "$json_file" "$tmp_file"

    # Get all environment variables with the given prefix
    mapfile -t env_vars < <(env | grep -E "^${prefix}[^=]+" | cut -d= -f1)

    for var in "${env_vars[@]}"; do
        local raw_value="${!var}"
        local stripped_name="${var#${prefix}}"
        local search_key=$(echo "$stripped_name" | tr '[:upper:]' '[:lower:]' | sed 's/__/./g')

        local key_info
        key_info=$(jq -r --arg key "$search_key" '
            def find_path($obj; $key_parts; $current_path; $current_type):
                if ($key_parts | length) == 0 then
                    {path: $current_path, type: $current_type}
                else
                    $obj | to_entries | .[] |
                    select(.key | ascii_downcase == $key_parts[0]) |
                    find_path(.value; $key_parts[1:];
                             $current_path + [.key];
                             .value | type) // empty
                end;

            ($key | split(".")) as $key_parts |
            find_path(.; $key_parts; []; null) |
            "\(.path | join(".")),\(.type)"
        ' "$tmp_file" 2>/dev/null)

        if [ -n "$key_info" ]; then
            IFS=',' read -r matched_path value_type <<< "$key_info"
            local jq_path=""
            IFS='.' read -ra parts <<< "$matched_path"
            for part in "${parts[@]}"; do
                jq_path+=".\"$part\""
            done

            local jq_set
            case "$value_type" in
                "string")
                    jq_set="$jq_path = \"${raw_value//\"/\\\"}\""
                    ;;
                "boolean")
                    local lower_value=$(echo "$raw_value" | tr '[:upper:]' '[:lower:]')
                    if [[ ! "$lower_value" =~ ^(true|false)$ ]]; then
                        echo "Error: '$matched_path' must be a boolean (true/false), skipping..."
                        continue
                    fi
                    jq_set="$jq_path = $lower_value"
                    ;;
                "number"|"integer")
                    if [[ ! "$raw_value" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
                        echo "Error: '$matched_path' must be a number, skipping..."
                        continue
                    fi
                    jq_set="$jq_path = $raw_value"
                    ;;
                "array")
                    if [[ "$raw_value" =~ ^\[.*\]$ ]]; then
                        if jq -e . <<< "$raw_value" >/dev/null 2>&1; then
                            jq_set="$jq_path = $raw_value"
                        else
                            echo "Error: Invalid JSON array format for '$matched_path', skipping..."
                            continue
                        fi
                    else
                        jq_set="$jq_path = [\"$raw_value\"]"
                    fi
                    ;;
                *)
                    if [[ "$raw_value" =~ ^(true|false)$ ]]; then
                        jq_set="$jq_path = $raw_value"
                    elif [[ "$raw_value" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
                        jq_set="$jq_path = $raw_value"
                    else
                        jq_set="$jq_path = \"${raw_value//\"/\\\"}\""
                    fi
                    ;;
            esac

            if jq -e "$jq_set" "$tmp_file" > "${tmp_file}.new" 2>/dev/null; then
                mv "${tmp_file}.new" "$tmp_file"
            fi
        fi
    done

    mv "$tmp_file" "$json_file"
    echo "Finished updating $json_file"
}

echo " "
mkdir -p "$p/Settings" 2>/dev/null
if [ ! -f "$p/Settings/ServerGameSettings.json" ]; then
	echo "$p/Settings/ServerGameSettings.json not found. Copying default file."
	cp "$s/VRisingServer_Data/StreamingAssets/Settings/ServerGameSettings.json" "$p/Settings/" 2>&1
fi
if [ ! -f "$p/Settings/ServerHostSettings.json" ]; then
	echo "$p/Settings/ServerHostSettings.json not found. Copying default file."
	cp "$s/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json" "$p/Settings/" 2>&1
fi

# Update settings from environment variables
if [ $(env | grep -c '^GAME_SETTINGS_') -gt 0 ]; then
  echo "Updating game settings from environment variables..."
  update_json_settings "$p/Settings/ServerGameSettings.json" "GAME_SETTINGS_"
fi

if [ $(env | grep -c '^HOST_SETTINGS_') -gt 0 ]; then
  echo "Updating host settings from environment variables..."
  update_json_settings "$p/Settings/ServerHostSettings.json" "HOST_SETTINGS_"
fi

# Checks if log file exists, if not creates it
current_date=$(date +"%Y%m%d-%H%M")
logfile="$current_date-VRisingServer.log"
if ! [ -f "${p}/$logfile" ]; then
	echo "Creating ${p}/$logfile"
	touch "$p/$logfile"
fi

cd "$s" || exit 1

echo "Starting V Rising Dedicated Server with name $SERVERNAME"
echo " "
echo "Starting Xvfb"
Xvfb :0 -screen 0 1024x768x16 &

echo "Waiting for Xvfb to be ready..."
sleep 2

echo "Initializing Wine prefix..."
WINEDLLOVERRIDES="mscoree,mshtml=" DISPLAY=:0.0 wineboot --init
sleep 2

echo "Launching wine64 V Rising"
echo " "

DISPLAY=:0.0 wine64 /mnt/vrising/server/VRisingServer.exe -persistentDataPath "$p" -serverName "$SERVERNAME" "$override_savename" -logFile "$p/$logfile" "$game_port" "$query_port" 2>&1 &
ServerPID=$!

/usr/bin/tail -n 0 -f "$p/$logfile" &
wait $ServerPID
