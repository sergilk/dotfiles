#
# ~/.bashrc
#

# After new value in this file you should update script typing (source ~/.bashrc)

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# Autostart x session
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx

# Custom aliases
defText=leafpad
flbText=nano

alias i3c="${defText:-$flbText} ~/.config/i3/config"
alias brc="${defText:-$flbText} ~/.bashrc"
alias xrc="${defText:-$flbText} ~/.xinitrc"
alias pbc="sudo -E ${defText:-$flbText} ~/.config/polybar/config.ini"
alias lsa="ls -A"
alias rfc="${defText:-$flbText} ~/.config/rofi/config.rasi"
alias pic="${defText:-$flbText} ~/.config/picom/picom.conf"
alias desk="lsa /usr/share/applications/"
alias mhdd="sudo mount /dev/sdb1 /mnt/hdd"
alias uhdd="sudo umount /mnt/hdd"
alias code="code --password-store=gnome-libsecret"