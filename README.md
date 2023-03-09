# ndunnett/dotfiles
Designed to use across any unix system compatible with zsh, only actually tested on macOS and Ubuntu. There is no framework, plugins are managed by <100 lines of shell script. There are two types of files: config (static location) and linked (symbolically linked). I have minimised the amount of linked files, and point back to the config files as much as possible.

Running `install.sh` dynamically manages symbolic links using `ln` based on the contents of `linked` (it will map the file structure to your `$HOME` directory) and writes the required environment variables to `.zshenv`. Existing files that conflict with linked files will be renamed to have `.old` as a suffix.

Functions defined within the `config/zsh/functions` directory will be automatically compiled and autoloaded at the start of `~/.zshrc`. All files prefixed with a number within `config/zsh` (ie. `01_config.zsh`) will be sourced in order, these files are where all custom configuration should be defined. An array of GitHub repositories with format `<author>/<name>` should be exported as `dotfiles_plugins` before calling `dotfiles load_plugins` to automatically manage plugin loading.

### Shell plugins
- [romkatv/powerlevel10k](https://github.com/romkatv/powerlevel10k): nice theme with good performance
- [zimfw/completion](https://github.com/zimfw/completion): enables tab completion
- [zimfw/ssh](https://github.com/zimfw/ssh): for ssh-agent convenience
- [zdharma/fast-syntax-highlighting](https://github.com/zdharma/fast-syntax-highlighting): highly performant syntax highlighting
- [zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions): fish-like autosuggestions

### `dotfiles` command
- Work in progress, see [config/zsh/functions/dotfiles/dotfiles](https://github.com/ndunnett/dotfiles/blob/master/config/zsh/functions/dotfiles/dotfiles)

# Install
### Manual
Run single line script:

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ndunnett/dotfiles/master/scripts/bootstrap.sh)" && exec zsh

### GitHub codespaces
On GitHub, navigate to `Settings > Codespaces`, tick `automatically install dotfiles` and populate repository field. Upon building a codespace, run `exec zsh` and restart the container.

### VSCode devcontainers
In VSCode, navigate to `Settings > User > Extensions > Dev Containers`, and populate `Dotfiles: Repository`. Upon building a container, run `exec zsh` and restart the container.

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
- Make script idempotent
- Refine list of plugins to use
- Populate config with more improvements
- Test and patch compatibility with wider range of distributions
