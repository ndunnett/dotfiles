#!/bin/zsh

# load functions
[[ -e "$ZSH_HOME/functions/init.zsh" ]] || (source $ZSH_HOME/functions/dotfiles/_dotfiles_init_functions && _dotfiles_init_functions)
source "$ZSH_HOME/functions/init.zsh"

# source configuration scripts
for file in $ZSH_HOME/<0-10000>*.*; do
  source $file
done
