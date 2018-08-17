export ZSH=$HOME/.oh-my-zsh
export ZSH_THEME="steeef"
export CASE_SENSITIVE="true"
export DISABLE_AUTO_TITLE="true"
plugins=(
    colored-man-pages
    docker
    git
    git-flow
    golang
    ssh-agent
    vi-mode
)
export plugins

### User configuration ###

# common exports
export GOPATH=$HOME/dev/projects/go
export GOROOT=/usr/local/opt/go/libexec
export PATH=$HOME/.local/bin:$PATH
export PATH=/usr/local/bin:$PATH
export PATH=$GOPATH/bin:$PATH
export PATH=$GOROOT/bin:$PATH
export EDITOR=$(which nvim)
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export SHELL=$(which zsh)
export TERM=screen-256color

# no history for commands that begin with space
setopt histignorespace

### Plugin configuration ###
source $ZSH/oh-my-zsh.sh
eval "$(pyenv init -)"

# aliases
alias gcbb='git checkout -b $(pbpaste) origin/$(pbpaste)' # OSX only
alias randpass="openssl rand -base64 45 | tr -d /=+ | cut -c -30"
alias rs="rsync -avP"
alias t="task"
alias tpl="tmuxp load"
alias vimw="vim -u ~/.vimrc-writing"
alias xc="xclip -selection clipboard"
alias xp="xclip -selection clipboard -o"
alias xr="xclip -selection clipboard -o | zsh"
# git
gmd () {
  # usage: gcm && gmd feature/x
  git merge --no-ff $@
  git branch -D $@
  echo "Delete the remote branch? [y|n]: "
  read yn
  if [ $yn == 'y' ]; then
    git push --delete origin $@
  fi
}
# docker
alias d="docker"
alias dc="docker-compose"
alias dm="docker-machine"
alias dcd="docker-compose -f docs.yml"
alias dcp="docker-compose -f production.yml"
alias dcr="docker-compose run --rm"
alias dcs="docker-compose -f staging.yml"
# kubernetes
alias k="kubectl"
kn() {
  kubectl --namespace=$K8S_NAMESPACE $@
}
# terraform
alias tf="terraform"
alias tfp="terraform plan"
alias tfa="terraform apply"
