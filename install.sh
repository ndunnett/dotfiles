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

# check depencies
dependencies="stow"
. $dotfiles_dir/scripts/dependencies.sh

# generate secret files from templates
. $dotfiles_dir/scripts/secrets.sh

# run stow script
. $dotfiles_dir/scripts/stow.sh
