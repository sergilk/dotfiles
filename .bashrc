#
# ~/.bashrc
#

[[ $- != *i* ]] && return
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx

PS1='\[\e[38;5;155m\]\u\[\e[0m\] \[\e[38;5;68m\]\w\[\e[0m\]\[\e[38;5;209m\]$(git branch --show-current 2>/dev/null | sed -e "s/.*/ \0/")\[\e[0m\]\[\e[38;2;51;204;255m\] »\[\e[m\] \[\e[0m\]'

alias lsa="ls -A"
alias mhdd="sudo mount /dev/sdb1 /mnt/hdd"
alias uhdd="sudo umount /mnt/hdd"
alias code="code --password-store=gnome-libsecret"
alias rm="trash -v"
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
