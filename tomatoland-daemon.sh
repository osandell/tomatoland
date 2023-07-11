#!/usr/bin/env bash

echo $$ >$XDG_RUNTIME_DIR/tomatoland.pid

pomodoro_counter=1800
break_counter=600

pause() {
    case "$status" in
    "running")
        printf '{"text":"<span>   %d</span>","class":"pomodoro"}\n' "$pomodoro_counter" >$XDG_RUNTIME_DIR/tomatoland.json
        status=paused
        ;;
    "awaiting_break_start")
        printf '{"text":"<span>▶️ %d</span>","class":"pomodoro"}\n' "$pomodoro_counter" >$XDG_RUNTIME_DIR/tomatoland.json
        status=break_running
        ;;
    "break_running")
        printf '{"text":"<span>▶️ %d</span>","class":"pomodoro"}\n' "$pomodoro_counter" >$XDG_RUNTIME_DIR/tomatoland.json
        status=break_running
        ;;
    *)
        printf '{"text":"<span>▶️ %d</span>","class":"pomodoro"}\n' "$pomodoro_counter" >$XDG_RUNTIME_DIR/tomatoland.json
        status=running
        ;;
    esac
}

reset() {
    pomodoro_counter=1800
    printf '{"text":"<span>▶️ %d</span>","class":"pomodoro"}\n' "$pomodoro_counter" >$XDG_RUNTIME_DIR/tomatoland.json
    break_counter=600
    status=resetted
}

reset_and_start() {
    pomodoro_counter=1800
    printf '{"text":"<span>▶️ %d</span>","class":"pomodoro"}\n' "$pomodoro_counter" >$XDG_RUNTIME_DIR/tomatoland.json
    break_counter=600
    status=running
    aplay ~/Downloads/file.wav &
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
printf '{"text":"<span>   %d</span>","class":"pomodoro"}\n' "$pomodoro_counter" >$XDG_RUNTIME_DIR/tomatoland.json
trap 'custom_action' USR1

while true; do
    case $status in
    running)
        printf '{"text":"<span>▶️ %d</span>","class":"pomodoro"}\n' "$((pomodoro_counter / 60))" >$XDG_RUNTIME_DIR/tomatoland.json
        sleep 1
        ((pomodoro_counter -= 1))
        if [ $pomodoro_counter -eq 0 ]; then
            status=awaiting_break_start
            aplay ~/Downloads/file.wav &
        fi
        ;;
    paused)
        printf '{"text":"<span>   %d</span>","class":"pomodoro"}\n' "$((pomodoro_counter / 60))" >$XDG_RUNTIME_DIR/tomatoland.json
        sleep 1
        ;;
    resetted)
        printf '{"text":"<span>   %d</span>","class":"pomodoro"}\n' "$((pomodoro_counter / 60))" >$XDG_RUNTIME_DIR/tomatoland.json
        sleep 1
        ;;
    awaiting_break_start)
        printf '{"text":"<span>   %d</span>","class":"break"}\n' "$((break_counter / 60))" >$XDG_RUNTIME_DIR/tomatoland.json
        sleep 1
        ;;
    break_running)
        printf '{"text":"<span>▶️ %d</span>","class":"break"}\n' "$((break_counter / 60))" >$XDG_RUNTIME_DIR/tomatoland.json
        sleep 1
        ((break_counter -= 1))
        if [ $break_counter -eq 0 ]; then
            reset
            aplay ~/Downloads/file.wav &
        fi
        ;;
    break_paused)
        printf '{"text":"<span>   %d</span>","class":"break"}\n' "$((break_counter / 60))" >$XDG_RUNTIME_DIR/tomatoland.json
        sleep 1
        ;;
    *)
        echo "Invalid status: $status. Exiting script."
        exit 1
        ;;
    esac
done
