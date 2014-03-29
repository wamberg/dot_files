ZSH=$HOME/.oh-my-zsh
ZSH_THEME="wamberg"
CASE_SENSITIVE="true"
DISABLE_AUTO_TITLE="true"
plugins=(debian django docker git git-flow tmux virtualenv)

### Plugin configuration ###

# autostart tmux
export ZSH_TMUX_AUTOSTART=true

source $ZSH/oh-my-zsh.sh

### User configuration ###

export PATH=$HOME/bin:/usr/local/bin:$PATH

# customize dircolors
if [ "$TERM" != "dumb" ]; then
    [ -e "$HOME/.dircolors" ] && DIR_COLORS="$HOME/.dircolors"
    [ -e "$DIR_COLORS" ] || DIR_COLORS=""
    eval "`dircolors -b $DIR_COLORS`"
fi

# aliases
alias rs="rsync -avP"
