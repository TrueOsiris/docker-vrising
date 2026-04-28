# Troubleshooting

Common issues and solutions for running the V Rising dedicated server in Docker.

## Common Log Messages (Harmless)

Since version 1.1, the logs may frequently display messages like these. You can safely ignore them:

```text
01b4:fixme:winsock:server_ioctl_sock Unsupported ioctl 4004747b (device=4004 access=1 func=d1e method=3)
01b4:fixme:winsock:WSAIoctl unsupported WS_IOCTL cmd (SIO_IDEAL_SEND_BACKLOG_QUERY)
```

## 🛑 Server Not Showing in the Public List

This is the most common issue. If your server is running but you (or your friends) can't see it in the in-game list:

1. **Verify Ports:** Ensure both the Game Port (`27015 UDP`) and the Query Port (`27016 UDP`) are open and forwarded on your router to the internal IP of the machine running Docker. **Both must be UDP.**
2. **Host Firewall:** Check that the firewall on your host machine (e.g., Windows Defender, ufw, firewalld) is allowing UDP traffic on those ports.
3. **List Settings:** Verify your configuration has `HOST_SETTINGS_ListOnSteam=true` and `HOST_SETTINGS_ListOnEOS=true`.
4. **Direct Connect:** Try using the "Direct Connect" button in-game and entering `YOUR_EXTERNAL_IP:27015`. If this works but the list doesn't, your Query Port (`27016`) is likely blocked.

## 💾 Save Corruption & Rollbacks

If your server crashes during a save or power loss, your world might become corrupted. The game automatically keeps a history of auto-saves using the `AutoSaveSmartKeep` system.

**How to roll back your server:**
1. **Stop the server:** `docker-compose down`
2. Navigate to your saves folder: `./persistentdata/Saves/v3/YOUR_WORLD_NAME/`
3. You will see several folders with timestamps (e.g., `AutoSave_20240101_120000`). The game loads the folder named `AutoSave_Latest`.
4. Delete (or move) the `AutoSave_Latest` folder.
5. Find the most recent timestamped folder that you know was working, and **rename it to** `AutoSave_Latest`.
6. **Start the server:** `docker-compose up -d`

## 🧩 Modding Support (BepInEx)

This Docker image provides the **vanilla** V Rising dedicated server. It does not automatically install mod frameworks or plugins.

**How to mod this server:**
- To use mods, you must manually install the **BepInEx** framework into your mapped `./server` volume on the host.
- Most mods involve placing `.dll` files into a `BepInEx/plugins` folder that you create inside the server directory.
- **Note:** Modding may cause stability issues and is not officially supported by this project.

## Windows Docker Host Issues

If you are running Docker on a Windows host and encounter the following exception:

```text
vrising-1 | 0024:err:module:LdrInitializeThunk "UnityPlayer.dll" failed to initialize, aborting
vrising-1 | 0024:err:module:LdrInitializeThunk Initializing dlls for L"Z:\\mnt\\vrising\\server\\VRisingServer.exe" failed, status c0000005
```

**Solution**: You must use absolute paths for your volume mappings. Example:

```yaml
volumes:
  - E:\\my-server-folder\\server:/mnt/vrising/server
```

## Performance & Startup

- **Long Startup Times**: Depending on your hardware and network, the server can take up to **10 minutes** to fully initialize, especially when downloading updates or loading large save files.
- **CPU Requirements**: The server requires a modern CPU. If your CPU does not support AVX/AVX2, some plugins like `lib_burst_generated.dll` might cause crashes. The container includes a fix to disable these plugins if AVX is missing.

## Getting Help

- [V Rising Official Instructions](https://github.com/StunlockStudios/vrising-dedicated-server-instructions)
- [Project GitHub Issues](https://github.com/TrueOsiris/docker-vrising/issues)
