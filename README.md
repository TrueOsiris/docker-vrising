# docker-vrising<br>
Minimal Mono container with a V-Rising dedicated server<br>

![Trueosiris Rules](https://img.shields.io/badge/trueosiris-rules-f08060) 
[![Docker Pulls](https://badgen.net/docker/pulls/trueosiris/vrising?icon=docker&label=pulls)](https://hub.docker.com/r/trueosiris/vrising/) 
[![Docker Stars](https://badgen.net/docker/stars/trueosiris/vrising?icon=docker&label=stars)](https://hub.docker.com/r/trueosiris/vrising/) 
[![Docker Image Size](https://badgen.net/docker/size/trueosiris/vrising?icon=docker&label=image%20size)](https://hub.docker.com/r/trueosiris/vrising/) 
![Github stars](https://badgen.net/github/stars/trueosiris/docker-vrising?icon=github&label=stars) 
![Github forks](https://badgen.net/github/forks/trueosiris/docker-vrising?icon=github&label=forks) 
![Github issues](https://img.shields.io/github/issues/TrueOsiris/docker-vrising)
![Github last-commit](https://img.shields.io/github/last-commit/TrueOsiris/docker-vrising)

### setup

### environment variables

| Environment Variable | Key | Description |
| -------------------- | ---------------------------- | ------------------------------------------------------------------------------- |
| TZ | Europe/Brussels | timezone for ntpdate |

### volumes

| Volume                    | Container path                                                   |
| ------------------------- | ---------------------------------------------------------------- |
| github                    | /mnt/github |

### Run command

    docker run -d --name='git' \
    --net='bridge' \
    -e TZ="Europe/Paris" \
    -v '/path/on/host/':'/mnt/github':'rw' \
    -v '/var/run/docker.sock':'/var/run/docker.sock':'rw' \
    'trueosiris/vrising'

### links

github repo: https://github.com/TrueOsiris/docker-vrising <br>
dockerhub repo: https://hub.docker.com/repository/docker/trueosiris/vrising <br>

