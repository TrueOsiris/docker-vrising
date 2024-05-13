#!/bin/bash

if [ ! -d "$LOGSDIR" ]; then mkdir "$LOGSDIR"; fi

# Rename latest.log to VRising-{LastModifiedDate}.log
# if the file exists and its not empty
ContainerLog="$LOGSDIR/latest.log"
if [ -f "$ContainerLog" ] && [ -s "$ContainerLog" ]; then
	LogDate=$(date --date="@$(stat -c "%Y" "$ContainerLog")" +'%Y%m%d-%H%M%S')
    mv "$ContainerLog" "$LOGSDIR/VRising-$LogDate.log"
fi

term_handler() {
    # First we get the hexdec value of the Win PID 
    WinHexPID=$(winedbg --command "info proc" | grep -Po '^\s*\K.{8}(?=.*VRisingServer\.exe)')

    # Now we convert the hexdec to decimal 
    # and use it to send an taskkill via CMD
    wine cmd.exe /C "taskkill /pid $(( 0x$WinHexPID ))"

    # Wineserver should exit after the gameserver is shutdown,
    # so we wait for it
    wineserver -w

    exit
    # Yeepii, we gracefully shutdown the gameserver! \'-'/
}

# Trap SIGTERM so we can gracefully shutdown the gameserver
trap 'term_handler' SIGTERM

# Not using pipes so we can capture bash PID later
/bin/bash "$SCRIPTSDIR/start.sh" > >(tee "$ContainerLog") 2>&1 &

# PID of bash
killpid=$!
wait "$killpid"
