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

# Get IP addresses
alias ip_public="dig +short myip.opendns.com @resolver1.opendns.com"
alias ip_private="ipconfig getifaddr en0"

# Print each PATH entry on a separate line
alias path="echo ${PATH} | sed \"s|:|\\n|g\""
