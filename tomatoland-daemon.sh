#!/usr/bin/env bash

if [[ "$(uname)" == "Darwin" ]]; then
    # macOS
    RUNTIME_DIR="$HOME/Library/Application Support"
    AUDIO_PLAYER="afplay"
else
    # Assume Linux
    RUNTIME_DIR="$RUNTIME_DIR"
    AUDIO_PLAYER="aplay"
fi

echo $$ >"$RUNTIME_DIR/tomatoland.pid"

pomodoro_counter=1800
break_counter=600

pause() {
    case "$status" in
    "running")
        $AUDIO_PLAYER "$(dirname "$0")/pause.wav" &
        printf " $pomodoro_counter" >"$RUNTIME_DIR/tomatoland"
        status=paused
        ;;
    "awaiting_break_start")
        $AUDIO_PLAYER "$(dirname "$0")/play.wav" &
        printf "▶️ $pomodoro_counter" >"$RUNTIME_DIR/tomatoland"
        status=break_running
        ;;
    "break_running")
        $AUDIO_PLAYER "$(dirname "$0")/play.wav" &
        printf "▶ $pomodoro_counter" >"$RUNTIME_DIR/tomatoland"
        status=break_running
        ;;
    *)
        $AUDIO_PLAYER "$(dirname "$0")/play.wav" &
        printf "▶️ $pomodoro_counter" >"$RUNTIME_DIR/tomatoland"
        status=running
        ;;
    esac
}

reset() {
    $AUDIO_PLAYER "$(dirname "$0")/next.wav" &
    pomodoro_counter=1800
    printf "▶️ $pomodoro_counter" >"$RUNTIME_DIR/tomatoland"
    break_counter=600
    status=resetted
}

reset_and_start() {
    $AUDIO_PLAYER "$(dirname "$0")/next.wav" &
    pomodoro_counter=1800
    printf "▶️ $pomodoro_counter" >"$RUNTIME_DIR/tomatoland"
    break_counter=600
    status=running
}

custom_action() {
    if [ -f "$RUNTIME_DIR/tomatoland.arg" ]; then
        custom_argument=$(cat "$RUNTIME_DIR/tomatoland.arg")
        case $custom_argument in
        pause) pause ;;
        reset) reset_and_start ;;
        *) echo "Unknown argument: $custom_argument" ;;
        esac
        rm $RUNTIME_DIR/tomatoland.arg
    else
        echo "Custom action triggered with no argument"
    fi
}

status=resetted
printf " $pomodoro_counter" >"$RUNTIME_DIR/tomatoland"
trap 'custom_action' USR1

while true; do
    case $status in
    running)
        printf "▶️ $((pomodoro_counter / 60))" >"$RUNTIME_DIR/tomatoland"
        sleep 1
        ((pomodoro_counter -= 1))
        if [ $pomodoro_counter -eq 0 ]; then
            status=awaiting_break_start
            $AUDIO_PLAYER "$(dirname "$0")/smw_save_menu.wav" &
        fi
        ;;
    paused)
        printf " $((pomodoro_counter / 60))" >"$RUNTIME_DIR/tomatoland"
        sleep 1
        ;;
    resetted)
        printf "  $((pomodoro_counter / 60))" >"$RUNTIME_DIR/tomatoland"
        sleep 1
        ;;
    awaiting_break_start)
        printf "   $((break_counter / 60))" >"$RUNTIME_DIR/tomatoland"
        sleep 1
        ;;
    break_running)
        printf "▶️ $((break_counter / 60))" >"$RUNTIME_DIR/tomatoland"
        sleep 1
        ((break_counter -= 1))
        if [ $break_counter -eq 0 ]; then
            reset
            $AUDIO_PLAYER ~/Downloads/file.wav &
        fi
        ;;
    break_paused)
        printf "   $((break_counter / 60))" >"$RUNTIME_DIR/tomatoland"
        sleep 1
        ;;
    *)
        echo "Invalid status: $status. Exiting script."
        exit 1
        ;;
    esac
done
