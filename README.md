<p align="center">
  <a href="https://github.com/TrueOsiris/docker-vrising">
    <img alt="V Rising Docker" src="https://github.com/TrueOsiris/docker-vrising/blob/main/assets/docker-virising.png?raw=true" height="250">
  </a>
  <p align="center">A high-performance, easy-to-use Dockerized V Rising dedicated server.</p>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker">
  <img src="https://img.shields.io/badge/Ubuntu_24.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white" alt="Ubuntu">
  <img src="https://img.shields.io/badge/Wine_11-800000?style=for-the-badge&logo=wine&logoColor=white" alt="Wine">
</p>

<p align="center">
  <img src="https://img.shields.io/docker/pulls/trueosiris/vrising?logo=docker&label=pulls" alt="Pulls">
  <img src="https://img.shields.io/docker/stars/trueosiris/vrising?logo=docker&label=stars" alt="Stars">
  <img src="https://img.shields.io/github/stars/TrueOsiris/docker-vrising?logo=github&label=stars" alt="GitHub Stars">
  <img src="https://img.shields.io/github/last-commit/TrueOsiris/docker-vrising?logo=github&label=last%20commit" alt="Last Commit">
</p>

---

## Documentation Index

Explore our guides to get your server up and running quickly and securely.

- 🚀 **[Quick Start & Installation](docs/installation.md)** — Get your server running in minutes using Docker Compose or CLI.
- ⚙️ **[Server Configuration](docs/configuration.md)** — Detailed guide on basic environment variables and advanced dynamic JSON patching.
- 🌐 **[Networking & Ports](docs/networking.md)** — Port forwarding, server list visibility, and custom port configuration.
- 💾 **[Data & Save Management](docs/data-management.md)** — How volumes work, performing backups, and migrating local saves to your server.
- 🔧 **[Troubleshooting](docs/troubleshooting.md)** — Solutions for common errors, Windows host issues, and log explanations.
- 🛠️ **[Development & Contributing](docs/development.md)** — CI/CD pipeline, automated pruning secrets, and the OpenSpec workflow.
- 📜 **[Changelog](CHANGELOG.md)** — Keep track of the latest updates and bug fixes.

---

## Quick Features

- **Automated Updates**: SteamCMD integration ensures your server is always running the latest version.
- **Dynamic Configuration**: Modify game and host settings directly from your `docker-compose.yml` without touching JSON files.
- **Slim & Fast**: Optimized Ubuntu 24.04 base with Wine 11.0 for maximum compatibility and performance.
- **Verified Stability**: Includes automated E2E testing to ensure the image always boots successfully.

---

## Credits & Links

- [Official V Rising Website](https://playvrising.com/)
- [V Rising Dedicated Server Instructions (Stunlock Studios)](https://github.com/StunlockStudios/vrising-dedicated-server-instructions)
- [Docker Hub Page](https://hub.docker.com/r/trueosiris/vrising)

*Special thanks to the Stunlock Studios team for creating such an amazing game!*
