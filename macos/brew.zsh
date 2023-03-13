#!/bin/zsh

echo "[dotfiles] checking brew installation"

# manually load brew paths
brew_paths="$(/opt/homebrew/bin/brew shellenv)"
eval $brew_paths

# run brew installer in non-interactive mode
if ! command -v brew >/dev/null 2>&1; then
  echo "[dotfiles] brew not installed! starting brew installer..."
  sudo -v
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  changes_made="yes"
fi

# add brew paths to .zshenv
echo "[dotfiles] checking brew paths are in .zshenv"
brew_paths_array=(${(@s:;:)${brew_paths:gs/export //}})
for brew_path in $brew_paths_array; do
  key=$(echo $brew_path | cut -f1 -d "=" | xargs)
  value=$(echo $brew_path | cut -f2 -d "=" | xargs)
  zsh "$DOTFILES_HOME/scripts/insert_env.zsh" "$key" "$value" && changes_made="yes"
done

# check for changes and exit
[[ -v changes_made ]] && exit 0 || exit 1
