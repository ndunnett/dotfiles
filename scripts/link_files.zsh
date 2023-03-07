#!/bin/zsh

# get directories and filepaths
DOTFILES_HOME=$1
ZSH_HOME=$DOTFILES_HOME/config/zsh
zshenv_file=$HOME/.zshenv
linked_file=$DOTFILES_HOME/.linked

# insert DOTFILES_HOME and ZSH_HOME into .zshenv file
[[ -e $zshenv_file ]] || touch $zshenv_file
for var in DOTFILES_HOME ZSH_HOME; do
  line="$var=$(eval "echo \$$var")"
  grep $line $zshenv_file >/dev/null || echo $line >> $zshenv_file
done

# check if .linked exists, delete existing symbolic linkes
if [[ -e $linked_file ]]; then
  while read src dst; do
    [[ -L $dst ]] && rm -f $dst
  done < $linked_file
  truncate -s 0 $linked_file
else
  touch $linked_file
fi

# populate .linked
for src in $(find $DOTFILES_HOME/linked -type f); do
  dst=$(echo $src | sed "s|$DOTFILES_HOME/linked|$HOME|g")
  echo "$src $dst" >> $linked_file
done

# for each linked file delete existing symlink, backup existing file, create new symlink
while read src dst; do
  [[ -L $dst ]] && rm -f $dst
  [[ -e $dst ]] && mv $dst $dst\.old
  ln -sf $src $dst
done < $linked_file
