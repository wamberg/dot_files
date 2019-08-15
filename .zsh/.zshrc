export ZSH=$HOME/.oh-my-zsh
export ZSH_THEME=""
export CASE_SENSITIVE="true"
export DISABLE_AUTO_TITLE="true"
plugins=(
    docker
    git
    ssh-agent
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
alias grbe="git diff --name-only --diff-filter=U | uniq  | xargs $EDITOR"
alias randpass="openssl rand -base64 45 | tr -d /=+ | cut -c -30"
alias rs="rsync -avP"
alias tpl="tmuxp load"
alias vimw="vim -u ~/.vimrc-writing"
alias xc="xclip -selection clipboard"
alias xp="xclip -selection clipboard -o"
alias xr="xclip -selection clipboard -o | zsh"

dcli () {
  CONTAINER_NAME='cli_'$(basename "$(pwd)")
  docker run --rm -it -d \
    --name="${CONTAINER_NAME}" --hostname="${CONTAINER_NAME}" \
    --mount="type=bind,src=$(pwd),target=/home/wamberg/dev" \
    --mount="type=bind,src=${HOME}/.ssh,target=/home/wamberg/.ssh" \
    --mount="type=bind,src=${HOME}/.aws,target=/home/wamberg/.aws" \
    wamberg/cli:latest
  docker attach "${CONTAINER_NAME}"
}

n () {
  CONTAINER_NAME='nvim_'$(basename "$(pwd)")
  if [[ -z "$1" ]]; then
    MOUNT_SRC="$(pwd)"
    MOUNT_TARGET="/home/wamberg/dev"
  else
    MOUNT_SRC="$(pwd)/$1"
    MOUNT_TARGET="/home/wamberg/src/$1"
  fi
  docker run --rm -it \
    --name="${CONTAINER_NAME}" --hostname="${CONTAINER_NAME}" \
    --mount="type=bind,src=${MOUNT_SRC},target=${MOUNT_TARGET}" \
    wamberg/cli:latest \
    nvim --cmd "cd src" ${MOUNT_TARGET}
}

lps () {
  limegreen="%F{118}"
  purple="%F{135}"
  lpass ls | grep -i "$1" | while read -r record
  do
    id=$(grep -o '\[id.*' <<< "$record" | grep -Eo '[0-9]*')
    username=$(lpass show --username "$id")
    password=$(lpass show --password "$id")
    url=$(lpass show --url "$id")
    print -P "$limegreen$record%f"
    print -P "$purple username:%f $username"
    print -P "$purple password:%f $password"
    print -P "$purple url:%f $url"
  done
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
