#!/usr/bin/env bash

# touch /tmp/tomatoland.log

if [[ "$(uname)" == "Darwin" ]]; then
    # macOS
    RUNTIME_DIR="/Users/olof/Library/Application Support"
else
    # Assume Linux
    RUNTIME_DIR="$XDG_RUNTIME_DIR"
fi

# echo "Runtime directory: $1" >>/tmp/tomatoland.log

if [ "$1" ]; then
    sudo -u olof echo "$1" >"$RUNTIME_DIR/tomatoland.arg"
    chown olof "$RUNTIME_DIR/tomatoland.arg"
else
    sudo -u olof echo "No command line argument provided"
    exit 1
fi

if [ -f "$RUNTIME_DIR/tomatoland.pid" ]; then
    # This will just trigger the trap in tomatoland-daemon.sh. It's not meant to kill the process.
    sudo -u olof kill -USR1 $(cat "$RUNTIME_DIR/tomatoland.pid")
else
    echo "PID file not found"
    exit 1
fi
