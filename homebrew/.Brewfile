# .Brewfile - my Homebrew packages for declarative system configuration

# ZSH is my default shell
brew "zsh"

# Fish is a nice shell I'm trying out
brew "fish"

# Nushell is an interesting shell written in Rust (object oriented)
brew "nushell"

# use Bash from Homebrew, since it's newer than the system default
brew "bash"

# Neovim is my default text editor
brew "neovim"

# Tmux for managing multiple terminal sessions
brew "tmux"

# Python environment manager
# NOTE: I use ~/.venv for my user-default Python environment (via `uv`)
brew "uv"

# Rust programming language, this manages toolchain
# this will set the default nightly toolchain:
# $ rustup default nightly
brew "rustup", postinstall: "${HOMEBREW_PREFIX}/bin/rustup default nightly"

# Git for version control
# NOTE: use more up-to-date version from Homebrew
brew "git"

# Git delta for better git diffs, used in my .gitconfig aliases
brew "git-delta"

# GitHub CLI for managing GitHub repositories
brew "gh"

# Lynx for a text-based web browser
# I don't use this much, but it's nice to play around with
brew "lynx"

# Collection of useful CLI utilities: https://joeyh.name/code/moreutils/
brew "moreutils"

# JSON processor for CLI
brew "jq"

# FastFetch for system information
brew "fastfetch"

# Disk usage analyzer, interactive CLI tool
brew "ncdu"

# Ripgrep for searching files, like `grep` but faster and better overall usability
brew "ripgrep"

# use more up-to-date version from Homebrew, for paging output
brew "less"

# Hierarchical directory listing tool, like `ls` but better formatted
brew "tree"

# web downloaders, use all so any scripts work
brew "wget"
brew "curl"
brew "fetch"

# Tool to count lines of code
brew "cloc"

# 'bat' for better `cat` output, with syntax highlighting and more
# NOTE: I use an alias for `cat` in my .zshrc to use `bat` instead, so it's required
brew "bat"
brew "bat-extras"

# ImageMagick for CLI image processing
brew "imagemagick"

# readline wrapper, for interactive tools that don't support readline
brew "rlwrap"

# Fuzzy finder, for finding files and directories
brew "fzf"

# System monitoring tools
brew "glances"
brew "bottom"
brew "btop"
brew "htop"

# Stow is used for managing dotfiles, and home directory structure
# TODO: find alternative?
brew "stow"

# OpenSSH is required for SSH
brew "openssh"

# Includes LLVM and Clang, for C/C++ development as well as compiler development
brew "llvm"

# C/C++ build tools, used for building software
brew "cmake"
brew "ninja"
brew "meson"

# math libraries
brew "fftw"

# LLVM v20 is required for llvmlite (Python package)
# brew "llvm@20"
brew "zstd"
brew "ffmpeg"

# for Java...
brew "openjdk"

# mpv for video playback
brew "mpv"

# Docker for containerization
brew "docker"

# QEMU for running virtual machines
brew "qemu"

# balenaEtcher for bootable driver creation
cask "balenaetcher"

# UTM for running virtual machines (QEMU wrapper UI)
cask "utm"

# Alfred for productivity, it's a better Spotlight/Launchpad replacement
cask "alfred"

# Font: JetBrains Mono
cask "font-jetbrains-mono"

# iTerm2 for terminal
cask "iterm2"

# Warp for terminal
cask "warp"

# GIMP for general image editing (bitmaps)
cask "gimp"

# Inkscape for vector graphics editing
cask "inkscape"

# web browser
cask "firefox"

# LaTeX for MacOS
cask "mactex"

# LibreOffice for MacOS
cask "libreoffice"

# Spotify for audio streaming
cask "spotify"

# Aerospace for terminal
cask "nikitabobko/tap/aerospace"

# LinearMouse for fixing acceleration on MacOS
cask "linearmouse"

# Discord for messaging
#cask "discord"

# Slack for messaging
#cask "slack"

# best archive manager, hands down
cask "the-unarchiver"

# Blender for 3D modeling
cask "blender"

# OBS for video recording
cask "obs"

# VLC for video playback
cask "vlc"

# .NET SDK for .NET development (C#/F#/...)
cask "dotnet-sdk"

# Steam for gaming
cask "steam"

# Prism Launcher for Minecraft
cask "prismlauncher"

# experiments
# cask "elmedia-player"

# Ghostty for terminal
# cask "ghostty"

# Tabby for terminal
# cask "tabby"
