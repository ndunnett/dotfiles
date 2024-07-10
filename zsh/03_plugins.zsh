#!/bin/zsh

# load Oh My Posh
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config "$DOTFILES_HOME/zsh/omp.yaml")"
fi

# load plugins
dotfiles load_plugins
