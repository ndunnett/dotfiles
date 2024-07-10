#!/bin/zsh

# zsh options
EDITOR="nano"
TIMEFMT=$'real\t%uE\nuser\t%uU\nsys\t%uS'
setopt HISTIGNOREDUPS
setopt HISTIGNORESPACE

# speeds up autosuggest
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# set terminal colour
TERM="xterm-256color"

# add common bin directories to path
new_paths=("$HOME/bin" "/usr/local/bin" "$HOME/.local/bin" "$DOTFILES_HOME/bin")
for new_path in $new_paths; do
  [[ ":$PATH:" != *":$new_path:"* ]] && PATH="${PATH}:$new_path"
done
