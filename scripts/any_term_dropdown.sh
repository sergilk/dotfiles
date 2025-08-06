#!/usr/bin/env bash
# AUTHOR: gotbletu (@gmail|twitter|youtube|github|lbry)
#         https://www.youtube.com/user/gotbletu
# DESC:   turn any terminal into a dropdown terminal
# DEMO:   https://www.youtube.com/watch?v=mVw2gD9iiOg
# DEPEND: coreutils xdotool wmutils (https://github.com/wmutils/core | https://aur.archlinux.org/packages/wmutils-git/)
# CLOG:   2022-03-05   else statement to allow terminal to jump to current virtual desktop if is visible on another desktop
#         2022-02-28   added auto launch terminal if none running by https://github.com/aaccioly
#         2021-02-10   use comm to match window name and class, this avoids terminal windows with different names
#         2015-02-15   0.1

# option 1: set terminal emulator manually
my_term="alacritty"

# option 2: auto detect terminal emulator (note: make sure to only open one)
# my_term="urxvt|kitty|xterm|uxterm|termite|sakura|lxterminal|terminator|mate-terminal|pantheon-terminal|konsole|gnome-terminal|xfce4-terminal"

# get terminal emulator pid ex: 44040485
pid=$(xdotool search --class "$my_term" | tail -n1)

# start a new terminal if none is currently running
if [[ -z "$pid" ]]; then
    while IFS='|' read -ra TERMS; do
        for candidate_term in "${TERMS[@]}"; do
            if command -v "$candidate_term" &>/dev/null; then
				if [[ "$candidate_term" == "alacritty" ]]; then
				     ${candidate_term} -e tmux &>/dev/null &
				else	
					${candidate_term} &>/dev/null &
				fi
				disown
                pid=$!
                break
            fi
        done
    done <<<"$my_term"
else
    # get windows id from pid ex: 0x2a00125%
    wid=$(printf 0x%x "$pid")

    # toggle show/hide terminal emulator
    mapw -t "$wid"
fi
