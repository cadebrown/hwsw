# .zshrc - interactive ZSH shell configuration (for Cade Brown)

### ZSH SETUP ###

# https://zsh.sourceforge.io/Doc/Release/Options.html
# setopt AUTO_MENU
setopt MENU_COMPLETE

setopt EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_LEX_WORDS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt APPEND_HISTORY

setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_SPACE

setopt EXTENDED_GLOB
setopt NUMERIC_GLOB_SORT
setopt GLOB_STAR_SHORT

setopt C_BASES
setopt C_PRECEDENCES

# TODO: should symlinks be chased?
setopt RM_STAR_SILENT
setopt CHASE_LINKS

### OHMYZSH SETUP ###

export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.oh-my-zsh-custom"
# export ZSH_THEME="afowler"
export ZSH_THEME="" # must be empty for custom prompt

# ZSH completion
# autoload -Uz compinit && compinit

# bash completion
# autoload -Uz bashcompinit && bashcompinit

plugins=(git colorize zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

### PROMPT SETUP ###

# PURE_GIT_UNTRACKED_DIRTY=0
fpath+=("$ZSH_CUSTOM/themes/pure")

autoload -Uz promptinit && promptinit
zstyle :prompt:pure:git:stash show yes
prompt pure

# aliases
alias g='git'
alias p='uv run python'
alias e='nvim'

alias cat='bat --paging=never'

alias cufftbench='./test/cufftbench/cufftbench_static'

# date and time stamping
alias datestamp='date +"%Y%m%d"'
alias timestamp='date +"%Y%m%d%H%M%S"'



# Xan completions
function __xan {
    xan compgen "$1" "$2" "$3"
}
complete -F __xan -o default xan

# Zoxide completions
# eval "$(zoxide init zsh)"
