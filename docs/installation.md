# Installation

This guide covers how to set up and run the V Rising dedicated server using Docker.

## Quick Start (Docker Compose)

The recommended way to run the server is using [Docker Compose](https://docs.docker.com/compose/).

```yaml
services:
  vrising:
    image: dmirtillo/vrising-dedicated
    environment:
      - TZ=Europe/Rome
      - SERVERNAME=vrising-dedicated
    volumes:
      - ./server:/mnt/vrising/server
      - ./persistentdata:/mnt/vrising/persistentdata
    ports:
      - '9876:9876/udp'
      - '9877:9877/udp'
    healthcheck:
      test: ["CMD-SHELL", "nc -z -u 127.0.0.1 $${QUERYPORT:-9877} || exit 1"]
      interval: 30s
      timeout: 10s
      start_period: 120s
      retries: 3
    restart: unless-stopped
```

### Starting the server
```bash
docker-compose up -d
```

## 🎮 Configuration Sets (Recipes)

Not sure what settings to use? Pick the `docker-compose.yml` that best fits how you want to play. These examples use the default V Rising ports (27015/27016) which are common in community guides.

### Option A: Standard PvE (Co-op with Friends)
Perfect for a private server where you work together to build a castle and defeat bosses.

```yaml
services:
  vrising:
    image: dmirtillo/vrising-dedicated
    environment:
      - SERVERNAME="My Cozy Vampire Castle"
      - WORLDNAME="world1"
      # Secure the server so only friends can join
      - HOST_SETTINGS_Password=secretblood
      # Set to PvE (Player vs Environment)
      - GAME_SETTINGS_GameModeType=PvE
      # Quality of Life: Allow teleporting with resources
      - GAME_SETTINGS_TeleportBoundItems=false
    volumes:
      - ./server:/mnt/vrising/server
      - ./persistentdata:/mnt/vrising/persistentdata
    ports:
      - '27015:27015/udp' # Game Port
      - '27016:27016/udp' # Query Port
    healthcheck:
      test: ["CMD-SHELL", "nc -z -u 127.0.0.1 $${QUERYPORT:-27016} || exit 1"]
      interval: 30s
      timeout: 10s
      start_period: 120s
      retries: 3
    restart: unless-stopped
```

### Option B: Standard PvP (Competitive)
A public server focused on clan warfare and raiding.

```yaml
services:
  vrising:
    image: dmirtillo/vrising-dedicated
    environment:
      - SERVERNAME="Blood & Glory [PvP]"
      - WORLDNAME="pvp_world1"
      # Ensure it shows up on the public server list
      - HOST_SETTINGS_ListOnSteam=true
      - HOST_SETTINGS_ListOnEOS=true
      # Use the official Standard PvP preset
      - GAME_SETTINGS_Preset=StandardPvP
    volumes:
      - ./server:/mnt/vrising/server
      - ./persistentdata:/mnt/vrising/persistentdata
    ports:
      - '27015:27015/udp'
      - '27016:27016/udp'
    healthcheck:
      test: ["CMD-SHELL", "nc -z -u 127.0.0.1 $${QUERYPORT:-27016} || exit 1"]
      interval: 30s
      timeout: 10s
      start_period: 120s
      retries: 3
    restart: unless-stopped
```

## Docker CLI

If you prefer using the Docker CLI directly:

```bash
docker run -d --name='vrising' \
  --restart=unless-stopped \
  -e TZ="Europe/Rome" \
  -e SERVERNAME="vrising-dedicated" \
  -v "$(pwd)/server:/mnt/vrising/server" \
  -v "$(pwd)/persistentdata:/mnt/vrising/persistentdata" \
  -p 9876:9876/udp \
  -p 9877:9877/udp \
  dmirtillo/vrising-dedicated
```

## Post-Installation

- Launching the server can take up to 10 minutes, especially on the first run or with an existing save.
- Once the server is running, you can find your configuration files in your host's `persistentdata/Settings` folder.
- For networking and port forwarding details, see [Networking & Ports](networking.md).
