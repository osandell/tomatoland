#!/usr/bin/env bash

if [ "$1" ]; then
    echo "$1" >$XDG_RUNTIME_DIR/tomatoland.arg
else
    echo "No command line argument provided"
    exit 1
fi

if [ -f "$XDG_RUNTIME_DIR/tomatoland.pid" ]; then
    kill -USR1 $(cat $XDG_RUNTIME_DIR/tomatoland.pid)
else
    echo "PID file not found"
    exit 1
fi
