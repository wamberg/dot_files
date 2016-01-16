export ZSH=$HOME/.oh-my-zsh
export ZSH_THEME="wamberg"
export CASE_SENSITIVE="true"
export DISABLE_AUTO_TITLE="true"
export plugins=(
    debian
    django
    docker
    docker-compose
    git
    git-flow
    tmux
    tmuxinator
    vi-mode
    virtualenv
    virtualenvwrapper
)

source $ZSH/oh-my-zsh.sh

### User configuration ###
# virtualenvwrapper env vars
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/dev/projects

# common exports
export PATH=$HOME/.local/bin:$PATH
export EDITOR=vim
export SHELL=zsh

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
# docker base commands
alias d="docker"
alias dm="docker-machine"
alias dc="docker-compose"
# docker custom commands
alias dcp="docker-compose -f production.yml"
alias dps="d ps --format='{{.Label \"com.docker.compose.project\"}}\t{{.Label \"com.docker.compose.service\"}}\t{{.Ports}}' | sort"
