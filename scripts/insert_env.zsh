#!/bin/zsh

# define variables
zshenv="$HOME/.zshenv"
key=$1
value=$2

# define line to be inserted
new_line="$key=$value"

# if .zshenv doesn't exist, create it and insert new variable
if [[ ! -e $zshenv ]]; then
  touch $zshenv
  echo "$new_line" >> $zshenv
  changes_made="yes"

# check if line is already in .zshenv
elif [[ $(grep "$new_line" $zshenv) == "" ]]; then
  # if this is a path definition, don't overwrite
  if [[ "$key" == "path" || "$key" == "PATH" || "$key" == "MANPATH" || "$key" == "INFOPATH" ]]; then
    echo "$new_line" >> $zshenv
  else
    # check if variable is already defined and overwrite it, otherwise insert new variable
    old_line=$(grep "$key=" $zshenv)
    [[ "$old_line" == "" ]] && echo "$new_line" >> $zshenv || sed -i "" -e "s|$old_line|$new_line|g" $zshenv
  fi
  changes_made="yes"
fi

# check for changes
if [[ -v changes_made ]]; then
  echo "[dotfiles] defined $new_line in .zshenv"
  exit 0
else
  echo "[dotfiles] $new_line already defined in .zshenv"
  exit 1
fi
