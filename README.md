# ndunnett/dotfiles
Basic dotfiles repo designed to use across any unix system compatible with zsh. There is no framework, plugins are managed by <100 lines of shell script. There are two types of files: config and linked. I have minimised the amound of linked files, and point back to the static config files as much as possible. Running `install.sh` dynamically manages symbolic links using `ln` based on the contents of `linked` and writes the required environment variables to `.zshenv`.

### Shell plugins
- [romkatv/powerlevel10k](https://github.com/romkatv/powerlevel10k): nice theme with good performance
- [zimfw/completion](https://github.com/zimfw/completion): enables tab completion
- [zimfw/ssh](https://github.com/zimfw/ssh): for ssh-agent convenience
- [zdharma/fast-syntax-highlighting](https://github.com/zdharma/fast-syntax-highlighting): highly performant syntax highlighting
- [zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions): fish-like autosuggestions

### `dotfiles` command
- `dotfiles reload`: reloads shell with `exec ${SHELL} -l`
- `dotfiles update`: runs `git pull` for each plugin repo and the dotfiles repo, reinitialises plugins, reloads shell
- `dotfiles benchmark`: runs benchmark using [zsh-bench](https://github.com/romkatv/zsh-bench)
- `dotfiles help`: prints valid commands with brief explanation to terminal

# Install
### Manual
    curl -s https://raw.githubusercontent.com/ndunnett/dotfiles/master/bootstrap.sh | sh && exec zsh
### GitHub codespaces
On GitHub, navigate to `Settings > Codespaces`, tick `automatically install dotfiles` and populate repository field. Upon building a codespace, run `exec zsh` and restart the container.
### VSCode devcontainers
In VSCode, navigate to `Settings > User > Extensions > Dev Containers`, and populate `Dotfiles: Repository`. Upon building a container, run `exec zsh` and restart the container.

# Performance

# TODO
- Setup plugin compilation
- Setup font management
- Setup SSH teleportation
- Improve `dotfiles update` to check status of repo before pulling
- Setup automatic updates
- Add some logging and tidy up output to terminal
- Make script idempotent
- Refine list of plugins to use
- Populate config with more improvements
- Test and patch compatibility with wider range of distributions
