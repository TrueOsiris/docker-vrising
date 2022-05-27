<p align="center">
  <a href="https://github.com/TrueOsiris/docker-vrising">
    <img alt="Iroh" src="assets/docker-virising.png?raw=true" height="250">
  </a>
  <p  align="center">A dockersized V Rising dedicated server on Ubuntu 22.04 with Wine.</p>
</p>

<p align="center">
  <img alt="Trueosiris Rules" src="https://img.shields.io/badge/trueosiris-rules-f08060" />
  <a href="https://hub.docker.com/r/trueosiris/vrising/">
    <img alt="Docker Pulls" src="https://badgen.net/docker/pulls/trueosiris/vrising?icon=docker&label=pulls" />
  </a>
  <a href="https://hub.docker.com/r/trueosiris/vrising/">
    <img alt="Docker stars" src="https://badgen.net/docker/stars/trueosiris/vrising?icon=docker&label=stars" />
  </a>
  <a href="https://hub.docker.com/r/trueosiris/vrising/">
    <img alt="Docker stars" src="https://badgen.net/docker/size/trueosiris/vrising?icon=docker&label=image%20size" />
  </a>
  <a href="https://hub.docker.com/r/trueosiris/vrising/">
    <img alt="Docker stars" src="https://badgen.net/docker/size/trueosiris/vrising?icon=docker&label=image%20size" />
  </a>
  <br>
  <img alt="Github forks" src="https://badgen.net/github/stars/trueosiris/docker-vrising?icon=github&label=stars" />
  <img alt="Github forks" src="https://badgen.net/github/forks/trueosiris/docker-vrising?icon=github&label=forks" />
  <a href="https://github.com/TrueOsiris/docker-vrising/issues/">
    <img alt="Github issues" src="https://img.shields.io/github/issues/TrueOsiris/docker-vrising" />
  </a>
  <img alt="Github last-commit" src="https://img.shields.io/github/last-commit/TrueOsiris/docker-vrising" />
</p>

## Environment variables

| Variable | Key | Description |
| -------------------- | ---------------------------- | ------------------------------------------------------------------------------- |
| TZ | Europe/Brussels | timezone for ntpdate |
| SERVERNAME | published servername | mandatory setting that overrules the ServerHostSettings.json entry |
| WORLDNAME | optional worldname | default = world1. No real need to alter this. saves will be in a subdir WORLDNAME |
| AUTO_BACKUP | 1 | enables auto backup crontask. default = `0` (false) |
| AUTO_BACKUP_SCHEDULE | `*/15 * * * *` | default = `"*/30 * * * *"` 30min interval |

## Ports
Edit `ServerHostSettings.json` if you wan't to change the ports,name,descriptions etc. If you change the ports make sure you do the same for the docker container.

| Exposed Container port | Type | Default |  Comment | 
| ---------------------- | ---- | ------- | -------- |
| 9876 | UDP | ✔️ | Replacing with **27015** the server will show up on server list ingame |
| 9877 | UDP | ✔️ | Replacing with **27016** the server will show up on server list ingame |

## RCON <small>- Optional</small>
To enable RCON edit `ServerHostSettings.json` and paste following lines after `QueryPort`. To communitate using RCON protocal use a [RCON CLI](https://github.com/gorcon/rcon-cli) by gorcon.

```json
"Rcon": {
  "Enabled": true,
  "Password": "docker",
  "Port": 25575
},
```

## Volumes

If you want to continue from your local game, stop the container, overwrite the persistentdata
contents, and relaunch the server. 

| Volume                    | Container path                                                   | Description |
| ------------------------- | ---------------------------------------------------------------- | ----------------------------------------------- |
| steam install path    | /mnt/vrising/server | path to hold the dedicated server files |
| world | /mnt/vrising/persistentdata | path that holds the world files |


## Docker cli
You can find your server config files in `/path/on/host/dedicatedserverfiles/VRisingServer_Data/StreamingAssets/Settings`
```terminal
docker run -d --name='vrising' \
--net='bridge' \
-e TZ="Europe/Paris" \
-e SERVERNAME="trueosiris-V" \
-v '/path/on/host/dedicatedserverfiles':'/mnt/vrising/server':'rw' \
-v '/path/on/host/persistentdata':'/mnt/vrising/persistentdata':'rw' \
-p 9876:9876/udp \
-p 9877:9877/udp \
'trueosiris/vrising'
```

## docker-compose.yml

You can find your server config files in `server/VRisingServer_Data/StreamingAssets/Settings`

```
version: '3.3'
services:
  vrising:
    container_name: vrising
    image: trueosiris/vrising
    network_mode: bridge
    environment:
      - TZ=Europe/Paris
      - SERVERNAME=vrisingDocker
    volumes:
      - './server:/mnt/vrising/server:rw'
      - './data:/mnt/vrising/persistentdata:rw'
    ports:
      - '9876/udp:9876/udp'
      - '9877/udp:9877/udp'
```

## Good links

- [V Rising Dedicated Server Instructions](https://github.com/StunlockStudios/vrising-dedicated-server-instructions)
- [Dockerhub - Trueosiris/vrising](https://hub.docker.com/repository/docker/trueosiris/vrising)

# Contributors
<a href="https://github.com/TrueOsiris/docker-vrising/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=TrueOsiris/docker-vrising" />
</a>