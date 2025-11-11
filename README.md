# hwsw: My Hardware and Software Configuration

This repository details how I set up my computers, both with physical hardware used (with manuals, drivers, etc) and what software I use on top. The idea is to clone this repository on any new device, automate installation, and track upgrades.

## Setup

The easiest way is to run the setup script from `curl`/`wget`/`fetch`:

```shell
# if you have `curl` installed
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/cadebrown/hwsw/main/tools/install.sh)"

# if you have `wget` installed
$ sh -c "$(wget -O- https://raw.githubusercontent.com/cadebrown/hwsw/main/tools/install.sh)"

# if you have `fetch` installed
$ sh -c "$(fetch -o - https://raw.githubusercontent.com/cadebrown/hwsw/main/tools/install.sh)"
```

This script respects the following environment variables:

* `HWSW=$HOME/hwsw` - path to install this repository to, default is in your home directory
* `REPO=cadebrown/hwsw` - repository to clone, default is my own
* `REMOTE=https://github.com/${REPO}.git` - remote URL to clone, default is GitHub's
* `BRANCH=main` - branch to checkout, default is main

### Manual Setup Instructions

If the above is just too easy (or, doesn't work for a special case), you can manually run the process as:

```shell
# clone the repository to your home directory
$ git clone git@github.com:cadebrown/hwsw.git /path/to/hwsw && cd $_

# symbolically link it, if it is installed in a custom place
$ ln -sfr . ~/hwsw

# make sure all submodules are initialized
$ git submodule update --init --recursive

# run the installation script
# TODO: document the steps here...
$ ./tools/install.sh

# ensure Rust toolchain is installed, and I use the nightly version
$ rustup default nightly

```

## Homebrew Package Manager Configuration

I use [Homebrew](https://brew.sh/) as a package manager on Linux and MacOS, as it has a ton of common packages, and lots of instructions reference it. However, I also use [Homebrew Bundle and Brewfile](https://docs.brew.sh/Brew-Bundle-and-Brewfile) to make my installation reproducible and trackable.

* [Install without sudo](https://dgcs.brew.sh/Installation#untar-anywhere-unsupported)

First, install Homebrew:

```shell
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then, you can install, upgrade, and sync your Homebrew packages with:

```shell
# NOTE: --cleanup will REMOVE any packages not mentioned in Brewfile!
$ brew update && brew bundle install --services --cleanup && brew upgrade
```

Now, there are a few packages that Homebrew provides over the system defaults (like `zsh`). To ensure these are used, you can run:

```shell
$ echo $(brew --prefix)/bin/zsh | sudo tee -a /etc/shells | sudo chsh -s $(brew --prefix)/bin/zsh $USER
```

### Setup on MacOS

The automatic setup script will handle this for you.

### Setup on Linux

```shell
$ git clone https://github.com/Homebrew/brew $HWSW/homebrew/.homebrew
$ eval "$($HWSW/homebrew/.homebrew/bin/brew shellenv)"

# install Homebrew packages using a manual script method (required for some NFS errors on shared scratch space filesystems)
$ ./tools/install-brewfile-linux.sh $HWSW/homebrew/.Brewfile
# options for failures/debugging:--keep-tmp --debug --interactive

# this is a fix for the `stow` package, which is required for the dotfiles
$ export PERLLIB="$HWSW/homebrew/.homebrew/Cellar/stow/2.4.1/home/linuxbrew/.linuxbrew/Cellar/perl/5.38.2_1/lib/perl5/site_perl/5.38"
```

### Setup on Windows

Just follow the instructions for Linux, but use Windows Subsystem for Linux (WSL) instead of Linux.
