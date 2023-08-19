#!/usr/bin/env bash

echo $$ >$XDG_RUNTIME_DIR/tomatoland.pid

pomodoro_counter=1800
break_counter=600

pause() {
    case "$status" in
    "running")
        aplay "$(dirname "$0")/pause.wav" &
        printf " $pomodoro_counter" >$XDG_RUNTIME_DIR/tomatoland
        status=paused
        ;;
    "awaiting_break_start")
        aplay "$(dirname "$0")/play.wav" &
        printf "▶️ $pomodoro_counter" >$XDG_RUNTIME_DIR/tomatoland
        status=break_running
        ;;
    "break_running")
        aplay "$(dirname "$0")/play.wav" &
        printf "▶ $pomodoro_counter" >$XDG_RUNTIME_DIR/tomatoland
        status=break_running
        ;;
    *)
        aplay "$(dirname "$0")/play.wav" &
        printf "▶️ $pomodoro_counter" >$XDG_RUNTIME_DIR/tomatoland
        status=running
        ;;
    esac
}

reset() {
    aplay "$(dirname "$0")/next.wav" &
    pomodoro_counter=1800
    printf "▶️ $pomodoro_counter" >$XDG_RUNTIME_DIR/tomatoland
    break_counter=600
    status=resetted
}

reset_and_start() {
    aplay "$(dirname "$0")/next.wav" &
    pomodoro_counter=1800
    printf "▶️ $pomodoro_counter" >$XDG_RUNTIME_DIR/tomatoland
    break_counter=600
    status=running
}

custom_action() {
    if [ -f "$XDG_RUNTIME_DIR/tomatoland.arg" ]; then
        custom_argument=$(cat $XDG_RUNTIME_DIR/tomatoland.arg)
        case $custom_argument in
        pause) pause ;;
        reset) reset_and_start ;;
        *) echo "Unknown argument: $custom_argument" ;;
        esac
        rm $XDG_RUNTIME_DIR/tomatoland.arg
    else
        echo "Custom action triggered with no argument"
    fi
}

status=resetted
printf " $pomodoro_counter" >$XDG_RUNTIME_DIR/tomatoland
trap 'custom_action' USR1

while true; do
    case $status in
    running)
        printf "▶️ $((pomodoro_counter / 60))" >$XDG_RUNTIME_DIR/tomatoland
        sleep 1
        ((pomodoro_counter -= 1))
        if [ $pomodoro_counter -eq 0 ]; then
            status=awaiting_break_start
            aplay "$(dirname "$0")/smw_save_menu.wav" &
        fi
        ;;
    paused)
        printf " $((pomodoro_counter / 60))" >$XDG_RUNTIME_DIR/tomatoland
        sleep 1
        ;;
    resetted)
        printf "  $((pomodoro_counter / 60))" >$XDG_RUNTIME_DIR/tomatoland
        sleep 1
        ;;
    awaiting_break_start)
        printf "   $((break_counter / 60))" >$XDG_RUNTIME_DIR/tomatoland
        sleep 1
        ;;
    break_running)
        printf "▶️ $((break_counter / 60))" >$XDG_RUNTIME_DIR/tomatoland
        sleep 1
        ((break_counter -= 1))
        if [ $break_counter -eq 0 ]; then
            reset
            aplay ~/Downloads/file.wav &
        fi
        ;;
    break_paused)
        printf "   $((break_counter / 60))" >$XDG_RUNTIME_DIR/tomatoland
        sleep 1
        ;;
    *)
        echo "Invalid status: $status. Exiting script."
        exit 1
        ;;
    esac
done
