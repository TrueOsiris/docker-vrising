#!/bin/bash
dir=/mnt/vrising/persistentdata/backup

mkdir "$dir" 2>/dev/null

## Remove backups older then 1 day
find $dir -mtime +1 -type f -exec rm -fv {} \;

## Start backup process
if [ ! -f "$dir/backup" ]; then
    fileName="$(date +"%Y%m%d-%H%M%S")-${1:-"backup"}.tar.gz"
    tar -cvpzf $dir/$fileName /mnt/vrising/persistentdata/Saves
fi