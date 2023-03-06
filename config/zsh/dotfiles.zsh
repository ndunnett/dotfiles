#!/bin/zsh

plugins_home=$ZSH_HOME/plugins

function _dotfiles_benchmark() {
  # download zsh-bench
  if [[ ! -d $plugins_home/zsh-bench ]]; then
    git clone --depth 1 https://github.com/romkatv/zsh-bench $plugins_home/zsh-bench
  else
    git -C $plugins_home/zsh-bench pull
  fi

  # run zsh-bench
  zsh $plugins_home/zsh-bench/zsh-bench
}

function _dotfiles_reload_shell() {
  exec zsh -l
}

function _dotfiles_update() {
  # delete compiled files
  for file in $(find $DOTFILES_HOME/config/zsh -type f -regex ".*\.zwc"); do
    rm -f $file
  done

  for plugin in $dotfiles_plugins; do
    plugin_dir=$plugins_home/$(echo ${plugin%/*})_$(basename $plugin)

    # remove symlink to init.zsh if it exists
    if [[ -L $plugin_dir/init.zsh ]]; then
      rm $plugin_dir/init.zsh
    fi

    # pull/download plugin repo
    if [[ ! -d $plugin_dir ]]; then
      git clone --depth 1 https://github.com/$plugin.git $plugin_dir
    else
      git -C $plugin_dir pull
    fi

    # find zsh file for plugin and make symlink if it isn't init.zsh
    if [[ ! -e $plugin_dir/init.zsh ]]; then
      init_candidates=($plugin_dir/*.plugin.{z,}sh(N) $plugin_dir/*.{z,}sh{-theme,}(N))
      (( $#init_candidates )) || { echo >&2 "No init file found for $plugin." && continue }
      ln -sf ${init_candidates[1]} $plugin_dir/init.zsh
    fi
  done

  # pull dotfiles repo
  git -C $DOTFILES_HOME pull

  # recompile files
  for file in $(find $DOTFILES_HOME/config/zsh -type f -regex ".*\.zsh"); do
    zcompile -R -- $file.zwc $file
  done

  _dotfiles_reload_shell
}

function _dotfiles_help() {
  echo "Valid usage: dotfiles [ reload | update | benchmark ]"
  echo
  echo "reload: reloads shell with \"exec zsh -l\""
  echo "update: runs \"git pull\" for each plugin repo and the dotfiles repo, recompiles, reloads shell"
  echo "benchmark: runs benchmark using zsh-bench"
}

function dotfiles() {
  while [ $# -gt 0 ]; do
    case "$1" in
      benchmark) _dotfiles_benchmark;;
      reload) _dotfiles_reload_shell;;
      update) _dotfiles_update;;
      help) _dotfiles_help;;
      *) echo "bad argument: $1" && echo && _dotfiles_help;;
    esac
    shift
  done
}

# load plugins
for plugin in $dotfiles_plugins; do
  plugin_dir=$plugins_home/$(echo ${plugin%/*})_$(basename $plugin)
  init_file=$plugin_dir/init.zsh
  fpath+=$plugin_dir

  if [[ ! -e $init_file ]]; then
    _dotfiles_update
  fi

  source $init_file
done
