#!/bin/zsh

# load functions
[[ -e "$ZSH_HOME/functions/init.zsh" ]] || dotfiles update
source "$ZSH_HOME/functions/init.zsh"

# source configuration scripts
for file in $ZSH_HOME/<0-100>*.*; do
  source $file
done
