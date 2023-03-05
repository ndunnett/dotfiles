# ndunnett/dotfiles
Basic dotfiles setup to use across macOS and Linux machines, physical, virtual, or containerised. Files are managed using symlinks with [GNU stow](https://www.gnu.org/software/stow/). The shell of choice is [zsh](https://zsh.sourceforge.io/) using [zim](https://zimfw.sh/) to manage plugins. Performance wise, on an M1 MacBook Air it takes ~50ms to load all configuration and plugins in a fresh shell, and shell response feels instant.

#### Shell plugins:
- [romkatv/powerlevel10k](https://github.com/romkatv/powerlevel10k): nice theme with good performance
- [zimfw/completion](https://github.com/zimfw/completion): enables tab completion
- [zimfw/ssh](https://github.com/zimfw/ssh): for ssh-agent convenience
- [zdharma/fast-syntax-highlighting](https://github.com/zdharma/fast-syntax-highlighting): highly performant syntax highlighting
- [zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions): fish-like autosuggestions

#### Roles:
default: should work on most Unix environments that support GNU stow once package manager is configured (only tested on Ubuntu and Debian)
macOS: same as default but executes shellenv for homebrew

# Install

#### Manual
    cd ~ && git clone https://github.com/ndunnett/dotfiles.git && ./dotfiles/install.sh [default|macos]

#### GitHub codespaces
On GitHub, navigate to `Settings > Codespaces`, tick `automatically install dotfiles` and populate repository field. Upon building a codespace, run `exec zsh` and restart container.

#### VSCode devcontainers
In VSCode, navigate to `Settings > User > Extensions > Dev Containers`, and populate `Dotfiles: Repository`. Upon building a container, run `exec zsh` and restart container.

# TODO
- Find better solution than stow that doesn't require installing dependencies
- Make script idempotent
- Test and patch compatibility with wider range of distributions
- Populate config with more improvements
- Install more completion plugins
