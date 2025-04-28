<p align="center">
  <a href="https://github.com/TrueOsiris/docker-vrising">
    <img alt="Iroh" src="https://github.com/TrueOsiris/docker-vrising/blob/main/assets/docker-virising.png?raw=true" height="250">
  </a>
  <p  align="center">Dockerized V Rising dedicated server in an Ubuntu 22.04 container with Wine.</p>
</p>

[![Docker Pulls](https://badgen.net/docker/pulls/trueosiris/vrising?icon=docker&label=pulls)](https://hub.docker.com/r/trueosiris/vrising/)
[![Docker Stars](https://badgen.net/docker/stars/trueosiris/vrising?icon=docker&label=stars)](https://hub.docker.com/r/trueosiris/vrising/)
[![Docker Image Size](https://badgen.net/docker/size/trueosiris/vrising?icon=docker&label=image%20size)](https://hub.docker.com/r/trueosiris/vrising/)
![Github stars](https://badgen.net/github/stars/trueosiris/docker-vrising?icon=github&label=stars&cache=600)
![Github forks](https://badgen.net/github/forks/trueosiris/docker-vrising?icon=github&label=fork&cache=600s)
![Github open issues](https://badgen.net/github/open-issues/TrueOsiris/docker-vrising?cache=600)
![Github closed issues](https://badgen.net/github/closed-issues/TrueOsiris/docker-vrising?cache=600)
![Github last-commit](https://img.shields.io/github/last-commit/TrueOsiris/docker-vrising?cache=600)

## Updates

### 1.1 and latest image

- Just tested the latest image for V-Rising 1.1 & all works fine. 
- Log will be spammed with these messages. Feel free to give me a solution here.<br>
  01b4:fixme:winsock:server_ioctl_sock Unsupported ioctl 4004747b (device=4004 access=1 func=d1e method=3)<br>
  vrising-1  | 01b4:fixme:winsock:WSAIoctl unsupported WS_IOCTL cmd (SIO_IDEAL_SEND_BACKLOG_QUERY)
- There is no way to continue a game from 1.0. I just checked with the discord community.

### image 2024-05-16 ([trueosiris/vrising:2.1](https://hub.docker.com/layers/trueosiris/vrising/2.1/images/sha256-00639c82158711d868f41750aa43f605bd35f5b775725137ef3b0b10ba80b52e?context=repo) or [latest](https://hub.docker.com/layers/trueosiris/vrising/latest/images/sha256-00639c82158711d868f41750aa43f605bd35f5b775725137ef3b0b10ba80b52e?context=repo)) 

- Merged with [pull65](https://github.com/TrueOsiris/docker-vrising/pull/65) from [Killerherts](https://github.com/killerherts).<br>
  Logs older than 30 days are cleaned up on server start.
- Merged with [pull52](https://github.com/TrueOsiris/docker-vrising/pull/52) from [Diyagi](https://github.com/diyagi).<br>
  Previous container version can still be grabbed via [trueosiris/vrising:2.0](https://hub.docker.com/layers/trueosiris/vrising/2.0/images/sha256-b9142d6f653685c92e25745f48cd205a1ffc7ed4aedef19011b03ab2a03a33c6?context=repo)<br>
  Main fixes are: clean shutdown & complete log to container log. Kudos!
- Added date to the logfile name, so per server launch, a logfile will be created. For now, they will not be automatically cleaned up.
- If you're experiencing [this issue](https://github.com/TrueOsiris/docker-vrising/issues/51) with "[476:488:20240511,134828.926:ERROR http_transport_win.cc:388] HTTP status 403" in the log, pull [trueosiris/vrising:display](https://hub.docker.com/layers/trueosiris/vrising/display/images/sha256-592b9ace78b7228c08134804fa94b0f47766bb9202d86048a0a4ded81f765cda?context=repo) which uses xvfb.
- If you're experiencing [this issue](https://github.com/TrueOsiris/docker-vrising/issues/43) with "wine: Assertion failed at address 00007F79E2C9EA7C (thread 0094)" in the log, u might need the latest wine from winehq, therefore grab [trueosiris/vrising:winehq](https://hub.docker.com/layers/trueosiris/vrising/winehq/images/sha256-f7f662258b30d6250d16718aa008a95b868336c92fdd98e56fd39bbca5626f8c?context=repo)

### V-Rising 1.0 update

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
| LOGDAYS | optional lifetime of logfiles | overrule default of 30 days |

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
- Description can be changed in `/path/on/host/persistentdata/Settings/ServerHostSettings.json`. The server will have to be restarted after changes.
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

## Credits

- All credits go to the awesome designers of [V-Rising](https://playvrising.com/)!
