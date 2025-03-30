#!/usr/bin/env bash

if [[ "$(uname)" == "Darwin" ]]; then
    # macOS
    RUNTIME_DIR="$HOME/Library/Application Support"
    AUDIO_PLAYER="afplay"
elif grep -q microsoft /proc/version; then
    # WSL
    RUNTIME_DIR="/home/olof/dev/osandell/tomatoland"
    AUDIO_PLAYER="/bin/aplay"
else
    # Assume Linux
    RUNTIME_DIR="$RUNTIME_DIR"
    AUDIO_PLAYER="aplay"
fi

# Set proper UTF-8 encoding
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

echo $$ >"$RUNTIME_DIR/tomatoland.pid"

pomodoro_counter=1800
break_counter=600

start() {
    $AUDIO_PLAYER "$(dirname "$0")/turning-page.wav" &
    pomodoro_counter=1800
    printf "▶ $((pomodoro_counter / 60))" >"$RUNTIME_DIR/tomatoland"
    break_counter=600
    status=running
}

stop() {
    $AUDIO_PLAYER "$(dirname "$0")/book-closing.wav" &
    pomodoro_counter=1800
    printf "▶ $((pomodoro_counter / 60))" >"$RUNTIME_DIR/tomatoland"
    break_counter=600
    status=stopped
}

pause() {
    case "$status" in
    "running")
        $AUDIO_PLAYER "$(dirname "$0")/pause-tape-recorder.wav" &
        printf "⏸ $((pomodoro_counter / 60))" >"$RUNTIME_DIR/tomatoland"
        status=paused
        ;;
    "awaiting_break_start")
        $AUDIO_PLAYER "$(dirname "$0")/play-tape-recorder.wav" &
        printf "▶ $((pomodoro_counter / 60))" >"$RUNTIME_DIR/tomatoland"
        status=break_running
        ;;
    "break_running")
        $AUDIO_PLAYER "$(dirname "$0")/play-tape-recorder.wav" &
        printf "▶ $((pomodoro_counter / 60))" >"$RUNTIME_DIR/tomatoland"
        status=break_running
        ;;
    *)
        $AUDIO_PLAYER "$(dirname "$0")/play-tape-recorder.wav" &
        printf "▶ $((pomodoro_counter / 60))" >"$RUNTIME_DIR/tomatoland"
        status=running
        ;;
    esac
}

custom_action() {
    # Use absolute path for the argument file
    ARG_FILE="$RUNTIME_DIR/tomatoland.arg"
    
    if [ -f "$ARG_FILE" ]; then
        # Trim whitespace including newlines
        custom_argument=$(tr -d '[:space:]' < "$ARG_FILE")
        echo "Custom action triggered with argument: '$custom_argument'"
        case $custom_argument in
        start) start ;;
        stop) stop ;;
        pause) pause ;;
        *) echo "Unknown argument: '$custom_argument'" ;;
        esac
        rm "$ARG_FILE"
    else
        echo "Custom action triggered with no argument"
    fi
}

status=stopped
printf "⏸ $pomodoro_counter" >"$RUNTIME_DIR/tomatoland"
trap 'custom_action' USR1

echo "Tomatoland daemon started with PID $$"

while true; do
    case $status in
    running)
        #printf "▶ $((pomodoro_counter / 60))" >"$RUNTIME_DIR/tomatoland"
        sleep 1
        ((pomodoro_counter -= 1))
        if [ $pomodoro_counter -eq 0 ]; then
            status=awaiting_break_start
            $AUDIO_PLAYER "$(dirname "$0")/smw_save_menu.wav" &
        fi
        ;;
    paused)
        printf "⏸ $((pomodoro_counter / 60))" >"$RUNTIME_DIR/tomatoland"
        sleep 1
        ;;
    stopped)
        printf "⏸ $((pomodoro_counter / 60))" >"$RUNTIME_DIR/tomatoland"
        sleep 1
        ;;
    awaiting_break_start)
        printf "⏸ $((break_counter / 60))" >"$RUNTIME_DIR/tomatoland"
        sleep 1
        ;;
    break_running)
        printf "▶ $((break_counter / 60))" >"$RUNTIME_DIR/tomatoland"
        sleep 1
        ((break_counter -= 1))
        if [ $break_counter -eq 0 ]; then
            status=stopped
            pomodoro_counter=1800
            break_counter=600
            $AUDIO_PLAYER ~/Downloads/file.wav &
        fi
        ;;
    break_paused)
        printf "⏸ $((break_counter / 60))" >"$RUNTIME_DIR/tomatoland"
        sleep 1
        ;;
    *)
        echo "Invalid status: $status. Exiting script."
        exit 1
        ;;
    esac
done
