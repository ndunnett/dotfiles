#!/bin/zsh

plugins_home=$ZSH_HOME/plugins

function _dotfiles_benchmark() {
  # download zsh-bench
  if [[ -d $plugins_home/zsh-bench ]]; then
    git -C $plugins_home/zsh-bench pull
  else
    git clone --depth 1 https://github.com/romkatv/zsh-bench $plugins_home/zsh-bench
  fi

  # run zsh-bench
  zsh $plugins_home/zsh-bench/zsh-bench
}

function _dotfiles_reload_shell() {
  exec zsh -l
}

function _dotfiles_compile() {
  for file in $(find $DOTFILES_HOME/config/zsh -type f -name "*.zsh"); do
    [[ $file.zwc -ot $file ]] && rm -f $file.zwc
    [[ -e $file.zwc ]] || zcompile -R -- $file.zwc $file
  done
}

function _dotfiles_update() {
  for plugin in $dotfiles_plugins; do
    plugin_dir=$plugins_home/$plugin

    # remove symlink to init.zsh if it exists
    [[ -L $plugin_dir/init.zsh ]] && rm $plugin_dir/init.zsh

    # pull/download plugin repo
    if [[ -d $plugin_dir ]]; then
      git -C $plugin_dir pull
    else
      git clone --depth 1 https://github.com/$plugin.git $plugin_dir
    fi

    # find zsh file for plugin and make symlink if it isn't init.zsh
    if [[ ! -e $plugin_dir/init.zsh ]]; then
      init_candidates=($plugin_dir/*.plugin.{z,}sh(N) $plugin_dir/*.{z,}sh{-theme,}(N))
      (( $#init_candidates )) || { echo >&2 "no init file found for $plugin!" && continue }
      ln -sf ${init_candidates[1]} $plugin_dir/init.zsh
    fi
  done

  # pull dotfiles repo
  git -C $DOTFILES_HOME pull

  # rebuild plugins/init.zsh
  if [[ -e $plugin_dir/init.zsh ]]; then
    truncate -s 0 "$plugins_home/init.zsh"
  else
    touch "$plugins_home/init.zsh"
  fi
  for plugin in $dotfiles_plugins; do
    echo "source $plugins_home/$plugin/init.zsh" >> $plugins_home/init.zsh
  done

  _dotfiles_compile
  _dotfiles_reload_shell
}

function _dotfiles_help() {
  echo "Valid usage: dotfiles [ reload | update | benchmark ]"
  echo
  echo "reload: reloads shell with \"exec zsh -l\""
  echo "compile: recompiles all *.zsh files under config/zsh"
  echo "update: runs \"git pull\" for each plugin repo and the dotfiles repo, recompiles, reloads shell"
  echo "benchmark: runs benchmark using zsh-bench"
}

function dotfiles() {
  while [ $# -gt 0 ]; do
    case "$1" in
      benchmark) _dotfiles_benchmark;;
      reload) _dotfiles_reload_shell;;
      compile) _dotfiles_compile;;
      update) _dotfiles_update;;
      help) _dotfiles_help;;
      *) echo "bad argument: $1" && echo && _dotfiles_help;;
    esac
    shift
  done
}

# load plugins
[[ -e $plugins_home/init.zsh ]] || _dotfiles_update
source $plugins_home/init.zsh
