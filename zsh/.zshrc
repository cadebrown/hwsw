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

# zstyle ':omz:lib:theme-and-appearance' gnu-ls yes

# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
plugins=(git colorize zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

### PROMPT SETUP ###

# PURE_GIT_UNTRACKED_DIRTY=0
fpath+=("$ZSH_CUSTOM/themes/pure")

autoload -U promptinit
promptinit
zstyle :prompt:pure:git:stash show yes
prompt pure

# aliases
alias g='git'
alias p='uv python'
alias e='nvim'

alias cat='bat --paging=never'
