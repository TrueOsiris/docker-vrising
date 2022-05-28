<p align="center">
  <a href="https://github.com/TrueOsiris/docker-vrising">
    <img alt="Iroh" src="https://github.com/TrueOsiris/docker-vrising/blob/main/assets/docker-virising.png?raw=true" height="250">
  </a>
  <p  align="center">Dockerized V Rising dedicated server in an Ubuntu 22.04 container with Wine.</p>
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
  <img alt="Github stars" src="https://badgen.net/github/stars/trueosiris/docker-vrising?icon=github&label=stars" />
  <img alt="Github forks" src="https://badgen.net/github/forks/trueosiris/docker-vrising?icon=github&label=forks" />
  <a href="https://github.com/TrueOsiris/docker-vrising/issues/">
    <img alt="Github issues" src="https://img.shields.io/github/issues/TrueOsiris/docker-vrising" />
  </a>
  <img alt="Github last-commit" src="https://img.shields.io/github/last-commit/TrueOsiris/docker-vrising" />
</p>

Edit `ServerHostSettings.json` if you want to change the ports, descriptions etc.<br>
Server config files are in `/path/on/host/dedicatedserverfiles/VRisingServer_Data/StreamingAssets/Settings`.

## Environment variables

| Variable | Type | Default | Description |
| -------------------- | ---------------------------- |  ---------------------------- | ------------------------------------------------------------------------------- |
| TZ | `string` |   | Timezone for ntpdate `Europe/Paris` |
| SERVERNAME | `string` | trueosiris-V | Mandatory setting that overrules the ServerHostSettings.json entry |
| WORLDNAME | `string` | world1 | Optional: No real need to alter this. saves will be in a subdir WORLDNAME |
| AUTO_BACKUP | `boolean` | 0 | Enables auto backup task, backups older then 1 day will be removed |
| AUTO_BACKUP_SCHEDULE | `*/15 * * * *` | 30min | Set interval for each save |

## Ports

| Exposed Container port | Type | Default |
| ---------------------- | ---- | ------- |
| 9876 | UDP | ✔️ |
| 9877 | UDP | ✔️ |

## Volumes

| Volume                    | Container path                                                   | Description |
| ------------------------- | ---------------------------------------------------------------- | ----------------------------------------------- |
| steam install path    | /mnt/vrising/server | path to hold the dedicated server files |
| world | /mnt/vrising/persistentdata | path that holds the world files |


## Docker cli
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
      - AUTO_BACKUP=1
    volumes:
      - './server:/mnt/vrising/server:rw'
      - './data:/mnt/vrising/persistentdata:rw'
    ports:
      - '9876:9876/udp'
      - '9877:9877/udp'
```

## Links

- [V Rising Dedicated Server Instructions](https://github.com/StunlockStudios/vrising-dedicated-server-instructions)
- [Dockerhub - Trueosiris/vrising](https://hub.docker.com/repository/docker/trueosiris/vrising)
- [Github - trueosiris/vrising](https://github.com/TrueOsiris/docker-vrising)

## RCON <small>- Optional</small>
To enable RCON edit `ServerHostSettings.json` and paste following lines after `QueryPort`. To communicate using RCON protocal use the [RCON CLI](https://github.com/gorcon/rcon-cli) by gorcon.

```json
"Rcon": {
  "Enabled": true,
  "Password": "docker",
  "Port": 25575
},
```

## Contributors
<a href="https://github.com/TrueOsiris/docker-vrising/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=TrueOsiris/docker-vrising" />
</a>

## Remarks 
### as requested or logged in issues

- Configuration settings are still those in /path/on/host/dedicatedserverfiles/VRisingServer_Data/StreamingAssets/Settings
so NOT those in /persistentdata.


- If you use different internal & external ports, you can only use direct connect. For example `-p 12345:6789/udp` container port 6789 as defined in ServerHostSettings.json, and exposed as 12345 will make your server invisible, even if  `"ListOnMasterServer=true"`


- If you want to see the server in the server list and want to use 27015-27016/UDP, you'll need to change the ports in the ServerHostSettings.json file to 27015 and 27016. Then expose these ports (below). Of course, forward these udp ports on your firewall from incoming wan to the ports on the internal ip of your dockerhost.<br>
1. Start the container & let the server install<br>It ends with something like `0024:fixme:ntdll:EtwEventSetInformation (deadbeef, 2, 000014B2D39FA170, 65) stub`
2. Stop the container.<br>
3. Alter the ports in `/path/on/host/dedicatedserverfiles/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json` to<br>
```
 "Port": 27015,
 "QueryPort": 27016,
``` 
4. On your firewall, port forward incoming wan udp ports 27015 and 27016 to the same udp ports on your dockerhost ip.<br>
5. Restart the container with these ports:
```
-p 27015:27015/udp
-p 27016:27016/udp
```


- If you want to continue from your local game, stop the container, overwrite the persistentdata
contents with your local data, and relaunch the server.
