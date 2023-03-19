#!/bin/zsh

echo "[dotfiles] checking brew installation"

# ensure brew is installed
if [[ ! -e "/opt/homebrew/bin/brew" ]]; then
  echo "[dotfiles] brew not installed! starting brew installer..."
  echo "[dotfiles] elevating to sudo"
  sudo -v
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  changes_made="yes"
fi

# add brew paths to .zshenv
echo "[dotfiles] checking brew paths are in .zshenv"
brew_paths="$(/opt/homebrew/bin/brew shellenv)"
brew_paths_array=(${(@s:;:)${brew_paths:gs/export //}})
for brew_path in $brew_paths_array; do
  key=$(echo $brew_path | cut -f1 -d "=" | xargs)
  value=$(echo $brew_path | cut -f2 -d "=" | xargs)
  zsh "$DOTFILES_HOME/scripts/insert_env.zsh" "$key" "$value" && changes_made="yes"
done

# check for changes and exit
[[ -v changes_made ]] && exit 0 || exit 1
