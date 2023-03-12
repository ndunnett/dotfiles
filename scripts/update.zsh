#!/bin/zsh

echo "[dotfiles] checking for updates"

function repo_up_to_date() {
  [[ $(git -C $1 rev-parse HEAD) == $(git -C $1 ls-remote -q | grep HEAD | cut -f1) ]] && return 1 || return 0
}

source "$DOTFILES_HOME/zsh/plugin_repos.zsh"

for plugin in $plugin_repos; do
  # check plugins
  echo "[dotfiles] checking $plugin..."
  if [[ ! -d "$DOTFILES_HOME/zsh/plugins/$plugin" ]]; then
    echo "[dotfiles] plugin directory doesn't exist, cloning repo"
    git clone -q --depth 1 --recursive --shallow-submodules "https://github.com/$plugin.git" "$DOTFILES_HOME/zsh/plugins/$plugin"
    changes_made="yes"
  elif repo_up_to_date "$DOTFILES_HOME/zsh/plugins/$plugin"; then
    echo "[dotfiles] $plugin out of date, pulling repo"
    git -C "$DOTFILES_HOME/zsh/plugins/$plugin" pull -q
    changes_made="yes"
  fi
done

# check dotfiles repo
echo "[dotfiles] checking dotfiles repo..."
if repo_up_to_date "$DOTFILES_HOME"; then
  echo "[dotfiles] dotfiles out of date, pulling repo"
  git -C "$DOTFILES_HOME" pull -q
  changes_made="yes"
fi

# check for changes
if [[ -v changes_made ]]; then
  echo "[dotfiles] finished updating, recompile to apply changes"
  exit 1
else
  echo "[dotfiles] finished updating, no changes made"
  exit 0
fi
