#!/bin/bash
/home/steam/steamcmd/steamcmd.sh +force_install_dir /mnt/vrising +login anonymous +app_update 1829350 +quit
/usr/bin/tail -f /var/log/dpkg.log

