export ZSH=$HOME/.oh-my-zsh
export ZSH_THEME="wamberg"
export CASE_SENSITIVE="true"
export DISABLE_AUTO_TITLE="true"
plugins=(
    django
    docker
    docker-compose
    git
    git-flow
    gpg-agent
    jira
    tmux
    vi-mode
    virtualenv
    virtualenvwrapper
)
export plugins

### Plugin configuration ###
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
alias randpass="openssl rand -base64 45 | tr -d /=+ | cut -c -30"
# docker base commands
alias d="docker"
alias dc="docker-compose"
alias dm="docker-machine"
# docker custom commands
alias dcs="docker-compose -f staging.yml"
alias drmd="docker images --quiet --filter=dangling=true | xargs docker rmi"  # remove dangling images
alias dps="d ps --format='{{.Label \"com.docker.compose.project\"}}\t{{.Label \"com.docker.compose.service\"}}\t{{.Ports}}' | sort"
