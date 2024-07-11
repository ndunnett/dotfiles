#!/bin/sh

echo "[dotfiles] start installation"

# check that zsh is available
command -v zsh >/dev/null 2>&1 || { echo >&2 "zsh not found!"; exit 1; }

# clone dotfiles repo if we aren't in it
if [ -d ".git" ]; then
  DOTFILES_HOME=$(dirname -- "$(readlink -f -- "$0")")
else
  DOTFILES_HOME="$HOME/dotfiles"
  echo "[dotfiles] cloning dotfiles repo to $DOTFILES_HOME..."
  git clone -q --depth 1 --recursive --shallow-submodules https://github.com/ndunnett/dotfiles.git "$DOTFILES_HOME"
  cd "$DOTFILES_HOME" || (echo "[dotfiles] failed to cd into $DOTFILES_HOME" && exit 1)
  changes_made="yes"
fi

# insert DOTFILES_HOME into .zshenv file
zsh "$DOTFILES_HOME/scripts/insert_env.zsh" "DOTFILES_HOME" "$DOTFILES_HOME" && changes_made="yes"

# disable global compinit
zsh "$DOTFILES_HOME/scripts/insert_env.zsh" "skip_global_compinit" "1" && changes_made="yes"

# install Starship
if [ ! -x "$DOTFILES_HOME/bin/starship" ]; then
  wait
  echo "[dotfiles] installing Starship..."

  if [ -x "$(command -v curl)" ]; then
    download="curl -sS"
  elif [ -x "$(command -v wget)" ]; then
    download="wget -qO -"
  elif [ -x "$(command -v fetch)" ]; then
    download="fetch -qo -"
  fi

  if [ -n "$download" ]; then
    mkdir -p "$DOTFILES_HOME/bin"
    $download https://starship.rs/install.sh | sh -s -- -f -b "$DOTFILES_HOME/bin" 1>/dev/null &
    changes_made="yes"
  else
    echo "[dotfiles] failed to install, no http downloader available"
  fi
fi

# run install.zsh for zsh
if [ -d "$DOTFILES_HOME/zsh" ] && [ -e "$DOTFILES_HOME/zsh/install.zsh" ]; then
  echo "[dotfiles] installing zsh..."
  zsh "$DOTFILES_HOME/zsh/install.zsh" && changes_made="yes"
fi

# run install.zsh for remaining topics
for topic_dir in "$DOTFILES_HOME"/*; do
  if [ "$topic_dir" != "$DOTFILES_HOME/zsh" ] && [ -d "$topic_dir" ] && [ -e "$topic_dir/install.zsh" ]; then
    echo "[dotfiles] installing topic $(echo "$topic_dir" | sed "s|$DOTFILES_HOME/||g")..."
    zsh "$topic_dir/install.zsh" && changes_made="yes"
  fi
done

# check for changes
wait
if [ "$changes_made" ]; then
  echo "[dotfiles] finished installation, reload shell"
else
  echo "[dotfiles] finished installation, no changes made"
fi

exit 0
