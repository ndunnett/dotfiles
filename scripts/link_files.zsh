#!/bin/zsh

linked_file="$DOTFILES_HOME/.linked"

# check if .linked exists, delete existing symbolic linkes
if [[ -e $linked_file ]]; then
  while read file_to_link link_target; do
    [[ -L $link_target ]] && rm -f "$link_target"
  done < $linked_file
  truncate -s 0 "$linked_file"
else
  touch "$linked_file"
fi

# populate .linked with [file_to_link] [link_target]
for file_to_link in $DOTFILES_HOME/*/**/*.linked(D); do
  echo "$file_to_link $(echo "$file_to_link" | sed -e "s|$DOTFILES_HOME/[^/]*|$HOME|g" -e "s|.linked||g")" >> $linked_file
done

# for each file to link: delete existing symlink, backup existing file, create new symlink
while read file_to_link link_target; do
  [[ -L $link_target ]] && rm -f "$link_target"
  [[ -e $link_target ]] && mv "$link_target" "$link_target.old"
  ln -sf "$file_to_link" "$link_target"
done < $linked_file
