# .zprofile - ZSH setup for login shells

### GENERAL SETUP ###

# set general information used by various programs and system utilities
export LANG=en_US.UTF-8

# set the default editor and pager
export EDITOR='nvim'
# export PAGER='nvim -R'
export MANPAGER='nvim +Man!'

# set the default web browser as lynx
export BROWSER='lynx'


### HOMEBREW SETUP ###

if [ -e "$HOME/.homebrew" ]; then
    # if prefer the user-specific Homebrew over the system-wide Homebrew, if it exists
    eval "$(~/.homebrew/bin/brew shellenv)"

    # FIX: problems with perl and stow
    export PERLLIB="$HOMEBREW_PREFIX/Cellar/stow/2.4.1/home/linuxbrew/.linuxbrew/Cellar/perl/5.38.2_1/lib/perl5/site_perl/5.38"

elif [ -e "/opt/homebrew" ]; then

    # otherwise, if the system-wide Homebrew exists, use it
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

### PATHS SETUP ###

# path to NVIDIA shared storage (NIS 'scratch space'), which is automounted on most systems
# TODO: support on my MacBook too?
if [ -e "$HOME/scratch" ]; then
    export SCRATCH=`realpath "$HOME/scratch"`
fi

# guide here: https://gitlab-master.nvidia.com/cuda-hpc-libraries/tools/conan/mathlibs-conan-recipes
export CONAN_HOME=$HOME/.conan2


### PYTHON SETUP ###

# disable virtual environment prompt for the default virtual environment
# TODO: is there a better way to do this? (so subsequent venvs do have a prompt?)
export VIRTUAL_ENV_DISABLE_PROMPT=1

# activate default Python virtual environment, installed in 
source ~/.venv/bin/activate

# use interactive Python startup file
export PYTHONSTARTUP="$HOME/.pythonrc"

### CUDA SETUP ###

# CUDA setup (only if there is a folder ~/cuda)
export CUDA_HOME="$HOME/cuda"
if [ -e "$CUDA_HOME" ]; then
    export PATH="$CUDA_HOME/bin:$PATH"
    export LD_LIBRARY_PATH="$CUDA_HOME/lib64:$CUDA_HOME/lib:$LD_LIBRARY_PATH"
    export C_INCLUDE_PATH="$CUDA_HOME/include:$C_INCLUDE_PATH"
    export CPLUS_INCLUDE_PATH="$CUDA_HOME/include:$CPLUS_INCLUDE_PATH"
fi

# NSYS setup (only if there is a folder ~/nsys)
export NSYS_HOME="$HOME/nsys"
if [ -d "$NSYS_HOME" ]; then
    export PATH="$NSYS_HOME/bin:$PATH"
    export LD_LIBRARY_PATH="$NSYS_HOME/lib64:$NSYS_HOME/lib:$LD_LIBRARY_PATH"
fi

# NCU setup (only if there is a folder ~/ncu)
export NCU_HOME="$HOME/ncu"
if [ -d "$NCU_HOME" ]; then
    export PATH="$NCU_HOME/bin:$PATH"
    export LD_LIBRARY_PATH="$NCU_HOME/lib64:$NCU_HOME/lib:$LD_LIBRARY_PATH"
fi
