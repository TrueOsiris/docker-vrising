<p align="center">
  <a href="https://github.com/TrueOsiris/docker-vrising">
    <img alt="Iroh" src="https://github.com/TrueOsiris/docker-vrising/blob/main/assets/docker-virising.png?raw=true" height="250">
  </a>
  <p  align="center">Dockerized V Rising dedicated server in an Debian 12 container with Wine.</p>
</p>

[![Docker Pulls](https://badgen.net/docker/pulls/trueosiris/vrising?icon=docker&label=pulls)](https://hub.docker.com/r/trueosiris/vrising/)
[![Docker Stars](https://badgen.net/docker/stars/trueosiris/vrising?icon=docker&label=stars)](https://hub.docker.com/r/trueosiris/vrising/)
[![Docker Image Size](https://badgen.net/docker/size/trueosiris/vrising?icon=docker&label=image%20size)](https://hub.docker.com/r/trueosiris/vrising/)
![Github stars](https://badgen.net/github/stars/trueosiris/docker-vrising?icon=github&label=stars)
![Github forks](https://badgen.net/github/forks/trueosiris/docker-vrising?icon=github&label=forks)
![Github open issues](https://badgen.net/github/open-issues/TrueOsiris/docker-vrising)
![Github closed issues](https://badgen.net/github/closed-issues/TrueOsiris/docker-vrising)
![Github last-commit](https://img.shields.io/github/last-commit/TrueOsiris/docker-vrising)

## Updates

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
- Make sure `HOST_SETTINGS_LISTEN_ON_STEAM: "true"` and `HOST_SETTINGS_LISTEN_ON_EOS: "true"` are set in your Environment
- Launching the server can take up to 10 minutes, even on a fast system, certainly with an existing save. Below is a screenshot of the end of the docker log of a functioning server, at the time we are able to connect to it.

## Environment variables


| Variable                          | Default V(alue)                     | Description                                                                         | Mandatory |
| --------------------------------- | ----------------------------------- | ----------------------------------------------------------------------------------- | --------- |
| TZ                                | Europe/Brussels                     | timezone for ntpdate                                                                | No |
| SERVER_DATA_PATH                  | /home/steam/vrising/server          | Path inside the container to save server files to                                   | No |
| PERSISTENT_DATA_PATH              | /home/steam/vrising/persistentdata  | Path inside the container to save world/configs/logs/etc. to                        | No |
| HOST_SETTINGS_NAME                | My Docker V-Rising Server           | The name of your server as visible in the server list                               | No |
| HOST_SETTINGS_DESCRIPTION         | V Rising Server hosted by Docker    | Description of your server                                                          | No |
| HOST_SETTINGS_PASSWORD            | ""                                  | Optional Server password                                                            | No |
| HOST_SETTINGS_MAX_CONNECTED_USERS | 10                                  | Maximum connected users                                                             | No |
| HOST_SETTINGS_MAX_CONNECTED_ADMINS| 4                                   | Maximum connected admins                                                            | No |
| HOST_SETTINGS_SERVER_ADMIN_LIST   | ""                                  | Comma separated list of Admin Steam IDs (e.g. "123456789,0987654321")               | No |
| HOST_SETTINGS_SERVER_FPS          | 30                                  | Server FPS                                                                          | No |
| HOST_SETTINGS_RCON_ENABLE         | "false"                             | Whether to enable RCON                                                              | No |
| HOST_SETTINGS_RCON_PASSWORD       | "Ch8ng3m3Pl3@s3!"                   | RCON Password [Requires: HOST_SETTINGS_RCON_ENABLE=true]                            | No |
| HOST_SETTINGS_RCON_PORT           | "9876"                              | RCON TCP Port to listen on                                                          | No |
| HOST_SETTINGS_AUTOSAVE_COUNT      | 40                                  | How many autosaves to keep                                                          | No |
| HOST_SETTINGS_AUTOSAVE_INTERVAL   | 120                                 | Interval in seconds for the server to autosave                                      | No |
| HOST_SETTINGS_LISTEN_ON_STEAM     | "true"                              | Whether to listen on steam                                                          | No |
| HOST_SETTINGS_LISTEN_ON_EOS       | "true"                              | Whether to listen on EOS                                                            | No |
| GAME_SETTINGS_PRESET              | "StandardPvP"                       | Game Settings Preset to start the server with                                       | No |
| GAME_SETTINGS_DIFFICULTY          | "Normal"                            | Server default difficulty setting                                                   | No |
| LIST_ON_MASTER_SERVER             | "true"                              | Whether to list the Server on Master Servers                                        | No |
| SERVER_IP                         | "127.0.0.1"                         | Public facing Server IP - **You might have to experiment with this**                | Maybe |
| SAVE_NAME                         | "default_world"                     | The name of your map                                                                | No |
| GAME_PORT                         | "9876"                              | UDP Port for Game connections                                                       | No |
| QUERY_PORT                        | "9877"                              | UDP Port to query the server on                                                     | No |
| DEBUG_ENV                         | "true"                              | Return all variables to the stdout on container start                               | No |
| LOGDAYS                           | 30                                  | Numer of days after which logs are deleted after their last modification            | No |
| OVERRIDE_CONFIG                   | true                                | Whether to generate new configs at the start of the container.                      | No |

## Ports


| Exposed Container port | Type | Default |
| ------------------------ | ------ | --------- |
| 9876                   | UDP  | ✔️    |
| 9876                   | TCP  | ❌    |
| 9877                   | UDP  | ✔️    |

## Volumes


| Volume             | Container path              | Description                             |
| -------------------- | ----------------------------- | ----------------------------------------- |
| steam install path | /home/steam/vrising/server      | path to hold the dedicated server files |
| world              | /home/steam/vrising/persistentdata  | path that holds the world files         |

## Docker cli

```bash
docker run -d --name='vrising' \
--net='bridge' \
--restart=unless-stopped \
-e TZ="Europe/Paris" \
-e HOST_SETTINGS_NAME="trueosiris-V" \
-v '/path/on/host/server':'/home/steam/vrising/server':'rw' \
-v '/path/on/host/persistentdata':'/home/steam/vrising/persistentdata':'rw' \
-p 9876:9876/udp \
-p 9877:9877/udp \
'trueosiris/vrising'
```

## docker-compose.yml

See the example docker-compose.yml in this repository.
Do not put any of your env variables in the "environment:" section in quotes.

**IMPORTANT**: The compose file will create the path you define in `source` if it does not exist. Ensure you're either running with UID/GID 1000 (the steam user in the container) or change owners of these folders accordingly. Otherwise you will get the following error:

```
mkdir: cannot create directory '/home/steam/vrising/persistentdata/Settings': Permission denied
```

## Kubernetes

You can use the provided example in `kubernetes/kustomize/overlays/exampleorg` to see the ways the base template could be adjusted to your requirements.
It's important to *at least* change the following:
- secret.yaml - Your RCON Secret, if you need one
- pvc.yaml - Adjust `storageClassname` and requsted storage according to your needs
- deployment.yaml - Set Image path to your registry. This image is not pushed to dockerhub by default

To update your Pod, just delete it and wait for it to restart.

## Links

- [V Rising Dedicated Server Instructions](https://github.com/StunlockStudios/vrising-dedicated-server-instructions)
- [Dockerhub - Trueosiris/vrising](https://hub.docker.com/repository/docker/trueosiris/vrising)
- [Github - trueosiris/vrising](https://github.com/TrueOsiris/docker-vrising)

## RCON <small>- Optional</small>

To enable RCON set the `HOST_SETTINGS_RCON_ENABLE`, `HOST_SETTINGS_RCON_PASSWORD`, `HOST_SETTINGS_RCON_PORT` variables. To communicate using RCON protocal use the [RCON CLI](https://github.com/gorcon/rcon-cli) by gorcon.


## Remarks

-   Server config files are in `/path/on/host/persistentdata/Settings`. 
    Files in `/path/on/host/server/` are overwritten on Steam update. <br>
    Priority of settings is

    - container variables
    - files in /server. (and these are reset to defaults each new patch)

    Please note that you cannot edit your config files in `$PERSISTENT_DATA_PATH/Settings/ServerGameSettings.json` or `$PERSISTENT_DATA_PATH/Settings/ServerHostSettings.json`, these will be overwritten by your ENV every time the container is restarted by default. In case you want to adjust any setting that isn't covered by the current config options, please create an issue or a PR.
    If you want to manually adjust your configs and keep your changes, move your config files (with proper access rights) to your mounted folder and set `OVERRIDE_CONFIG="false"`
- If you use different internal & external ports, you can only use direct connect. For example `-p 12345:6789/udp` container port 6789 as defined in ServerHostSettings.json, and exposed as 12345 will make your server invisible ~~, even if  `"ListOnMasterServer=true"`~~
- If you want to see the server in the server list and want to use 27015-27016/UDP, you'll need to change the ports to 27015 and 27016. Then expose these ports (below). Of course, forward these udp ports on your firewall from incoming wan to the ports on the internal ip of your dockerhost.

  - Start the container & let the server install.
  - Stop the container.
  - Alter the ports to
    ```
     GAME_PORT: "27015"
     QUERY_PORT: "27016"
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
