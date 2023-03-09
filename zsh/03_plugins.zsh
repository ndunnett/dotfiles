#!/bin/zsh

# load Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# define plugins to be loaded
export dotfiles_plugins=(
  romkatv/powerlevel10k
  zimfw/completion
  zimfw/ssh
  zdharma/fast-syntax-highlighting
  zsh-users/zsh-autosuggestions
)

# load plugins
dotfiles load_plugins
