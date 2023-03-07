#!/bin/sh

# check that zsh is available
command -v zsh >/dev/null 2>&1 || { echo >&2 "zsh not found!"; exit 1; }

# set default shell to zsh
zsh_path=$(command -v zsh)
test $SHELL != $zsh_path || sudo chsh -s $zsh_path

# link files
DOTFILES_HOME=$( dirname -- "$( readlink -f -- "$0"; )"; )
zsh $DOTFILES_HOME/scripts/link_files.zsh $DOTFILES_HOME
