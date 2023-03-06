#!/bin/sh

# get directories and filepaths
DOTFILES_HOME=$( dirname -- "$( readlink -f -- "$0"; )"; )
ZSH_HOME=$DOTFILES_HOME/config/zsh
zshenv_file=$HOME/.zshenv
linked=$DOTFILES_HOME/.linked

# insert DOTFILES_HOME and ZSH_HOME into .zshenv file
if ! test -f $zshenv_file; then
  touch $zshenv_file
fi
for var in DOTFILES_HOME ZSH_HOME; do
  line="$var=${!var}"
  if ! grep -q $line $zshenv_file; then
    echo $line >> $zshenv_file
  fi
done

# set default shell to zsh
if ! test $SHELL = $(which zsh); then
  sudo chsh -s $(which zsh)
fi

# check if .linked exists
if test -f $linked; then
  # delete old symbolic links
  while read src dst; do
    if test -L $dst; then
      rm -f $dst
    fi
  done < $linked

  truncate -s 0 $linked
else
  touch $linked
fi

# populate .linked
for src in $(find $DOTFILES_HOME/linked -type f); do
  dst=$(echo $src | sed "s|$DOTFILES_HOME/linked|$HOME|g")
  echo "$src $dst" >> $linked
done

# distribute linked files
while read src dst; do
  # delete existing symlink
  if test -L $dst; then
    rm -f $dst
  fi

  # backup existing file
  if test -e $dst; then
    mv $dst $dst\.old
  fi

  # create new symlink
  ln -sf $src $dst
done < $linked
