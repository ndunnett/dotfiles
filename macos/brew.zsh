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

# add brew paths to init file
echo "[dotfiles] adding Homebrew to path..."
brew_paths="$(/opt/homebrew/bin/brew shellenv)"
echo "$brew_paths" >> "$DOTFILES_HOME/macos/init.zsh.temp"
eval "$brew_paths"

# install bundle from Brewfile
echo "[dotfiles] installing Homebrew bundle..."
brew bundle install --file="$DOTFILES_HOME/macos/Brewfile"

# add brew zsh to acceptable shells
echo "[dotfiles] adding Homebrew zsh to acceptable shells..."
brew_zsh="$HOMEBREW_PREFIX/bin/zsh"
if [[ ! $(cat /etc/shells | grep "$brew_zsh") ]]; then
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
