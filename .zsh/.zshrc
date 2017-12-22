export ZSH=$HOME/.oh-my-zsh
export ZSH_THEME="wamberg"
export CASE_SENSITIVE="true"
export DISABLE_AUTO_TITLE="true"
plugins=(
    colored-man-pages
    docker
    git
    git-flow
    jira
    ssh-agent
    vi-mode
)
export plugins

### User configuration ###

# common exports
export PATH=$HOME/.local/bin:/usr/local/bin:$PATH
export EDITOR=$(which nvim)
export SHELL=$(which zsh)
export TERM=screen-256color

# no history for commands that begin with space
setopt histignorespace

### Plugin configuration ###
source $ZSH/oh-my-zsh.sh

# aliases
alias rs="rsync -avP"
alias randpass="openssl rand -base64 45 | tr -d /=+ | cut -c -30"
alias vimw="vim -u ~/.vimrc-writing"
alias xp="xclip -selection clipboard -o"
alias xc="xclip -selection clipboard"
alias xr="xclip -selection clipboard -o | zsh"
alias tpl="tmuxp load"
# docker base commands
alias d="docker"
alias dc="docker-compose"
alias dm="docker-machine"
# kubernetes base commands
alias k="kubectl"
alias kn="kubectl --namespace=$K8S_NAMESPACE"
# docker custom commands
alias dcd="docker-compose -f docs.yml"
alias dcp="docker-compose -f production.yml"
alias dcr="docker-compose run --rm"
alias dcs="docker-compose -f staging.yml"
