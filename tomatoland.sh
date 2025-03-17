#!/usr/bin/env bash

# touch /tmp/tomatoland.log

if [[ "$(uname)" == "Darwin" ]]; then
    # macOS
    RUNTIME_DIR="$HOME/Library/Application Support"
    AUDIO_PLAYER="afplay"
elif grep -q microsoft /proc/version; then
    # WSL
    RUNTIME_DIR="/home/olof/dev/osandell/tomatoland"
    AUDIO_PLAYER="aplay"
else
    # Assume Linux
    RUNTIME_DIR="$RUNTIME_DIR"
    AUDIO_PLAYER="aplay"
fi

# echo "Runtime directory: $1" >>/tmp/tomatoland.log

if [ "$1" ]; then
    sudo -u olof echo "$1" >"$RUNTIME_DIR/tomatoland.arg"
    chown olof "$RUNTIME_DIR/tomatoland.arg"
else
    sudo -u olof echo "No command line argument provided"
    exit 1
fi

# Signal the running service
if systemctl --user is-active tomatoland-daemon.service &>/dev/null; then
    # Get the PID from systemd
    SERVICE_PID=$(systemctl --user show --property MainPID --value tomatoland-daemon.service)
    
    if [ -n "$SERVICE_PID" ] && [ "$SERVICE_PID" -gt 0 ]; then
        echo "Sending USR1 signal to PID $SERVICE_PID"
        kill -USR1 $SERVICE_PID
    else
        echo "Could not determine PID of tomatoland-daemon service"
        exit 1
    fi
else
    if [ -f "$RUNTIME_DIR/tomatoland.pid" ]; then
        # This will just trigger the trap in tomatoland-daemon.sh. It's not meant to kill the process.
        sudo -u olof kill -USR1 $(cat "$RUNTIME_DIR/tomatoland.pid")
    else
        echo "PID file not found"
        exit 1
    fi
fi
