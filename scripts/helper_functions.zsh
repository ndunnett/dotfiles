#!/bin/zsh

function repo_up_to_date() {
  # checking that latest local commit matches latest remote commit
  [[ "$(git -C $1 rev-parse HEAD)" == "$(git -C $1 log -1 --pretty=format:"%H" origin/HEAD)" ]] && return 1 || return 0
}

function compile_file() {
  # delete compiled file if it's older than the source then compile
  [[ "$1.zwc" -ot $1 ]] && rm -f "$1.zwc"
  [[ -e "$1.zwc" ]] && return 1 || (zcompile "$1" && return 0)
}

function files_differ() {
  # if files both exist, compare contents
  [[ ! -e "$1" || ! -e "$2" ]] && return 0
  cmp -s "$1" "$2" && return 1 || return 0
}

function compare_replace_compile() {
  # if file at $1 differs from file at $2, replace $1 with $2 and compile $1
  if files_differ "$1" "$2"; then
    rm -f "$1" && mv "$2" "$1"
    compile_file "$1"
    return 0
  else
    rm -f "$2"
    return 1
  fi
}
