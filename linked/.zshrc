# ~/.zshrc

for file in $(find $DOTFILES_HOME/config/zsh/* -maxdepth 0 -regex ".*[0-9][0-9].*.rc"); do
  source $file
done
