plugins_home=$ZSH_HOME/plugins

function _dotfiles_benchmark() {
  if [[ ! -d $plugins_home/zsh-bench ]]; then
    git clone --depth 1 https://github.com/romkatv/zsh-bench $plugins_home/zsh-bench
  else
    git --git-dir="$plugins_home/zsh-bench/.git" pull
  fi

  zsh $plugins_home/zsh-bench/zsh-bench
}

function _dotfiles_reload_shell() {
  exec ${SHELL} -l
}

function _dotfiles_init_plugin() {
  # loop through plugins
  for plugin in $@; do
    plugin_dir=$plugins_home/$(echo ${plugin%/*})_$(basename $plugin)

    # download plugin repo
    if [[ ! -d $plugin_dir ]]; then
      git clone --depth 1 https://github.com/$plugin.git $plugin_dir
    fi

    # find zsh file for plugin and make symlink if it isn't init.zsh
    if [[ ! -e $plugin_dir/init.zsh ]]; then
      init_candidates=($plugin_dir/*.plugin.{z,}sh(N) $plugin_dir/*.{z,}sh{-theme,}(N))
      (( $#init_candidates )) || { echo >&2 "No init file found for $plugin." && continue }
      ln -sf ${init_candidates[1]} $plugin_dir/init.zsh
    fi
  done
}

function _dotfiles_update() {
  # loop through plugins
  for plugin in $dotfiles_plugins; do
    plugin_dir=$plugins_home/$(echo ${plugin%/*})_$(basename $plugin)

    # remove symlink to init.zsh if it exists
    if [[ -L $plugin_dir/init.zsh ]]; then
      rm $plugin_dir/init.zsh
    fi

    # pull plugin repo
    git --git-dir="$plugin_dir/.git" pull

    # reinitialise plugin
    _dotfiles_init_plugin $plugin
  done

  # pull dotfiles repo
  git --git-dir="$DOTFILES/.git" pull

  _dotfiles_reload_shell
}

function dotfiles() {
  while [ $# -gt 0 ]; do
    case "$1" in
      benchmark) _dotfiles_benchmark;;
      reload) _dotfiles_reload_shell;;
      update) _dotfiles_update;;
      *) echo "bad argument: $1";;
    esac
    shift
  done
}

# load plugins
for plugin in $dotfiles_plugins; do
  init_file=$plugins_home/$(echo ${plugin%/*})_$(basename $plugin)/init.zsh

  if [[ ! -e $init_file ]]; then
    _dotfiles_init_plugin $plugin
  fi

  source $init_file
done
