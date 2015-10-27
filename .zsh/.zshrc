ZSH=$HOME/.oh-my-zsh
ZSH_THEME="wamberg"
CASE_SENSITIVE="true"
DISABLE_AUTO_TITLE="true"
plugins=(
    django
    docker
    docker-compose
    git
    git-flow
    jira
    tmux
    virtualenv
    virtualenvwrapper
    vi-mode
)

### Plugin configuration ###

# autostart tmux
export ZSH_TMUX_AUTOSTART=true

source $ZSH/oh-my-zsh.sh

### User configuration ###
# virtualenvwrapper env vars
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/dev/projects

# customize dircolors
if [ "$TERM" != "dumb" ]; then
    [ -e "$HOME/.dircolors" ] && DIR_COLORS="$HOME/.dircolors"
    [ -e "$DIR_COLORS" ] || DIR_COLORS=""
    eval "`dircolors -b $DIR_COLORS`"
fi

# aliases
alias rs="rsync -avP"
alias grr="grep -r"
alias grl="grep -rl"
alias d="docker"
alias dc="docker-compose"
alias dm="docker-machine"
