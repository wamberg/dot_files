export ZSH=$HOME/.oh-my-zsh
export ZSH_THEME="wamberg"
export CASE_SENSITIVE="true"
export DISABLE_AUTO_TITLE="true"
plugins=(
    colored-man-pages
    docker
    docker-compose
    git
    git-flow
    jira
    vi-mode
    virtualenv
    virtualenvwrapper
)
export plugins

### User configuration ###
# virtualenvwrapper env vars
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/dev/projects
export VIRTUALENVWRAPPER_PYTHON=$(which python3)

# common exports
export PATH=$HOME/.local/bin:$PATH
export EDITOR=vim
export SHELL=zsh
export TERM=screen-256color

### Plugin configuration ###
source $ZSH/oh-my-zsh.sh

# aliases
alias rs="rsync -avP"
alias randpass="openssl rand -base64 45 | tr -d /=+ | cut -c -30"
alias vimw="vim -u ~/.vimrc-writing"
alias xp="xclip -selection clipboard -o"
alias xc="xclip -selection clipboard"
alias xr="xclip -selection clipboard -o | zsh"
# docker base commands
alias d="docker"
alias dc="docker-compose"
alias dm="docker-machine"
# docker custom commands
alias dcs="docker-compose -f staging.yml"
alias drmd="docker images --quiet --filter=dangling=true | xargs docker rmi"  # remove dangling images
