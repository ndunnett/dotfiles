#!/bin/zsh

# source topic init scripts
for file in $DOTFILES_HOME/*/init.zsh; do
  source $file
done

# source configuration scripts
for file in $DOTFILES_HOME/*/<0-10000>*.*; do
  source $file
done
