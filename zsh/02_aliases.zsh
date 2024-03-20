#!/bin/zsh

# Easier navigation: .., ..., ...., ....., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~"
alias -- -="cd -"

# Use coloured grep and ls output
alias ls="ls --color=auto"
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

# Print each PATH entry on a separate line
alias path="echo ${PATH} | sed \"s|:|\\n|g\""

# Print list of largest files and directories within pwd
alias ducks="while read -r line; do du -sh \"\$line\"; done < <(ls -1A) | sort -rh | head"
