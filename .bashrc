#
# ~/.bashrc
#

[[ $- != *i* ]] && return

[ -f "$HOME/.xprofile" ] && source "$HOME/.xprofile"

PS1='\[\e[38;5;155m\]\u\[\e[0m\] \[\e[38;5;68m\]\w\[\e[0m\]\[\e[38;5;209m\]$(git branch --show-current 2>/dev/null | sed -e "s/.*/ \0/")\[\e[0m\]\[\e[38;2;51;204;255m\] »\[\e[m\] \[\e[0m\]'

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias rm="trash -v"
alias watt="powerstat -d 0 -f -g -c -S -H"

# Import colorscheme from 'wal'
cat "$XDG_CACHE_HOME/wal/sequences"
