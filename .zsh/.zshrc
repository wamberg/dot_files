export ZSH=$HOME/.oh-my-zsh
export ZSH_THEME=""
export CASE_SENSITIVE="true"
export DISABLE_AUTO_TITLE="true"
plugins=(
  asdf
  docker
  git
  ssh-agent
  yarn
)
export plugins

### User configuration ###

# common exports
export EDITOR=$(which nvim)
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export SHELL=$(which zsh)
export TERM=screen-256color
export PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$HOME/.local/bin:/usr/local/bin:${PATH}:$HOME/.local/go/bin"

#
export PATH="${PATH}:/usr/local/go/bin"
export GOPATH=~/dev/go
export PATH="${PATH}:${GOPATH}/bin"

# no history for commands that begin with space
setopt histignorespace

### Plugin configuration ###
source $ZSH/oh-my-zsh.sh

# Pure prompt configuration
bindkey -v  # Set Vi mode
fpath=("$HOME/dev/dot_files/.zsh/pure" $fpath)
autoload -U promptinit; promptinit
PURE_GIT_UNTRACKED_DIRTY=0
prompt pure


# Eliminate vi-mode normal mode delay
KEYTIMEOUT=1

# aliases
alias ag="ag --path-to-ignore ~/.gitignore_global"
alias gbdm="git branch --merged | egrep -v \"(^\*|master)\" | xargs git branch -d"
alias o="./omks"
alias ob="./omks build"
alias or="./omks run"
alias os="./omks stop"
alias ov="./omks vars"
alias randpass="openssl rand -base64 45 | tr -d /=+ | cut -c -30"
alias rs="rsync -avP"
alias tpl="tmuxp load"

j () {
  # "journal" - open a new file in work-log
  FILENAME="$(date -Iseconds).md"
  nvim -c ":Goyo" "${HOME}/dev/work-log/${FILENAME}"
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
