# Server Configuration

The V Rising Docker image provides three ways to configure your server: environment variables, dynamic JSON patching, and direct file editing.

## 1. Core Environment Variables

These variables control the basic identity and networking of your server.

| Variable | Default | Description |
| :--- | :--- | :--- |
| `TZ` | `Europe/Rome` | Timezone for the server logs and scheduling. |
| `SERVERNAME` | `vrising-dedicated` | The name of your server as it appears in the server list. |
| `WORLDNAME` | `world1` | The name of the world save file. |
| `GAMEPORT` | `9876` | The UDP port for game traffic. |
| `QUERYPORT` | `9877` | The UDP port for Steam query traffic. |
| `LOGDAYS` | `30` | Number of days to keep server logs before automatic cleanup. |
| `BRANCH` | `(latest)` | Optional: Use `legacy-1.0.x-pc` to run an older version. |

## 2. Dynamic JSON Configuration (Recommended)

You can modify almost any setting in `ServerGameSettings.json` and `ServerHostSettings.json` directly from your `docker-compose.yml` or Docker CLI using environment variable prefixes.

### Basic Usage
- Use `GAME_SETTINGS_` to patch `ServerGameSettings.json`
- Use `HOST_SETTINGS_` to patch `ServerHostSettings.json`

Example:
```yaml
environment:
  - HOST_SETTINGS_ListOnSteam=true
  - HOST_SETTINGS_ListOnEOS=true
  - GAME_SETTINGS_GameModeType=PvE
```

### Nested Parameters
V Rising settings are often nested. Use a double underscore (`__`) to navigate through JSON levels.

Example:
```yaml
environment:
  - HOST_SETTINGS_Rcon__Enabled=true
  - HOST_SETTINGS_Rcon__Password=mypassword
  - GAME_SETTINGS_UnitStatModifiers_Global__MaxHealthModifier=2
  - GAME_SETTINGS_CastleStatModifiers_Global__HeartLimits__Level1__FloorLimit=100
```

### Features
- **Case-Insensitive**: Both `HOST_SETTINGS_ListOnSteam` and `HOST_SETTINGS_LISTONSTEAM` work.
- **Fail-Safe**: If you provide a setting that doesn't exist, it will be ignored.
- **Type Validation**: If a setting expects a number and you provide a string, the update will be skipped to prevent corruption.

## 3. Direct File Editing

You can also edit the JSON files directly on your host machine. They are located in your persistent data directory:
- `/mnt/vrising/persistentdata/Settings/ServerGameSettings.json`
- `/mnt/vrising/persistentdata/Settings/ServerHostSettings.json`

**Priority of Settings:**
1. Dynamic Environment Variables (`GAME_SETTINGS_*`)
2. Local files in `/persistentdata`
3. Default files in `/server` (reset on every Steam update)

## 📁 Understanding Your Data

When you run the Docker container, it creates folders on your host machine to store game files and your personal data.

```text
Your Host Machine (Local)             Docker Container (Internal)
┌─────────────────────────┐          ┌─────────────────────────┐
│ ./server/               │ ───────▶ │ /mnt/vrising/server/    │ (Game Binaries - Automated)
├─────────────────────────┤          ├─────────────────────────┤
│ ./persistentdata/       │ ───────▶ │ /mnt/.../persistentdata/│ (YOUR DATA - BACK THIS UP!)
│  ├── Settings/          │          │                         │
│  │   ├── adminlist.txt  │          │                         │
│  │   └── *.json         │          │                         │
│  └── Saves/             │          │                         │
│      └── v3/world1/     │          │                         │
└─────────────────────────┘          └─────────────────────────┘
```

**Note:** Never modify files in the `./server` folder manually. All configuration and saves live in `./persistentdata`.

## 👑 Admins & Bans

To manage players on your server, you use the `adminlist.txt` and `banlist.txt` files located in your host's `./persistentdata/Settings/` directory.

### Adding Admins
1. Navigate to `./persistentdata/Settings/` on your host.
2. Create or edit `adminlist.txt`.
3. Add the **Steam64 IDs** (one per line). Use a tool like [steamid.io](https://steamid.io) to find them.
4. Restart the container.
5. In-game, open the console (`~`) and type `adminauth`.

### Banning Players
1. Navigate to `./persistentdata/Settings/` on your host.
2. Create or edit `banlist.txt`.
3. Add the **Steam64 IDs** of the players you wish to ban.
4. Restart the container.

## 🩺 Container Healthcheck

The V Rising dedicated server under Wine can take several minutes to generate a new world or load a large save file. To reliably determine when the server is fully ready to accept connections, the Docker image includes a native `HEALTHCHECK`.

The healthcheck performs a UDP ping against the server's Query Port (`QUERYPORT`). 

By default, the healthcheck is configured with a generous `start_period` of 120 seconds to account for the initial load time without prematurely marking the container as unhealthy. This is particularly useful for orchestrating other containers (like an RCON sidecar) that should only start once the server is fully initialized.

## 📡 RCON (Remote Console)

RCON allows you to send commands to your server without being in-game.

### Enabling RCON (Recommended Method)
Add these environment variables to your `docker-compose.yml`:

```yaml
environment:
  - HOST_SETTINGS_Rcon__Enabled=true
  - HOST_SETTINGS_Rcon__Password=SuperSecretPassword
  - HOST_SETTINGS_Rcon__Port=25575
ports:
  - '25575:25575/tcp' # Ensure you expose the TCP port!
```

### Executing Commands (Standalone)
You don't need to install anything on your host. Use a temporary Docker container to run the [gorcon/rcon-cli](https://github.com/gorcon/rcon-cli):

```bash
docker run --rm gorcon/rcon-cli -a 127.0.0.1:25575 -p SuperSecretPassword "announce 'Server is restarting in 5 minutes!'"
```

### Running an RCON Sidecar (Docker Compose)
If you prefer to have an RCON client running continuously alongside your server, you can configure an RCON sidecar in your `docker-compose.yml`. This sidecar will automatically wait for the V Rising server to become `healthy` before starting.

```yaml
services:
  vrising:
    image: dmirtillo/vrising-dedicated
    environment:
      - SERVERNAME=My RCON Server
      - HOST_SETTINGS_Rcon__Enabled=true
      - HOST_SETTINGS_Rcon__Password=SuperSecretPassword
    ports:
      - '9876:9876/udp'
      - '9877:9877/udp'
      - '25575:25575/tcp'
    healthcheck:
      test: ["CMD-SHELL", "nc -z -u 127.0.0.1 $${QUERYPORT:-9877} || exit 1"]
      interval: 30s
      timeout: 10s
      start_period: 120s
      retries: 3

  rcon:
    image: itzg/rcon-cli:latest
    environment:
      - RCON_HOST=vrising
      - RCON_PORT=25575
      - RCON_PASSWORD=SuperSecretPassword
    depends_on:
      vrising:
        condition: service_healthy
```
You can then easily execute commands through the sidecar container:
```bash
docker compose exec rcon rcon-cli "announce 'Hello World!'"
```

### Useful Commands
| Command | Description |
| :--- | :--- |
| `announce <message>` | Send a global message to all players. |
| `kick <character name>` | Kick a player from the server. |
| `banuser <character name>` | Ban a player from the server. |
| `unban <steam id>` | Unban a player. |
| `save` | Force an immediate world save. |
