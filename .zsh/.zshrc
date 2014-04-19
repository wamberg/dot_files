ZSH=$HOME/.oh-my-zsh
ZSH_THEME="wamberg"
CASE_SENSITIVE="true"
DISABLE_AUTO_TITLE="true"
plugins=(debian django docker git git-flow tmux virtualenv)

### Plugin configuration ###

# autostart tmux
export ZSH_TMUX_AUTOSTART=true

source $ZSH/oh-my-zsh.sh

### User configuration ###

# GO env vars
export GOROOT=$HOME/dev/go
export GOPATH=$HOME/dev/gocode
# virtualenvwrapper env vars
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/dev/projects

export PATH=$GOROOT/bin:$GOPATH/bin:/usr/local/bin:$PATH

source /usr/local/bin/virtualenvwrapper.sh
source /usr/local/bin/activate.sh

# customize dircolors
if [ "$TERM" != "dumb" ]; then
    [ -e "$HOME/.dircolors" ] && DIR_COLORS="$HOME/.dircolors"
    [ -e "$DIR_COLORS" ] || DIR_COLORS=""
    eval "`dircolors -b $DIR_COLORS`"
fi

# aliases
alias rs="rsync -avP"
alias grr="grep -r"
alias grl="grep -rl"
