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

# install Oh My Posh
if [ ! -x "$DOTFILES_HOME/bin/oh-my-posh" ]; then
  echo "[dotfiles] installing Oh My Posh..."
  mkdir -p "$DOTFILES_HOME/bin"
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$DOTFILES_HOME/bin"
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
