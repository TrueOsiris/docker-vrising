<p align="center">
  <a href="https://github.com/TrueOsiris/docker-vrising">
    <img alt="Iroh" src="https://github.com/TrueOsiris/docker-vrising/blob/main/assets/docker-virising.png?raw=true" height="250">
  </a>
  <p  align="center">Dockerized V Rising dedicated server in an Ubuntu 22.04 container with Wine.</p>
</p>

[![Docker Pulls](https://badgen.net/docker/pulls/trueosiris/vrising?icon=docker&label=pulls)](https://hub.docker.com/r/trueosiris/vrising/)
[![Docker Stars](https://badgen.net/docker/stars/trueosiris/vrising?icon=docker&label=stars)](https://hub.docker.com/r/trueosiris/vrising/)
[![Docker Image Size](https://badgen.net/docker/size/trueosiris/vrising?icon=docker&label=image%20size)](https://hub.docker.com/r/trueosiris/vrising/)
![Github stars](https://badgen.net/github/stars/trueosiris/docker-vrising?icon=github&label=stars)
![Github forks](https://badgen.net/github/forks/trueosiris/docker-vrising?icon=github&label=forks)
![Github open issues](https://badgen.net/github/open-issues/TrueOsiris/docker-vrising)
![Github closed issues](https://badgen.net/github/closed-issues/TrueOsiris/docker-vrising)
![Github last-commit](https://img.shields.io/github/last-commit/TrueOsiris/docker-vrising)

## 1.0 update

- The game is working perfectly with a new run of the container (from scratch). I'm on it with several buddies and <i>tested</i> for 3 hours.
- When the server is passworded, joining via Steam seems <b>not</b> possible. Use the ingame server list to join.
- Make sure `"ListOnSteam": true,` and `"ListOnEOS": true` are set in the ServerHostSettings.json in \persistentdata, so the server is visible in the serverlist
- Launching the server can take up to 10 minutes, even on a fast system, certainly with an existing save. Below is a screenshot of the end of the docker log of a functioning server, at the time we are able to connect to it.

## Environment variables


| Variable   | Key                    | Description                                                                       |
| ------------ | ------------------------ | ----------------------------------------------------------------------------------- |
| TZ         | Europe/Brussels        | timezone for ntpdate                                                              |
| SERVERNAME | published servername   | mandatory setting that overrules the ServerHostSettings.json entry                |
| WORLDNAME  | optional worldname     | default = world1. No real need to alter this. saves will be in a subdir WORLDNAME |
| GAMEPORT   | optional game udp port | to overrule Port in ServerHostSettings.json config                                |
| QUERYPORT  | optional query port    | to overrule QueryPort in ServerHostSettings.json config                           |

## Ports


| Exposed Container port | Type | Default |
| ------------------------ | ------ | --------- |
| 9876                   | UDP  | ✔️    |
| 9877                   | UDP  | ✔️    |

## Volumes


| Volume             | Container path              | Description                             |
| -------------------- | ----------------------------- | ----------------------------------------- |
| steam install path | /mnt/vrising/server         | path to hold the dedicated server files |
| world              | /mnt/vrising/persistentdata | path that holds the world files         |

## Docker cli

```bash
docker run -d --name='vrising' \
--net='bridge' \
--restart=unless-stopped \
-e TZ="Europe/Paris" \
-e SERVERNAME="trueosiris-V" \
-v '/path/on/host/server':'/mnt/vrising/server':'rw' \
-v '/path/on/host/persistentdata':'/mnt/vrising/persistentdata':'rw' \
-p 9876:9876/udp \
-p 9877:9877/udp \
'trueosiris/vrising'
```

## docker-compose.yml

```yaml
services:
  vrising:
    image: trueosiris/vrising
    environment:
      - TZ=Europe/Paris
      - SERVERNAME=vrising-TrueOsiris
    volumes:
      - type: bind
        source: /your/host/vrising/server
        target: /mnt/vrising/server
        bind:
          create_host_path: true
      - type: bind
        source: /your/host/vrising/persistentdata
        target: /mnt/vrising/persistentdata
        bind:
          create_host_path: true
    ports:
      - '9876:9876/udp'
      - '9877:9877/udp'
    restart: unless-stopped
    network_mode: bridge
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

## Remarks

- Server config files are in `/path/on/host/persistentdata/Settings`. Files in `/path/on/host/server/` are overwritten on Steam update. <br>
  Priority of settings is

  a. container variables

  b. files in /persistentdata

  c. files in /server. (and these are reset to defaults each new patch)

  If there are no files in `/path/on/host/persistentdata/Settings` on container start, the default files will be copied there from the /server directory.<br>
  Edit `ServerHostSettings.json` if you want to change the ports, descriptions etc.
- If you use different internal & external ports, you can only use direct connect. For example `-p 12345:6789/udp` container port 6789 as defined in ServerHostSettings.json, and exposed as 12345 will make your server invisible ~~, even if  `"ListOnMasterServer=true"`~~
- Make sure `"ListOnSteam": true,` and `"ListOnEOS": true` are set in the ServerHostSettings.json in \persistentdata, so the server is visible in the serverlist.
- If you want to see the server in the server list and want to use 27015-27016/UDP, you'll need to change the ports in the ServerHostSettings.json file to 27015 and 27016. Then expose these ports (below). Of course, forward these udp ports on your firewall from incoming wan to the ports on the internal ip of your dockerhost.

  - Start the container & let the server install.
  - Stop the container.
  - Alter the ports in `/path/on/host/persistentdata/Settings/ServerHostSettings.json` to
    ```
     "Port": 27015,
     "QueryPort": 27016,
    ```
  - On your firewall, port forward incoming wan udp ports 27015 and 27016 to the same udp ports on your dockerhost ip.
  - Restart the container with these ports:
    ```
     -p 27015:27015/udp
     -p 27016:27016/udp
    ```
- If you want to continue from your local game, stop the container, overwrite the persistentdata
  contents with your local data, and relaunch the server.

## Docker log

The log of a functional server in 1.0 should look like this:

![docker-log](https://timmer.ninja/images/vrising-dockerlog.png)
