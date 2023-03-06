#!/bin/sh

# get dotfiles directory
DOTFILES_HOME=$( dirname -- "$( readlink -f -- "$0"; )"; )
ZSH_HOME=$DOTFILES_HOME/config/zsh

# save to env file
zshenv_file=$HOME/.zshenv
if ! test -f $zshenv_file; then
  touch $zshenv_file
fi
if ! grep -q DOTFILES_HOME $zshenv_file; then
  echo "DOTFILES_HOME=$DOTFILES_HOME" >> $zshenv_file
fi
if ! grep -q ZSH_HOME $zshenv_file; then
  echo "ZSH_HOME=$ZSH_HOME" >> $zshenv_file
fi

# set default shell to zsh
if ! test $SHELL = $(which zsh); then
  sudo chsh -s $(which zsh)
  echo test
fi

# check if .linked exists
linked=$DOTFILES_HOME/.linked
if test -f $linked; then
  # delete symbolic links
  while read src dst; do
    if test -L $dst; then
      rm -f $dst
    fi
  done < $linked

  # clear .linked
  truncate -s 0 $linked
else
  # create .linked
  touch $linked
fi

# populate .linked
for src in $(find $DOTFILES_HOME/linked -type f); do
  dst=$(echo $src | sed "s|$DOTFILES_HOME/linked|$HOME|g")
  echo "$src $dst" >> $linked
done

# delete existing files and create new symlink
while read src dst; do
  if test -e $dst; then
    mv $dst $dst\.old
  fi
  ln -sf $src $dst
done < $linked
