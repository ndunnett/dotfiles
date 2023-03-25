#!/bin/zsh

echo "[dotfiles] checking brew installation"

# get path to homebrew bin
if [[ "$(uname)" == "Darwin" ]]; then
  [[ "$(uname -m)" == "arm64" ]] && HOMEBREW_PREFIX="/opt/homebrew" || HOMEBREW_PREFIX="/usr/local"
else
  HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi

# ensure brew is installed
if [[ ! -e "$HOMEBREW_PREFIX/bin/brew" ]]; then
  echo "[dotfiles] Homebrew not installed! starting Homebrew installer..."
  echo "[dotfiles] elevating to sudo..."
  sudo -v
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  changes_made="yes"
fi

# add brew paths to init file
echo "[dotfiles] adding Homebrew to path..."
eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
echo "export HOMEBREW_PREFIX=\"${HOMEBREW_PREFIX}\"" >> "$DOTFILES_HOME/macos/init.zsh.temp"
echo "export HOMEBREW_CELLAR=\"${HOMEBREW_CELLAR}\"" >> "$DOTFILES_HOME/macos/init.zsh.temp"
echo "export HOMEBREW_REPOSITORY=\"${HOMEBREW_REPOSITORY}\"" >> "$DOTFILES_HOME/macos/init.zsh.temp"
echo "export PATH=\"${HOMEBREW_PREFIX}/bin:${HOMEBREW_PREFIX}/sbin\${PATH+:\$PATH}\"" >> "$DOTFILES_HOME/macos/init.zsh.temp"
echo "export MANPATH=\"${HOMEBREW_PREFIX}/share/man\${MANPATH+:\$MANPATH}:\"" >> "$DOTFILES_HOME/macos/init.zsh.temp"
echo "export INFOPATH=\"${HOMEBREW_PREFIX}/share/info:\${INFOPATH:-}\"" >> "$DOTFILES_HOME/macos/init.zsh.temp"

# install bundle from Brewfile
echo "[dotfiles] installing Homebrew bundles..."
for brewfile in $DOTFILES_HOME/**/brew/Brewfile; do
  brew bundle install --file="$brewfile"
done

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
