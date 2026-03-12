# 🧛 V Rising Dedicated Server (Docker)

[![Docker Pulls](https://img.shields.io/docker/pulls/dmirtillo/vrising-dedicated?logo=docker&label=pulls)](https://hub.docker.com/r/dmirtillo/vrising-dedicated)
[![Docker Stars](https://img.shields.io/docker/stars/dmirtillo/vrising-dedicated?logo=docker&label=stars)](https://hub.docker.com/r/dmirtillo/vrising-dedicated)
[![GitHub Stars](https://img.shields.io/github/stars/dmirtillo/docker-vrising?logo=github&label=stars)](https://github.com/dmirtillo/docker-vrising)
[![Ubuntu 24.04](https://img.shields.io/badge/Ubuntu-24.04-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com)
[![Wine 11.0](https://img.shields.io/badge/Wine-11.0-800000?logo=wine&logoColor=white)](https://winehq.org)

A high-performance, easy-to-use Dockerized V Rising dedicated server running on **Ubuntu 24.04** with **Wine 11.0**. Designed for stability, ease of configuration, and automated maintenance.

---

## 🚀 Quick Start (Docker Compose)

The recommended way to run the server is using [Docker Compose](https://docs.docker.com/compose/). Create a `docker-compose.yml` file and paste the following:

```yaml
services:
  vrising:
    image: dmirtillo/vrising-dedicated
    container_name: vrising-server
    environment:
      - TZ=Europe/Rome
      - SERVERNAME=vrising-dedicated
      - WORLDNAME=world1
    volumes:
      - ./server:/mnt/vrising/server            # Game binaries (automated update)
      - ./persistentdata:/mnt/vrising/persistentdata # YOUR SAVES & SETTINGS
    ports:
      - '9876:9876/udp' # Game Port
      - '9877:9877/udp' # Query Port
    healthcheck:
      test: ["CMD-SHELL", "nc -z -u 127.0.0.1 $${QUERYPORT:-9877} || exit 1"]
      interval: 30s
      timeout: 10s
      start_period: 120s
      retries: 3
    restart: unless-stopped
```

Then run:
```bash
docker compose up -d
```

---

## ✨ Features

*   **Automated Updates:** Built-in SteamCMD integration ensures your server is always up-to-date on every restart.
*   **Dynamic JSON Patching:** Modify `ServerGameSettings.json` and `ServerHostSettings.json` directly via environment variables (no manual JSON editing required!).
*   **Native Healthcheck:** Reliable readiness reporting via UDP query port pinging.
*   **Optimized Stack:** Built on Ubuntu 24.04 with the latest stable Wine 11.0 for maximum performance.
*   **Slim Image:** Automated pruning of build-time dependencies to keep the image footprint small.

---

## ⚙️ Configuration

### Core Environment Variables
| Variable | Default | Description |
| :--- | :--- | :--- |
| `SERVERNAME` | `vrising-dedicated` | Your server's name in the server list. |
| `WORLDNAME` | `world1` | The name of your world save file. |
| `TZ` | `Europe/Rome` | Timezone for logs and scheduling. |
| `PUID` / `PGID` | `1000` | User/Group ID for file permissions. |

### Dynamic JSON Configuration (Advanced)
Patch any setting in the internal JSON files using these prefixes:
*   `GAME_SETTINGS_` for `ServerGameSettings.json`
*   `HOST_SETTINGS_` for `ServerHostSettings.json`

**Example:**
```yaml
environment:
  - HOST_SETTINGS_ListOnSteam=true
  - HOST_SETTINGS_Rcon__Enabled=true
  - HOST_SETTINGS_Rcon__Password=MySecretPassword
  - GAME_SETTINGS_GameModeType=PvE
  - GAME_SETTINGS_UnitStatModifiers_Global__MaxHealthModifier=2
```

---

## 📡 RCON & Sidecars

This image supports a persistent RCON sidecar pattern. You can run an RCON client that waits for the server to be `healthy` before starting:

```yaml
services:
  vrising:
    # ... (see Quick Start)
    environment:
      - HOST_SETTINGS_Rcon__Enabled=true
      - HOST_SETTINGS_Rcon__Password=SuperSecretPassword

  rcon:
    image: outdead/rcon-cli:latest
    environment:
      - RCON_HOST=vrising
      - RCON_PORT=25575
      - RCON_PASSWORD=SuperSecretPassword
    depends_on:
      vrising:
        condition: service_healthy
```

---

## 📖 Full Documentation

For detailed guides on networking, data management, and troubleshooting, visit the official repository:

🔗 **[GitHub Repository: dmirtillo/docker-vrising](https://github.com/dmirtillo/docker-vrising)**

*   [🚀 Installation Guide](https://github.com/dmirtillo/docker-vrising/blob/main/docs/installation.md)
*   [⚙️ Detailed Configuration](https://github.com/dmirtillo/docker-vrising/blob/main/docs/configuration.md)
*   [💾 Data & Saves](https://github.com/dmirtillo/docker-vrising/blob/main/docs/data-management.md)
*   [🌐 Networking & Ports](https://github.com/dmirtillo/docker-vrising/blob/main/docs/networking.md)

---

## ❤️ Credits & Thanks
*   **[TrueOsiris](https://github.com/TrueOsiris)**: A special thank you to the original creator of this project for their incredible foundational work and contributions to the V Rising Docker community.
*   **Stunlock Studios**: For creating such a fantastic game!
*   **Community Contributors**: For the ongoing bug reports, fixes, and feature suggestions.
