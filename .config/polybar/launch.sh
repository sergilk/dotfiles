#!/usr/bin/env bash

killall polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

polybar main -q -c "$XDG_CONFIG_HOME/polybar/config.ini"
