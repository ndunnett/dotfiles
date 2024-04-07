#!/bin/zsh

function files_differ() {
  # if files both exist, compare contents
  [[ ! -e "$1" || ! -e "$2" ]] && return 0
  cmp -s "$1" "$2" && return 1 || return 0
}

echo "[dotfiles] start linking files"

# make .linked.temp file
linked_file="$DOTFILES_HOME/.linked"
linked_temp="$DOTFILES_HOME/.linked.temp"
touch $linked_temp

# populate .linked.temp with [file_to_link] [link_target]
for file_to_link in $DOTFILES_HOME/*/**/*.linked(D); do
  echo "$file_to_link $(echo "$file_to_link" | sed -e "s|$DOTFILES_HOME/[^/]*|$HOME|g" -e "s|.linked||g")" >> $linked_temp
done

# compare .linked.temp with existing .linked
if files_differ "$linked_file" "$linked_temp"; then
  # delete existing symlinks
  if [[ -e $linked_file ]]; then
    while read file_to_link link_target; do
      echo "[dotfiles] removing link from $link_target to $(readlink -f $link_target)"
      [[ -L $link_target ]] && rm -f "$link_target"
    done < $linked_file
  fi

  # overwrite old .linked file
  rm -f "$linked_file" && mv "$linked_temp" "$linked_file"

  # for each file to link: delete existing symlink, backup existing file, create new symlink
  while read file_to_link link_target; do
    [[ -L $link_target && $link_target != $(readlink -f $link_target) ]] && rm -f "$link_target" && echo "[dotfiles] removing link from $link_target to $(readlink -f $link_target)"
    [[ -e $link_target ]] && mv "$link_target" "$link_target.old" && echo "[dotfiles] renaming $link_target to $link_target.old"
    [[ -d "$(dirname "$link_target")" ]] || mkdir "$(dirname "$link_target")"
    ln -sf "$file_to_link" "$link_target" && echo "[dotfiles] creating link from $link_target to $file_to_link"
  done < $linked_file

  changes_made="yes"
else
  # delete .linked.temp
  rm -f "$linked_temp"

  # make sure links are healthy
  while read file_to_link link_target; do
    echo "[dotfiles] linking $(echo "$file_to_link" | sed -e "s|$DOTFILES_HOME/||g" )..."

    if [[ ! -e $link_target ]]; then
      # if target doesn't exist, create symlink
      echo "[dotfiles] creating link from $link_target to $file_to_link"
      ln -sf "$file_to_link" "$link_target"
      changes_made="yes"
    elif [[ -f $link_target && ! -L $link_target ]]; then
      # if target is a file, backup and create symlink
      echo "[dotfiles] renaming $link_target to $link_target.old"
      echo "[dotfiles] creating link from $link_target to $file_to_link"
      mv "$link_target" "$link_target.old"
      ln -sf "$file_to_link" "$link_target"
      changes_made="yes"
    elif [[ -L $link_target && $(readlink -f $link_target) != $file_to_link ]]; then
      # if target is a symlink but doesn't match target, replace with correct symlink
      echo "[dotfiles] removing link from $link_target to $(readlink -f $link_target)"
      echo "[dotfiles] creating link from $link_target to $file_to_link"
      rm -f "$link_target"
      ln -sf "$file_to_link" "$link_target"
      changes_made="yes"
    fi
  done < $linked_file
fi

# check for changes
if [[ -v changes_made ]]; then
  echo "[dotfiles] finished linking files, reload to apply changes"
  exit 0
else
  echo "[dotfiles] finished linking files, no changes made"
  exit 1
fi
