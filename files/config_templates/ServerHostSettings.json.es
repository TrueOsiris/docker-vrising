{
  "Name": "${HOST_SETTINGS_NAME}",
  "Description": "${HOST_SETTINGS_DESCRIPTION}",
  "Port": ${GAME_PORT},
  "QueryPort": ${QUERY_PORT},
  "MaxConnectedUsers": ${HOST_SETTINGS_MAX_CONNECTED_USERS},
  "MaxConnectedAdmins": ${HOST_SETTINGS_MAX_CONNECTED_ADMINS},
  "ServerFps": ${HOST_SETTINGS_SERVER_FPS},
  "SaveName": "${SAVE_NAME}",
  "Password": "${HOST_SETTINGS_PASSWORD}",
  "Secure": true,
  "ListOnSteam": ${HOST_SETTINGS_LISTEN_ON_STEAM},
  "ListOnEOS": ${HOST_SETTINGS_LISTEN_ON_EOS},
  "AutoSaveCount": ${HOST_SETTINGS_AUTOSAVE_COUNT},
  "AutoSaveInterval": ${HOST_SETTINGS_AUTOSAVE_INTERVAL},
  "CompressSaveFiles": true,
  "GameSettingsPreset": "${GAME_SETTINGS_PRESET}",
  "GameDifficultyPreset": "",
  "AdminOnlyDebugEvents": true,
  "DisableDebugEvents": false,
  "API": {
    "Enabled": false
  },
  "Rcon": {
    "Enabled": ${HOST_SETTINGS_RCON_ENABLE},
    "Port": ${HOST_SETTINGS_RCON_PORT},
    "Password": "${HOST_SETTINGS_RCON_PASSWORD}"
  }
}