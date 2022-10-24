export ZSH=$HOME/.oh-my-zsh
export ZSH_THEME=""
export CASE_SENSITIVE="true"
export DISABLE_AUTO_TITLE="true"
plugins=(
  asdf
  docker
  git
)
export plugins

### User configuration ###

# common exports
export EDITOR=$(which lvim)
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export SHELL=$(which zsh)
export TERM=tmux-256color
export PATH="${PATH}:$HOME/.bin:$HOME/.local/bin"


# Golang
export GOPATH=~/dev/go
export PATH="${PATH}:${GOPATH}/bin"

# Node
export NODE_PATH=~/.npm-packages/lib/node_modules
export PATH="${PATH}:$HOME/.npm-packages/bin"


# fzf
export FZF_DEFAULT_COMMAND='rg --hidden --no-ignore --follow --files --ignore-file ~/.gitignore_global'

# nvim zen-mode
export KITTY_LISTEN_ON="unix:/tmp/kitty-$(pidof kitty)"

# no history for commands that begin with space
setopt histignorespace

### Plugin configuration ###
source $ZSH/oh-my-zsh.sh

# Pure prompt configuration
bindkey -v  # Set Vi mode
fpath=("$HOME/dev/dot_files/zsh/pure" $fpath)
autoload -U promptinit; promptinit
PURE_GIT_UNTRACKED_DIRTY=0
prompt pure

# Eliminate vi-mode normal mode delay
KEYTIMEOUT=1

# aliases
alias gmd="glow --width 180 --style light"
alias nvim="lvim"
alias o="./omks"
alias ob="./omks build"
alias or="./omks run"
alias os="./omks stop"
alias osh="./omks shell"
alias ov="./omks vars"
alias pca="pre-commit run --all-files"
alias randpass="openssl rand -base64 45 | tr -d /=+ | cut -c -30"
alias rs="rsync -avP"
alias ta="tmux attach"
alias xc="xclip -sel clip"

# cd into a fuzzy (via fzf) directory
c () {
  local dest="${1:-${HOME}/dev}"
  local depth="${2:-20}"
  D="$(\
    rg \
      --hidden \
      --no-ignore \
      --follow \
      --files \
      --ignore-file ~/.gitignore_global \
      --null \
      --max-depth ${depth} \
      ${dest} \
      2> /dev/null \
    | xargs -0 dirname \
    | sort -u \
    | fzf)"
  [ $? -eq 0 ] || return 1
  cd "${D}"
}

# Open a named tmux session. Use the last directory in current path as the
# session name.
tns () {
  local name="${1:-${PWD##*/}}"
  tmux new-session -ds "${name}" -x "$(tput cols)" -y "$(tput lines)"
  tmux rename-window -t "${name}":0 "code"
  tmux split-window -p 70
  tmux send-keys -t "${name}":0 nvim C-m
  tmux attach-session -t "${name}"
}

# Fuzzy change into a directory. Open a named tmux session there.
ct () {
  local dest="${1:-${HOME}/dev}"
  c "${dest}" 2
  [ $? -eq 0 ] || return 1
  tns
}

# docker
alias d="docker"
alias dc="docker compose"
alias dcup="docker compose up -d"
alias dcd="docker compose -f docs.yml"
alias dcp="docker compose -f docker-compose.yml -f docker-compose.production.yml"
alias dcr="docker compose run --rm"
alias dcs="docker compose -f docker-compose.yml -f docker-compose.staging.yml"
# kubernetes
alias k="kubectl"
kn() {
  kubectl --namespace=$K8S_NAMESPACE $@
}
# terraform
alias tf="terraform"
alias tfp="terraform plan"
alias tfa="terraform apply"
