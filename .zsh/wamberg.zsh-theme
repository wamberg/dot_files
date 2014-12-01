# wamberg: Customized theme based on ys.
# 
# http://ysmood.org/wp/2013/03/my-ys-terminal-theme/
# Mar 2013 ys

# Machine name.
function box_name {
    [ -f ~/.box-name ] && cat ~/.box-name || hostname
}

# Directory info.
local current_dir='${PWD/#$HOME/~}'
local vi_mode_info='$(vi_mode_prompt_info)'

# Git info.
local git_info='$(git_prompt_info)'
ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[white]%}on%{$reset_color%} git:%{$fg[cyan]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}x"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}o"

# Prompt format: \n # USER at MACHINE in DIRECTORY on git:BRANCH STATE [TIME] \n $ 
PROMPT="
%{$terminfo[bold]$fg[blue]%}#%{$reset_color%} \
%{$terminfo[bold]$fg[yellow]%}${current_dir}%{$reset_color%} \
%{$fg[white]%}as \
%{$fg[cyan]%}%n \
%{$fg[white]%}at \
%{$fg[green]%}$(box_name)\
${git_info} \
%{$fg[white]%}[%*] \
${vi_mode_info}
%{$terminfo[bold]$fg[red]%}$ %{$reset_color%}"

# right prompt
if type "virtualenv_prompt_info" > /dev/null
then
	RPROMPT='$(virtualenv_prompt_info)%{$reset_color%}%'
else
	RPROMPT=''
fi
