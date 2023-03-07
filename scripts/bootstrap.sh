#!/bin/sh

git clone --depth 1 https://github.com/ndunnett/dotfiles.git "$HOME/dotfiles" && sh "$HOME/dotfiles/install.sh"
