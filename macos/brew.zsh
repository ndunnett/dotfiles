#!/bin/zsh

echo "[dotfiles] checking brew installation"

# ensure brew is installed
if [[ ! -e "/opt/homebrew/bin/brew" ]]; then
  echo "[dotfiles] Homebrew not installed! starting Homebrew installer..."
  echo "[dotfiles] elevating to sudo..."
  sudo -v
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  changes_made="yes"
fi

# add brew paths to .zshenv
echo "[dotfiles] checking Homebrew paths are in .zshenv..."
brew_paths="$(/opt/homebrew/bin/brew shellenv)"
brew_paths_array=(${(@s:;:)${brew_paths:gs/export //}})
for brew_path in $brew_paths_array; do
  key=$(echo $brew_path | cut -f1 -d "=" | xargs)
  value=$(echo $brew_path | cut -f2 -d "=" | xargs)
  zsh "$DOTFILES_HOME/scripts/insert_env.zsh" "$key" "$value" && changes_made="yes"
done

# install bundle from Brewfile
echo "[dotfiles] installing Homebrew bundle..."
brew bundle install --file="$DOTFILES_HOME/macos/Brewfile"

# add brew zsh to acceptable shells
echo "[dotfiles] adding Homebrew zsh to acceptable shells..."
brew_zsh="/opt/homebrew/bin/zsh"
if [[ ! $(cat /etc/shells | grep -q "$brew_zsh") ]]; then
  echo "$brew_zsh" | sudo tee -a /etc/shells
  changes_made="yes"
fi

# set shell to brew zsh
echo "[dotfiles] setting shell to Homebrew zsh..."
if [[ "$SHELL" != "$brew_zsh" ]]; then
  chsh -s $brew_zsh
  changes_made="yes"
fi

# check for changes and exit
[[ -v changes_made ]] && exit 0 || exit 1
