#!/bin/zsh

source "$DOTFILES_HOME/scripts/helper_functions.zsh"

function update() {
  echo "[dotfiles] start checking for updates"
  source "$DOTFILES_HOME/zsh/plugin_repos.zsh"

  for plugin in $plugin_repos; do
    # check plugins
    echo "[dotfiles] checking $plugin..."
    if [[ ! -d "$DOTFILES_HOME/zsh/plugins/$plugin" ]]; then
      echo "[dotfiles] cloning $plugin repo..."
      git clone -q --depth 1 --recursive --shallow-submodules "https://github.com/$plugin.git" "$DOTFILES_HOME/zsh/plugins/$plugin"
      update_changes_made="yes"
    elif repo_up_to_date "$DOTFILES_HOME/zsh/plugins/$plugin"; then
      echo "[dotfiles] pulling $plugin repo..."
      git -C "$DOTFILES_HOME/zsh/plugins/$plugin" pull -q
      update_changes_made="yes"
    fi
  done

  # check dotfiles repo
  echo "[dotfiles] checking dotfiles repo..."
  if repo_up_to_date "$DOTFILES_HOME"; then
    echo "[dotfiles] pulling dotfiles repo..."
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

  # make main init.zsh
  main_init_file="$DOTFILES_HOME/zsh/init.zsh"
  main_init_temp="$DOTFILES_HOME/zsh/init.zsh.temp"
  touch "$main_init_temp"

  # in init.zsh: add function directories to fpath
  echo "fpath=($(echo $(find "$DOTFILES_HOME/zsh/functions" -type d)) \"\${fpath[@]}\")" >> "$main_init_temp"

  for function_file in $(find "$DOTFILES_HOME/zsh/functions" -type f ! -name "*.*"); do
    # in init.zsh: autoload function
    echo "autoload -Uz $function_file" >> "$main_init_temp"

    # compile function
    echo "[dotfiles] compiling $(echo $function_file | sed "s|$DOTFILES_HOME/zsh/functions/||g")..."
    compile_file "$function_file" && compile_changes_made="yes"
  done

  # compare and compile main init.zsh
  compare_replace_compile "$main_init_file" "$main_init_temp" && compile_changes_made="yes"

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
  compare_replace_compile "$plugin_init_file" "$plugin_init_temp" && compile_changes_made="yes"

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
        update
      ;;

      (--compile)
        compile_all
      ;;

      (*)
        echo "[dotfiles] bad argument: $1" && exit 1
      ;;
    esac
    shift
  done
else
  # run update and recompile if no args
  # update && changes_made="yes"
  compile_all && changes_made="yes"
  [[ -v changes_made ]] && exit 0 || exit 1
fi
