# Data & Save Management

This document explains how your server data is stored and how to manage your game saves.

## Volumes & Persistence

To ensure your server data survives a container restart, you must map the following volumes to your host machine:

| Host Path | Container Path | Description |
| :--- | :--- | :--- |
| `./server` | `/mnt/vrising/server` | Installation files for the dedicated server (from Steam). |
| `./persistentdata` | `/mnt/vrising/persistentdata` | Your world saves, settings, and logs. |

### Storage Tips
- **Disk Space**: The initial server download takes several GB. Ensure your host machine has sufficient space.
- **Backups**: We recommend backing up your `persistentdata/Saves` directory regularly.

## 🕒 Automated Backups (Linux)

You can use a simple `cron` job on your host machine to automate backups of your world saves.

1. Open your host's crontab:
   ```bash
   crontab -e
   ```
2. Add the following line to create a compressed backup at 3:00 AM every day:
   ```bash
   0 3 * * * tar -czf /path/to/your/backups/vrising_$(date +\%Y\%m\%d).tar.gz /path/to/your/persistentdata/Saves >/dev/null 2>&1
   ```
*Replace `/path/to/your/backups` and `/path/to/your/persistentdata` with your actual absolute paths.*

## Migrating a Local Save

If you want to move a save from your local PC to your dedicated server:

1. **Locate Local Save**: Find your save files on your local machine (typically in `%AppData%\LocalLow\Stunlock Studios\VRising\Saves`).
2. **Stop Server**: Stop your Docker container.
3. **Copy Files**: Overwrite the contents of the `persistentdata/Saves` directory on your Docker host with your local save data.
4. **Restart Server**: Relaunch the container.

## Using a Custom Settings Preset

If you have a `Custom.json` configuration file:
1. Start the server once to generate the directory structure.
2. Stop the server.
3. Place your `Custom.json` into the `persistentdata` folder.
4. In your `ServerHostSettings.json`, update the following line:
   ```json
   "GameSettingsPreset": "Custom"
   ```
5. Restart the server.
