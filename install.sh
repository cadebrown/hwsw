#!/bin/sh
# install.sh - single install script for my (Cade Brown) system setup
# NOTE: a lot of this was copied from: https://github.com/ohmyzsh/ohmyzsh/blob/master/tools/install.sh

# exit on error
set -e

# print commands as they are executed (for debugging)
# set -x

# Make sure important variables exist if not already defined
#
# $USER is defined by login(1) which is not always executed (e.g. containers)
# POSIX: https://pubs.opengroup.org/onlinepubs/009695299/utilities/id.html
USER=${USER:-$(id -u -n)}
# $HOME is defined at the time of login, but it could be unset. If it is unset,
# a tilde by itself (~) will not be expanded to the current user's home directory.
# POSIX: https://pubs.opengroup.org/onlinepubs/009696899/basedefs/xbd_chap08.html#tag_08_03
HOME="${HOME:-$(getent passwd $USER 2>/dev/null | cut -d: -f6)}"
# macOS does not have getent, but this works even if $HOME is unset
HOME="${HOME:-$(eval echo ~$USER)}"
# the default path to install this repository to, which might already exist
HWSW="${HWSW:-$HOME/hwsw}"

echo "--------------------------------"
echo "| install.sh - running ...     |"
echo "--------------------------------"
echo "USER=$USER"
echo "HOME=$HOME"
echo "HWSW=$HWSW"

# Default settings
REPO=${REPO:-cadebrown/hwsw}
echo "REPO=$REPO"
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
echo "REMOTE=$REMOTE"
BRANCH=${BRANCH:-main}
echo "BRANCH=$BRANCH"

echo ""

# # Other options
# CHSH=${CHSH:-yes}
# RUNZSH=${RUNZSH:-yes}
# KEEP_ZSHRC=${KEEP_ZSHRC:-no}
# OVERWRITE_CONFIRMATION=${OVERWRITE_CONFIRMATION:-yes}

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

user_can_sudo() {
  # Check if sudo is installed
  command_exists sudo || return 1
  # Termux can't run sudo, so we can detect it and exit the function early.
  case "$PREFIX" in
  *com.termux*) return 1 ;;
  esac
  # The following command has 3 parts:
  #
  # 1. Run `sudo` with `-v`. Does the following:
  #    • with privilege: asks for a password immediately.
  #    • without privilege: exits with error code 1 and prints the message:
  #      Sorry, user <username> may not run sudo on <hostname>
  #
  # 2. Pass `-n` to `sudo` to tell it to not ask for a password. If the
  #    password is not required, the command will finish with exit code 0.
  #    If one is required, sudo will exit with error code 1 and print the
  #    message:
  #    sudo: a password is required
  #
  # 3. Check for the words "may not run sudo" in the output to really tell
  #    whether the user has privileges or not. For that we have to make sure
  #    to run `sudo` in the default locale (with `LANG=`) so that the message
  #    stays consistent regardless of the user's locale.
  #
  ! LANG= sudo -n -v 2>&1 | grep -q "may not run sudo"
}

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

setup_hwsw_repo() {
  # Prevent the cloned repository from having insecure permissions. Failing to do
  # so causes compinit() calls to fail with "command not found: compdef" errors
  # for users with insecure umasks (e.g., "002", allowing group writability). Note
  # that this will be ignored under Cygwin by default, as Windows ACLs take
  # precedence over umasks except for filesystems mounted with option "noacl".
  umask g-w,o-w

  echo "--------------------------------"
  echo "| setting up hwsw repo ...     |"
  echo "--------------------------------"
  echo "HWSW=$HWSW"
  echo "REPO=$REPO"
  echo "REMOTE=$REMOTE"
  echo "BRANCH=$BRANCH"
  echo ""

  command_exists git || {
    echo "error: git is not installed"
    exit 1
  }

  ostype=$(uname)
  if [ -z "${ostype%CYGWIN*}" ] && git --version | grep -Eq 'msysgit|windows'; then
    echo "error: Windows/MSYS Git is not supported on Cygwin"
    echo "error: Make sure the Cygwin git package is installed and is first on the \$PATH"
    exit 1
  fi

  # git clone the repository if it doesn't exist
  if [ ! -e "$HWSW" ]; then
    # Manual clone with git config options to support git < v1.7.2
    git init --quiet "$HWSW" && cd "$HWSW" \
    && git config core.eol lf \
    && git config core.autocrlf false \
    && git config fsck.zeroPaddedFilemode ignore \
    && git config fetch.fsck.zeroPaddedFilemode ignore \
    && git config receive.fsck.zeroPaddedFilemode ignore \
    && git config hwsw.remote origin \
    && git config hwsw.branch "$BRANCH" \
    && git remote add origin "$REMOTE" \
    && git fetch --depth=1 origin \
    && git checkout -b "$BRANCH" "origin/$BRANCH" \
    && git submodule update --init --recursive || {
      [ ! -d "$HWSW" ] || {
        cd -
        rm -rf "$HWSW" 2>/dev/null
      }
      echo "error: git clone of hwsw repo failed"
      exit 1
    }

    # Exit installation directory
    cd -

  else
    echo "hwsw repo already exists, skipping clone..."
  fi

}

setup_hwsw_pkgs() {
  cd "$HWSW"

  echo "--------------------------------"
  echo "| setting up Homebrew ...      |"
  echo "--------------------------------"

  if [ "$(uname)" = "Darwin" ]; then
      echo "installing on a MacOS machine ..."

      # TODO: support a custom homebrew location? (for non-sudo access)
      if [ ! -e "/opt/homebrew" ]; then
          /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi

      eval "$(/opt/homebrew/bin/brew shellenv)"

      brew update && brew bundle install --file "$HWSW/homebrew/.Brewfile" --services --force && brew upgrade

  else
      # TODO: don't make this a hard dependency on Linux, use package managers?
      echo "installing on a $(uname) machine ..."

      # git clone homebrew if the file doesn't exist
      if [ ! -e "$HWSW/homebrew/.homebrew" ]; then
          git clone https://github.com/Homebrew/brew "$HWSW/homebrew/.homebrew"
      fi

      eval "$($HWSW/homebrew/.homebrew/bin/brew shellenv)"

      # on Linux, use a fix script
      $HWSW/tools/install-brewfile-linux.sh $HWSW/homebrew/.Brewfile

      # FIX: problems with perl and stow
      # TODO: fix version number?
      export PERLLIB="$HWSW/homebrew/.homebrew/Cellar/stow/2.4.1/home/linuxbrew/.linuxbrew/Cellar/perl/5.38.2_1/lib/perl5/site_perl/5.38"

  fi
  echo ""

  cd -

}

# install the actual repository in $HWSW
setup_hwsw_repo

# next, let's actually install the required packages
setup_hwsw_pkgs

# finally, install dotfiles to home directory
echo "--------------------------------"
echo "| installing dotfiles ...      |"
echo "--------------------------------"
echo "HWSW=$HWSW"
echo "HOME=$HOME"
echo ""

# create some default directories for config files, so stow doesn't link the entire folder to my dotfiles dir
# for example, ssh config is in ~/.ssh/config, but stow would link the entire ~/.ssh folder to my dotfiles dir (if it hasn't been created yet)
mkdir -p "$HOME/.ssh"
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.conan2it"

# # only on macos
# if [ "$(uname)" = "Darwin" ]; then

#   mkdir -p "$HOME/Library/Application Support/Alfred"

#   # in addition, move existing files to backups if they exist
#   if [ -e "$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences" ]; then
#       # check if it points to the correct directory
#       if [ "$(realpath "$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences")" != "$HWSW/alfred/Library/Application Support/Alfred/Alfred.alfredpreferences" ]; then
#           mv "$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences" "$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences.backup.$(date +%Y-%m-%d_%H-%M-%S)"
#       else
#           echo "Alfred preferences already point to the correct directory, skipping backup..."
#       fi
#   fi
# fi

echo "installing dotfiles ..."
stow -d "$HWSW" -t "$HOME" -S git ssh zsh neovim python rust homebrew aerospace linearmouse iterm2 --verbose

echo "--------------------------------"
echo "| installing config files ...  |"
echo "--------------------------------"
echo ""

if [ "$(uname)" = "Darwin" ]; then
  echo "installing iTerm2 preferences... (on MacOS)"

  # hide the dock
  defaults write com.apple.dock autohide -bool true; killall Dock

  # hide the menu bar
  defaults write NSGlobalDomain _HIHideMenuBar -bool true; killall Finder
  
  # Specify the preferences directory
  defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/.iterm2"

  # Tell iTerm2 to use the custom preferences in the directory
  defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

  # Tell iTerm2 to save preferences automatically
  defaults write com.googlecode.iterm2.plist "NoSyncNeverRemindPrefsChangesLostForFile_selection" -int 2
fi


echo "--------------------------------"
echo "| setting up Python ...        |"
echo "--------------------------------"

# set up Python virtual environment
echo "setting up Python virtual environment ..."
if [ ! -e "$HWSW/python/.venv" ]; then
    uv venv "$HWSW/python/.venv" --prompt uv --python 3.14 --relocatable --seed --clear
fi

echo "installing Python packages ..."
uv pip install -r "$HWSW/python/.venv.requirements.txt" --python "$HWSW/python/.venv"

echo "--------------------------------"
echo "| setting up Rust ...          |"
echo "--------------------------------"

# add Rust to the path
export PATH="$(brew --prefix rustup)/bin:$PATH"
# and installed Rust binaries
export PATH="$HOME/.cargo/bin:$PATH"

# set up the default Rust toolchain
rustup default nightly

while IFS= read -r line; do
  # Perform other operations with "$line" here
  # remove anything after and including '#' (comments)
  line=$(echo "$line" | sed 's/#.*//')
  if [ -n "$line" ]; then
    echo "installing Rust package: $line ..."
    cargo install --locked $line || echo "package install failed: $line"
  fi
done < "$HWSW/rust/.cargo.txt"

echo ""

