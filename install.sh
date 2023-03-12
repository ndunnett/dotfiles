#!/bin/sh

# check that zsh is available
command -v zsh >/dev/null 2>&1 || { echo >&2 "zsh not found!"; exit 1; }

# set default shell to zsh
zsh_path=$(command -v zsh)
[[ "$SHELL" == "$zsh_path" ]] || chsh -s "$zsh_path"

# clone dotfiles repo if we aren't in it
if [[ -d ".git" ]]; then
  DOTFILES_HOME=$( dirname -- "$( readlink -f -- "$0"; )"; )
else
  DOTFILES_HOME="$HOME/dotfiles"
  git clone --depth 1 https://github.com/ndunnett/dotfiles.git "$DOTFILES_HOME"
  cd "$DOTFILES_HOME"
fi

# insert DOTFILES_HOME into .zshenv file
zshenv="$HOME/.zshenv"
new_line="DOTFILES_HOME=$DOTFILES_HOME"
if ! [[ -e $zshenv ]]; then
  touch $zshenv && echo $new_line >> $zshenv
elif [[ $(grep $new_line $zshenv) == "" ]]; then
  old_line=$(grep "DOTFILES_HOME=" $zshenv)
  [[ $old_line == "" ]] && echo $new_line >> $zshenv || sed -i "" -e "s|$old_line|$new_line|g" $zshenv
fi

# link files, reload shell
zsh "$DOTFILES_HOME/scripts/update.zsh"
zsh "$DOTFILES_HOME/scripts/compile.zsh"
zsh "$DOTFILES_HOME/scripts/link_files.zsh"
exec zsh -l
