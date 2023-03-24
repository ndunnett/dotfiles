#!/bin/zsh

source "$DOTFILES_HOME/scripts/helper_functions.zsh"

# skip if not on macOS
[[ $(uname) != "Darwin" ]] && echo "[dotfiles] not on macOS, skipping topic" && exit 1

# make init.zsh
init_file="$DOTFILES_HOME/macos/init.zsh"
init_temp="$DOTFILES_HOME/macos/init.zsh.temp"
touch "$init_temp"

# check brew installation
zsh "$DOTFILES_HOME/macos/brew.zsh" && changes_made="yes"

# check python installation
zsh "$DOTFILES_HOME/macos/python.zsh" && changes_made="yes"

# compare and compile main init.zsh
compare_replace_compile "$init_file" "$init_temp" && changes_made="yes"

# check for changes and exit
[[ -v changes_made ]] && exit 0 || exit 1
