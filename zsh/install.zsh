#!/bin/zsh

function repo_up_to_date() {
  # checking that latest local commit matches latest remote commit
  [[ $(git -C $1 rev-parse HEAD) == $(git -C $1 ls-remote -q | grep HEAD | cut -f1) ]] && return 1 || return 0
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

function update() {
  echo "[dotfiles] start checking for updates"
  source "$DOTFILES_HOME/zsh/plugin_repos.zsh"

  for plugin in $plugin_repos; do
    # check plugins
    echo "[dotfiles] checking $plugin..."
    if [[ ! -d "$DOTFILES_HOME/zsh/plugins/$plugin" ]]; then
      echo "[dotfiles] plugin directory doesn't exist, cloning repo"
      git clone -q --depth 1 --recursive --shallow-submodules "https://github.com/$plugin.git" "$DOTFILES_HOME/zsh/plugins/$plugin"
      update_changes_made="yes"
    elif repo_up_to_date "$DOTFILES_HOME/zsh/plugins/$plugin"; then
      echo "[dotfiles] $plugin out of date, pulling repo"
      git -C "$DOTFILES_HOME/zsh/plugins/$plugin" pull -q
      update_changes_made="yes"
    fi
  done

  # check dotfiles repo
  echo "[dotfiles] checking dotfiles repo..."
  if repo_up_to_date "$DOTFILES_HOME"; then
    echo "[dotfiles] dotfiles out of date, pulling repo"
    git -C "$DOTFILES_HOME" pull -q
    update_changes_made="yes"
  fi

  # check for changes
  if [[ -v update_changes_made ]]; then
    echo "[dotfiles] finished updating, recompile to apply changes"
    return 0
  else
    echo "[dotfiles] finished updating, no changes made"
    return 1
  fi
}

function compile_all() {
  echo "[dotfiles] start compiling functions and plugins"

  # make functions init.zsh
  func_init_file="$DOTFILES_HOME/zsh/functions/init.zsh"
  func_init_temp="$DOTFILES_HOME/zsh/functions/init.zsh.temp"
  touch "$func_init_temp"

  # in init.zsh: add function directories to fpath
  echo "fpath=($(echo $(find "$DOTFILES_HOME/zsh/functions" -type d)) \"\${fpath[@]}\")" >> "$func_init_temp"

  for function_file in $(find "$DOTFILES_HOME/zsh/functions" -type f ! -name "*.*"); do
    # in init.zsh: autoload function
    echo "autoload -Uz $function_file" >> "$func_init_temp"

    # compile function
    echo "[dotfiles] compiling $(echo $function_file | sed "s|$DOTFILES_HOME/zsh/functions/||g")..."
    compile_file "$function_file" && compile_changes_made="yes"
  done

  # compare and compile functions init.zsh
  if files_differ "$func_init_file" "$func_init_temp"; then
    rm -f "$func_init_file" && mv "$func_init_temp" "$func_init_file"
    compile_file "$func_init_file"
    compile_changes_made="yes"
  else
    rm -f "$func_init_temp"
    compile_file "$func_init_file" && compile_changes_made="yes"
  fi

  # make plugins init.zsh
  plugin_init_file="$DOTFILES_HOME/zsh/plugins/init.zsh"
  plugin_init_temp="$DOTFILES_HOME/zsh/plugins/init.zsh.temp"
  touch "$plugin_init_temp"

  source "$DOTFILES_HOME/zsh/plugin_repos.zsh"
  for plugin in $plugin_repos; do
    # find zsh file for plugin
    init_candidates=($DOTFILES_HOME/zsh/plugins/$plugin/*{.plugin,}.{zsh-theme,zsh,sh}(N))
    [[ -n ${init_candidates} ]] || { echo >&2 "[dotfiles] no init file found for $plugin!" && continue }

    # in init.zsh: source plugin
    echo "source ${init_candidates[1]}" >> "$plugin_init_temp"

    # compile plugin files
    echo "[dotfiles] compiling $plugin..."
    for plugin_file in $DOTFILES_HOME/zsh/plugins/**/*.{sh,zsh,zsh-theme}; do
      compile_file "$plugin_file" && compile_changes_made="yes"
    done
  done

  # compare and compile plugins init.zsh
  if files_differ "$plugin_init_file" "$plugin_init_temp"; then
    rm -f "$plugin_init_file" && mv "$plugin_init_temp" "$plugin_init_file"
    compile_file "$plugin_init_file"
    compile_changes_made="yes"
  else
    rm -f "$plugin_init_temp"
    compile_file "$plugin_init_file" && compile_changes_made="yes"
  fi

  # check for changes
  if [[ -v compile_changes_made ]]; then
    echo "[dotfiles] finished compiling, reload to apply changes"
    return 0
  else
    echo "[dotfiles] finished compiling, no changes made"
    return 1
  fi
}

# handle arguments
if [ $# -gt 0 ]; then
  while [ $# -gt 0 ]; do
    case "$1" in
      (--update)
        update && exit 0 || exit 1
      ;;

      (--compile)
        compile_all && exit 0 || exit 1
      ;;

      (*)
        echo "[dotfiles] bad argument: $1"
      ;;
    esac
    shift
  done
else
  # run update and recompile if no args
  update && changes_made="yes"
  compile_all && changes_made="yes"
  [[ -v changes_made ]] && exit 0 || exit 1
fi
