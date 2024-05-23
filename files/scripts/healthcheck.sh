#!/bin/bash
set -eu

ps -q "$(cat /home/steam/server.pid)" -o state --no-headers | grep -q -v "D|R|S"