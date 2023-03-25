# ndunnett/dotfiles
Designed to maintain and use a common set of files across any unix derived system, only actually tested on macOS and Ubuntu. There is no framework, everything is managed by shell scripts. Files are organised by topic, with the `zsh` topic being the engine so to speak.

### How it works
Running `install.sh` primarily does two things:

1. Dynamically manages symbolic links using `ln`. Any files within any topic directory suffixed with `.linked` will be symbolically linked from `$HOME` in the same file structure, ie. `topic/foo/bar.zsh.linked` will have a symbolic link from `$HOME/foo/bar.zsh`. Existing files that conflict with linked files will be renamed to have `.old` as a suffix, ie. `$HOME/foo/bar.zsh.old`.

2. Runs the topic installation scripts, starting with `zsh`. Any script named `install.zsh` within the base directory of each topic will be run during installation. These scripts are where you should install applications, write environment variables, write initialisation scripts, etc. Within each topic directory, any file named `init.zsh` (ie. `topic/init.zsh`) will be sourced first, then all files prefixed with a number (ie. `topic/01_config.zsh`) will be sourced in alphabetical order within `$HOME/.zshrc`. This is where you should implement custom configuration that needs to be loaded with each shell instance.

### Idempotence
At every step of the way, before making any change it will first be checked if the change needs to be made, so it is safe to repeatedly run the installation process as well as updating and recompiling.

# Topic: `zsh`
### How it works
When `zsh/install.zsh` is executed, the list of plugins (defined within `zsh/plugin_repos.zsh` as an array of GitHub repositories with format `<author>/<name>`) will be cloned into the `zsh/plugins` directory. All `*.zsh` files are then compiled, and `zsh/plugins/init.zsh` will be generated sourcing each plugin. All functions within `zsh/functions` will also be compiled, and `zsh/init.zsh` will be generated which will add each directory within `zsh/functions` to `fpath` and autoload each function.

In `$HOME/.zshrc` (which is symbolically linked to `zsh/.zshrc.linked`), every `init.zsh` within any topic directory is sourced, then every `*.zsh` file that is prefixed with a number within any topic directory will be sourced in alphabetical order. Within `zsh/03_plugins.zsh`, the function `dotfiles load_plugins` is called which sources `zsh/plugins/init.zsh`. This way, you can control what is loaded before and after plugins are loaded.

### Updating or making changes
Running `dotfiles update` will pull all plugin repositories as well as the main dotfiles repository. It may be necessary to recompile by running `dotfiles recompile` which will recompile any files that have changed since they were last compiled. After updating or compiling, you can reload shell by running `dotfiles reload` to see the effect of any changes.

### Benchmarking
Running `dotfiles benchmark` will download the latest version of [zsh-bench](https://github.com/romkatv/zsh-bench) to the plugins folder and run it.

### Default plugins
- [romkatv/powerlevel10k](https://github.com/romkatv/powerlevel10k): nice theme with good performance
- [zimfw/completion](https://github.com/zimfw/completion): enables tab completion
- [zimfw/ssh](https://github.com/zimfw/ssh): for ssh-agent convenience
- [zdharma/fast-syntax-highlighting](https://github.com/zdharma/fast-syntax-highlighting): highly performant syntax highlighting
- [zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions): fish-like autosuggestions

# Topic: `macos`
### What it does
The install script for this topic will only run if it is being run within a macOS environment, so you could add all kinds of macOS specific system configuration here without affecting Linux environments which run the same installer.

### Homebrew
It will check whether or not [Homebrew](https://brew.sh/) is installed, and if not, run the installer in non-interactive mode. It will also statically define the required paths in `init.zsh` so that the `brew shellenv` script isn't called on every shell load as the installer recommends. It then looks through all topics for a folder `brew` containing a `Brewfile` and runs `brew bundle install --file=Brewfile`.

### Python
It will use Homebrew to install the latest version of Python and set aliases for `python` and `pip` within `init.zsh` to point to the brew installed `python3` and `python3 -m pip`. It then updates `pip` and looks through all topics for a folder `pip` containing a `requirements.txt` and runs `pip install -r requirements.txt`.

### zsh
It will use Homebrew to install the latest version of zsh and set it to your default shell. On Apple silicon, this will make your zsh use the latest arm64 native build rather than the slightly dated x64 build that ships with macOS by default.

# Install
### Single line install

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ndunnett/dotfiles/master/install.sh)"

### GitHub codespaces
On GitHub, navigate to `Settings > Codespaces`, tick `Automatically install dotfiles` and populate the repository field.

### VSCode devcontainers
In VSCode, navigate to `Settings > User > Extensions > Dev Containers`, and populate `Dotfiles: Repository`.

# Performance
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

# TODO
- Setup font management
- Setup SSH teleportation
- Setup automatic updates
- Enable automating installation with Ansible or similar
- Refine list of plugins to use
- Populate config with more improvements
- Test and patch compatibility with wider range of distributions
