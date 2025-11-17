#!/bin/bash
s=/mnt/vrising/server
p=/mnt/vrising/persistentdata

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
	find "$p" -name "*.log" -type f -mtime +$LOGDAYS -exec rm {} \;
}

trap 'term_handler' SIGTERM

if [ -z "$LOGDAYS" ]; then
	LOGDAYS=30
fi
if [[ -n $UID ]]; then
	usermod -u "$UID" docker 2>&1
fi
if [[ -n $GID ]]; then
	groupmod -g "$GID" docker 2>&1
fi
if [ -z "$SERVERNAME" ]; then
	SERVERNAME="trueosiris-V"
fi
override_savename=""
if [[ -n "$WORLDNAME" ]]; then
	override_savename="-saveName $WORLDNAME"
fi
game_port=""
if [[ -n $GAMEPORT ]]; then
	game_port=" -gamePort $GAMEPORT"
fi
query_port=""
if [[ -n $QUERYPORT ]]; then
	query_port=" -queryPort $QUERYPORT"
fi

beta_arg=""
if [ -n "$BRANCH" ]; then
  beta_arg=" -beta $BRANCH" 
fi
cleanup_logs

mkdir -p /root/.steam 2>/dev/null
chmod -R 777 /root/.steam 2>/dev/null
echo " "
echo "Updating V-Rising Dedicated Server files..."
echo " "
/usr/bin/steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "$s" +login anonymous +app_update 1829350 $beta_arg validate +quit
printf "steam_appid: "
cat "$s/steam_appid.txt"

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
        # Remove the prefix and convert to lowercase for matching
        local stripped_name="${var#${prefix}}"
        # Convert to lowercase and replace underscores with dots for nested paths
        local search_key=$(echo "$stripped_name" | tr '[:upper:]' '[:lower:]' | sed 's/__/./g')

        # Find the key path with case-insensitive matching and get the original value type
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
                    # Convert to lowercase for case-insensitive comparison
                    local lower_value=$(echo "$raw_value" | tr '[:upper:]' '[:lower:]')
                    if [[ ! "$lower_value" =~ ^(true|false)$ ]]; then
                        echo "Error: '$matched_path' must be a boolean (true/false), skipping..."
                        continue
                    fi
                    # Always use lowercase true/false in the output
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
                    # Special handling for array types - try to parse as JSON array
                    if [[ "$raw_value" =~ ^\[.*\]$ ]]; then
                        # If it looks like a JSON array, try to parse it
                        if jq -e . <<< "$raw_value" >/dev/null 2>&1; then
                            jq_set="$jq_path = $raw_value"
                        else
                            echo "Error: Invalid JSON array format for '$matched_path', skipping..."
                            continue
                        fi
                    else
                        # If it's not a JSON array, treat as a single value array
                        jq_set="$jq_path = [\"$raw_value\"]"
                    fi
                    ;;
                *)
                    # For unknown types, try to preserve the original type
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
            else
                echo "Failed to update: $matched_path"
                echo "   jq command: jq '$jq_set' $tmp_file"
            fi
        else
            # Try to find the key with exact case for better error message
            local exact_key=$(echo "$stripped_name" | tr '_' '.')
            local key_exists=false

            # Check if the key exists in the JSON (case insensitive)
            if jq -e --arg key "$exact_key" '
                def key_exists($obj; $key_parts):
                    if ($key_parts | length) == 0 then
                        true
                    else
                        $obj | to_entries | any(
                            .key | ascii_downcase == $key_parts[0]
                            and key_exists(.value; $key_parts[1:])
                        )
                    end;
                key_exists(.; $key | split("."))
            ' "$tmp_file" >/dev/null 2>&1; then
                echo "Found key but couldn't update (possible type mismatch): $stripped_name"
            else
                echo "Ignoring non-existent setting: $stripped_name"
            fi
        fi
    done

    mv "$tmp_file" "$json_file"
    echo "Finished updating $json_file"
}

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

cd "$s" || {
	echo "Failed to cd to $s"
	exit 1
}
echo "Starting V Rising Dedicated Server with name $SERVERNAME"
echo "Trying to remove /tmp/.X0-lock"
rm /tmp/.X0-lock 2>&1
echo " "
echo "Starting Xvfb"
Xvfb :0 -screen 0 1024x768x16 &
echo "Launching wine64 V Rising"
echo " "
v() {
	DISPLAY=:0.0 wine64 /mnt/vrising/server/VRisingServer.exe -persistentDataPath $p -serverName "$SERVERNAME" "$override_savename" -logFile "$p/$logfile" "$game_port" "$query_port" 2>&1 &
}
v
# Gets the PID of the last command
ServerPID=$!

# Tail log file and waits for Server PID to exit
/usr/bin/tail -n 0 -f "$p/$logfile" &
wait $ServerPID
