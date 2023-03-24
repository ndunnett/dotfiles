#!/bin/zsh

echo "[dotfiles] checking python installation"

# install brewed python
python_path="$HOMEBREW_PREFIX/bin/python3"
[[ -e "$python_path" ]] || (brew install python && changes_made="yes")

# update pip
echo "[dotfiles] updating pip..."
$python_path -m pip install --upgrade pip

# install packages
echo "[dotfiles] installing pip packages..."
for requirements in $DOTFILES_HOME/**/pip/requirements.txt; do
  $python_path -m pip install -r "$requirements"
done

# in init.zsh: set python aliases
echo "[dotfiles] setting aliases..."
echo "[dotfiles] python=\"$python_path\""
echo "[dotfiles] pip=\"$python_path -m pip\""
init_temp="$DOTFILES_HOME/macos/init.zsh.temp"
echo "alias python=\"$python_path\"" >> "$init_temp"
echo "alias pip=\"$python_path -m pip\"" >> "$init_temp"

# check for changes and exit
[[ -v changes_made ]] && exit 0 || exit 1
