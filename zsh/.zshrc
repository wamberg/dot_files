export ZSH=$HOME/.oh-my-zsh
export ZSH_THEME=""
export CASE_SENSITIVE="true"
export DISABLE_AUTO_TITLE="true"
plugins=(
  docker
  fzf
  git
)
export plugins

### User configuration ###

# common exports
export EDITOR=$(which nvim)
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export SHELL=$(which zsh)
export PATH="${PATH}:$HOME/.bin:$HOME/.local/bin"
if [[ "$OSTYPE" =~ ^darwin ]]; then
  export PATH="/opt/homebrew/bin:${PATH}"
  # Android
  export ANDROID_HOME=$HOME/Library/Android/sdk
  export PATH=$PATH:$ANDROID_HOME/emulator
  export PATH=$PATH:$ANDROID_HOME/platform-tools

  # kntools
  source $HOME/.kepler/kntools/environment-setup-sdk.sh
fi

# Golang
export GOPATH=~/dev/go
export PATH="${PATH}:${GOPATH}/bin"

# Node
export NODE_PATH=~/.npm-packages/lib/node_modules
export PATH="${PATH}:$HOME/.npm-packages/bin"

# fzf
export FZF_DEFAULT_COMMAND="fd --type f --strip-cwd-prefix --hidden --follow --no-ignore-vcs --ignore-file ~/.gitignore_global"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --strip-cwd-prefix --hidden --follow --no-ignore-vcs --ignore-file ~/.gitignore_global"
export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'

# no history for commands that begin with space
setopt histignorespace

### Plugin configuration ###
source $ZSH/oh-my-zsh.sh  # Activate oh-my-zsh
eval "$(mise activate zsh)"  # Activate mise

# Pure prompt configuration
bindkey -v  # Set Vi mode
fpath=("$HOME/dev/dot_files/zsh/pure" $fpath)
autoload -U promptinit; promptinit
PURE_GIT_UNTRACKED_DIRTY=0
prompt pure

# Eliminate vi-mode normal mode delay
KEYTIMEOUT=1
bindkey -M vicmd 'V' edit-command-line # this remaps `vv` to `V` (but overrides `visual-mode`)

### Aliases ###
alias acs='apt-cache search'
alias aupd='sudo apt update'
alias aupg='sudo apt upgrade'
alias gmd="glow --width 180 --style light"
alias pca="pre-commit run --all-files"
alias randpass="openssl rand -base64 45 | tr -d /=+ | cut -c -30"
alias rs="rsync -avP"
alias ta="tmux attach"
alias xc="xclip -sel clip"
alias zr=",zr.sh"

# cd into a fuzzy (via fzf) directory
c () {
  local dest="${1:-${HOME}/dev}"
  local depth="${2:-20}"
  D="$(\
      fd \
        --type d \
        --hidden \
        --follow \
        --ignore-file ~/.gitignore_global \
        --max-depth ${depth} \
        --full-path \
        --search-path ${dest} \
      2> /dev/null \
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
  tmux split-window -t "${name}":0 -l 70
  tmux send-keys -t "${name}":0 nvim C-m
  tmux attach-session -t "${name}"
}

# Fuzzy change into a directory. Open a named tmux session there.
ct () {
  local dest="${1:-${HOME}/dev}"
  c "${dest}" 1
  [ $? -eq 0 ] || return 1
  tns
}

# docker
alias av="aws-vault"
alias ave="aws-vault exec"
alias d="docker"
alias dc="docker compose"
alias dcup="docker compose up -d"
alias dcd="docker compose down"
alias dcp="docker compose -f docker-compose.yml -f docker-compose.production.yml"
alias dcr="docker compose run --rm"
alias dcs="docker compose -f docker-compose.yml -f docker-compose.staging.yml"

# terraform
alias tf="terraform"
alias tfp="terraform plan"
alias tfa="terraform apply"
