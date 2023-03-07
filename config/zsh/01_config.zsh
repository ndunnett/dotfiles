#!/bin/zsh

# zsh options
export EDITOR="nano"
export TIMEFMT=$'real\t%uE\nuser\t%uU\nsys\t%uS'
setopt HISTIGNOREDUPS
setopt HISTIGNORESPACE

# add common bin directories to path
append_path "$HOME/bin" "/usr/local/bin"

# add homebrew paths if on macOS
if [[ $KERNEL_NAME == "darwin" ]]; then
  case $(uname -m) in
    arm64) brew_prefix="/opt/homebrew";;
    *) brew_prefix="/usr/local";;
  esac

  append_path "$brew_prefix/bin" "$brew_prefix/sbin"
fi
