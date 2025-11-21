#!/usr/bin/env bash

source $HOME/.cache/wal/colors.sh

background="$(grep -m1 -E 'background' "$HOME/.cache/wal/dunstrc")"
foreground="$(grep -m1 -E 'foreground' "$HOME/.cache/wal/dunstrc")"

sed -i --follow-symlinks "s|^background.*|${background}|" "$HOME/.config/dunst/dunstrc"
sed -i --follow-symlinks "s|^foreground.*|${foreground}|" "$HOME/.config/dunst/dunstrc"

pkill dunst
dunst &
