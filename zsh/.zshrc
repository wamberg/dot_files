export ZSH=$HOME/.oh-my-zsh
export ZSH_THEME=""
export CASE_SENSITIVE="true"
export DISABLE_AUTO_TITLE="true"
plugins=(
  asdf
  direnv
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
export TERM=tmux-256color
export PATH="$HOME/.local/bin:${PATH}"

# Golang
export GOPATH=~/dev/go
export PATH="${PATH}:${GOPATH}/bin"

# fzf
export FZF_DEFAULT_COMMAND='rg --hidden --no-ignore --follow --files --ignore-file ~/.gitignore_global'

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
alias ahm="~/dev/dot_files/nix/apply-users.sh"
alias asys="~/dev/dot_files/nix/apply-system.sh"
alias ns="nix search nixpkgs"
alias o="./omks"
alias ob="./omks build"
alias or="./omks run"
alias os="./omks stop"
alias ov="./omks vars"
alias pca="pre-commit run --all-files"
alias randpass="openssl rand -base64 45 | tr -d /=+ | cut -c -30"
alias rs="rsync -avP"
alias upd="~/dev/dot_files/nix/update.sh"

# cd into a fuzzy (via fzf) directory
c () {
  local dest="${1:-${HOME}/dev}"
  D="$(\
    rg \
      --hidden \
      --no-ignore \
      --follow \
      --files \
      --ignore-file ~/.gitignore_global \
      --null \
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
  tmux new-session -ds "${name}"
  tmux rename-window -t "${name}":0 "manage"
  tmux new-window -t "${name}" -n "code"
  tmux send-keys -t "${name}":1 nvim C-m
  tmux new-window -t "${name}" -n "nav"
  tmux last-window -t "${name}"
  tmux attach-session -t "${name}"
}

# Fuzzy change into a directory. Open a named tmux session there.
ct () {
  local dest="${1:-${HOME}/dev}"
  c "${dest}"
  [ $? -eq 0 ] || return 1
  tns
}

# docker
alias d="docker"
alias dc="docker-compose"
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
