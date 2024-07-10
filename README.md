# <div align="center">ndunnett/dotfiles</div>

<div align="center">Dotfiles without a framework. Files are organized by topic, with the `zsh` topic serving as the core.</div>

### Symbolic Linking

Configuration files are linked automatically using `ln`. Files within any topic directory ending in `.linked` will be symbolically linked from `$HOME` in the same file structure. For example, `topic/foo/bar.zsh.linked` will be symbolically linked at `$HOME/foo/bar.zsh`. If there are existing files that conflict with the linked files, they will be renamed with a `.old` suffix, e.g., `$HOME/foo/bar.zsh.old`.

### Installation Scripts

Any script named `install.zsh` within the base directory of each topic will run during installation. Use these scripts to install applications, set environment variables, write initialization scripts, etc.

### Initialization

Within each topic directory, any file named `init.zsh` (e.g., `topic/init.zsh`) will be sourced first. Then, all files prefixed with a number (e.g., `topic/01_config.zsh`) will be sourced in alphabetical order within `$HOME/.zshrc`. Use these files to implement custom configurations that need to be loaded with each shell instance.

## Topic: `zsh`

When `zsh/install.zsh` is executed, the list of plugins (defined within `zsh/plugin_repos.zsh` as an array of GitHub repositories with format `<author>/<name>`) will be cloned into the `zsh/plugins` directory. All `*.zsh` files are then compiled, and `zsh/plugins/init.zsh` will be generated sourcing each plugin. All functions within `zsh/functions` will also be compiled, and `zsh/init.zsh` will be generated which will add each directory within `zsh/functions` to `fpath` and autoload each function.

In `$HOME/.zshrc` (which is symbolically linked to `zsh/.zshrc.linked`), every `init.zsh` within any topic directory is sourced, then every `*.zsh` file that is prefixed with a number within any topic directory will be sourced in alphabetical order. Within `zsh/03_plugins.zsh`, the function `dotfiles load_plugins` is called which sources `zsh/plugins/init.zsh`. This way, you can control what is loaded before and after plugins are loaded.

### Updating or making changes

Running `dotfiles update` will pull all plugin repositories as well as the main dotfiles repository. It may be necessary to recompile by running `dotfiles recompile` which will recompile any files that have changed since they were last compiled. After updating or compiling, you can reload shell by running `dotfiles reload` to see the effect of any changes.

### Benchmarking

Running `dotfiles benchmark` will download the latest version of [zsh-bench](https://github.com/romkatv/zsh-bench) to the plugins folder and run it.

## Topic: `macos`

The install script for this topic will only run if it is being run within a macOS environment, so you could add all kinds of macOS specific system configuration here without affecting Linux environments which run the same installer.

### Homebrew

It will check whether or not [Homebrew](https://brew.sh/) is installed, and if not, run the installer in non-interactive mode. It will also statically define the required paths in `init.zsh` so that the `brew shellenv` script isn't called on every shell load as the installer recommends. It then looks through all topics for a folder `brew` containing a `Brewfile` and runs `brew bundle install --file=Brewfile`.

### Python

It will use Homebrew to install the latest version of Python and set aliases for `python` and `pip` within `init.zsh` to point to the brew installed `python3` and `python3 -m pip`. It then updates `pip` and looks through all topics for a folder `pip` containing a `requirements.txt` and runs `pip install -r requirements.txt`.

### zsh

It will use Homebrew to install the latest version of zsh and set it to your default shell. On Apple silicon, this will make your zsh use the latest arm64 native build rather than the slightly dated x64 build that ships with macOS by default.

## Install

### Single line command

    curl -fsSL https://raw.githubusercontent.com/ndunnett/dotfiles/master/install.sh | sh

or

    wget -qO - https://raw.githubusercontent.com/ndunnett/dotfiles/master/install.sh | sh

### GitHub codespaces

On GitHub, navigate to `Settings > Codespaces`, tick `Automatically install dotfiles` and populate the repository field.

### VSCode devcontainers

In VSCode, navigate to `Settings > User > Extensions > Dev Containers`, and populate `Dotfiles: Repository`.

## Performance

Results from benchmarking with [zsh-bench](https://github.com/romkatv/zsh-bench) on a 2020 M1 MacBook Air:

### Vanilla (same plugins, loaded manually onto a bare .zshrc)

    first_prompt_lag_ms=13.259
    first_command_lag_ms=101.214
    command_lag_ms=13.800
    input_lag_ms=7.491
    exit_time_ms=39.214

### ndunnett/dotfiles

    first_prompt_lag_ms=20.456
    first_command_lag_ms=106.819
    command_lag_ms=5.379
    input_lag_ms=7.171
    exit_time_ms=38.615

### Oh-My-Zsh (same plugins, loaded by framework)

    first_prompt_lag_ms=292.866
    first_command_lag_ms=302.503
    command_lag_ms=86.253
    input_lag_ms=7.472
    exit_time_ms=100.290

### Comparison relative to vanilla

|  | Vanilla | ndunnett/dotfiles | Oh-My-Zsh |
|---|---|---|---|
| first_prompt_lag_ms | 100% | 154% | 2208% |
| first_command_lag_ms | 100% | 106% | 299% |
| command_lag_ms | 100% | 39% | 625% |
| input_lag_ms | 100% | 96% | 100% |
| exit_time_ms | 100% | 98% | 256% |
