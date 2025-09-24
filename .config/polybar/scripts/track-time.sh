#!/bin/bash

ICON="󰚭"
STATE_FILE="/tmp/polybar_timer_state"
START_FILE="/tmp/polybar_timer_start"
ELAPSED_FILE="/tmp/polybar_timer_elapsed"

get_elapsed() {
    now=$(date +%s)
    if [ -f "$STATE_FILE" ]; then
        state=$(cat "$STATE_FILE")
        case "$state" in
            running)
                start=$(cat "$START_FILE")
                base=$(cat "$ELAPSED_FILE" 2>/dev/null || echo 0)
                echo $((now - start + base))
                ;;
            paused)
                cat "$ELAPSED_FILE" 2>/dev/null || echo 0
                ;;
            *)
                echo 0
                ;;
        esac
    else
        echo 0
    fi
}

format_time() {
    elapsed=$(get_elapsed)
    hours=$((elapsed / 3600))
    minutes=$((elapsed % 3600 / 60))
    seconds=$((elapsed % 60))

    if [ "$elapsed" -lt 60 ]; then
        printf "%02d\n" "$seconds"
    elif [ "$hours" -gt 0 ]; then
        printf "%d:%02d:%02d\n" "$hours" "$minutes" "$seconds"
    else
        printf "%02d:%02d\n" "$minutes" "$seconds"
    fi
}

case "$1" in
    start)
        echo "running" > "$STATE_FILE"
        date +%s > "$START_FILE"
        if [ ! -f "$ELAPSED_FILE" ]; then
            echo 0 > "$ELAPSED_FILE"
        fi
        ;;
    pause)
        if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "running" ]; then
            if [ -f "$START_FILE" ]; then
                now=$(date +%s)
                start=$(cat "$START_FILE")
                base=$(cat "$ELAPSED_FILE" 2>/dev/null || echo 0)
                echo $((now - start + base)) > "$ELAPSED_FILE"
            fi
            echo "paused" > "$STATE_FILE"
        fi
        ;;
    reset)
        echo "reseted" > "$STATE_FILE"
        rm -f "$START_FILE" "$ELAPSED_FILE"
        ;;
    *)
        format_time
        ;;
esac

