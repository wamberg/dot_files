export ZSH=$HOME/.oh-my-zsh
export ZSH_THEME=""
export CASE_SENSITIVE="true"
export DISABLE_AUTO_TITLE="true"
plugins=(
    docker
    git
    ssh-agent
    yarn
    zsh-nvm
)
export plugins

### User configuration ###

# common exports
export EDITOR=$(which nvim)
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export SHELL=$(which zsh)
export TERM=screen-256color
export PYENV_ROOT=$HOME/.pyenv
export PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$HOME/.local/bin:/usr/local/bin:${PATH}:/usr/local/go/bin"

#
export PATH="${PATH}:/usr/local/go/bin"
export GOPATH=~/dev/golib
export PATH="${PATH}:${GOPATH}/bin"

# no history for commands that begin with space
setopt histignorespace

### Plugin configuration ###
source $ZSH/oh-my-zsh.sh
eval "$(pyenv init -)"

# Pure prompt configuration
bindkey -v  # Set Vi mode
fpath=("$HOME/.zfunctions" $fpath)
autoload -U promptinit; promptinit
PURE_GIT_UNTRACKED_DIRTY=0
prompt pure

# aliases
alias gbdm="git branch --merged | egrep -v \"(^\*|master)\" | xargs git branch -d"
alias randpass="openssl rand -base64 45 | tr -d /=+ | cut -c -30"
alias rs="rsync -avP"
alias tpl="tmuxp load"
alias ag="ag --path-to-ignore ~/.gitignore_global"

j () {
  # "journal" - open a new file in work-log
  FILENAME="$(date -Iseconds).md"
  nvim "${HOME}/dev/work-log/${FILENAME}"
}

t () {
  # "todo" - open todo file in work-log
  nvim "${HOME}/dev/work-log/todo.md"
}

# docker
alias d="docker"
alias dc="docker-compose"
alias dm="docker-machine"
alias dcup="docker-compose up -d"
alias dcd="docker-compose -f docs.yml"
alias dcp="docker-compose -f docker-compose.yml -f docker-compose.production.yml"
alias dcr="docker-compose run --rm"
alias dcs="docker-compose -f docker-compose.yml -f docker-compose.staging.yml"
# kubernetes
alias k="kubectl"
kn() {
  kubectl --namespace=$K8S_NAMESPACE $@
}
# terraform
alias tf="terraform"
alias tfp="terraform plan"
alias tfa="terraform apply"
