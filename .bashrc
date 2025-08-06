#
# ~/.bashrc
#

# After new value in this file you should update script typing (source ~/.bashrc)

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
export PS1="┌──\u@\h[\w]\n└─╼ "

# Autostart x session
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx

# Custom aliases
defText=nvim
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
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
alias rm="trash -v"
# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/sergilk/.lmstudio/bin"
# End of LM Studio CLI section

