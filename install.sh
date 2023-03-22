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

# symlink all files ending in .linked
zsh "$DOTFILES_HOME/scripts/link_files.zsh" && changes_made="yes"

# run install.zsh for each topic
for topic_dir in "$DOTFILES_HOME"/*; do
  if [ -d "$topic_dir" ] && [ -e "$topic_dir/install.zsh" ]; then
    echo "[dotfiles] installing topic $(echo "$topic_dir" | sed "s|$DOTFILES_HOME/||g")..."
    zsh "$topic_dir/install.zsh" && changes_made="yes"
  fi
done

# check for changes
if [ "$changes_made" ]; then
  echo "[dotfiles] finished installation, reloading shell"
  exec zsh -l
else
  echo "[dotfiles] finished installation, no changes made"
fi

exit 0
