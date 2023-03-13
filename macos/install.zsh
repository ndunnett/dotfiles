#!/bin/zsh

# skip if not on macOS
[[ $(uname) != "Darwin" ]] && echo "[dotfiles] not on macOS, skipping topic" && exit 1

# check brew installation
zsh "$DOTFILES_HOME/macos/brew.zsh" && changes_made="yes"

# check for changes and exit
[[ -v changes_made ]] && exit 0 || exit 1
