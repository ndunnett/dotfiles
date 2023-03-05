#!/bin/sh

# TODO: make script idempotent (check stow status before changing anything)

# default parameters
dotfiles_role=default

# get parameters from arguments
if [ $1 ]; then
  dotfiles_role=$1
fi

# get dotfiles directory
dotfiles_dir=$( dirname -- "$( readlink -f -- "$0"; )"; )
target_dir=$HOME
stowed=$dotfiles_dir/.stowed

# set default shell to zsh
if ! [ $SHELL = $(which zsh) ]; then
  sudo chsh -s $(which zsh)
fi

# check depencies
dependencies="stow"
. $dotfiles_dir/scripts/dependencies.sh

# run stow script
. $dotfiles_dir/scripts/stow.sh

# restart shell into zsh
exec zsh -l
