#!/bin/sh

# check if .stowed exists
if test -f $stowed; then
  # unstow files
  while read target dir module; do
    stow --delete --target=$target --dir=$dir $module
  done < $stowed

  # clear .stowed
  truncate -s 0 $stowed
else
  # create .stowed
  touch $stowed
fi

# populate .stowed
for src in $dotfiles_dir/config $dotfiles_dir/roles/$dotfiles_role; do
  for dir in $(find $src/* -maxdepth 0 -type d); do
    echo "$target_dir $src $(basename $dir)" >> $stowed
  done
done

# delete existing files
while read target dir module; do
  for file in $(find $dir/$module -type f); do
    file_name=$(basename $file)
    file_path=$(echo ${file%/*} | sed "s|$dir/$module|$target|g")
    rm -f $file_path/$file_name
  done
done < $stowed

# stow files
while read target dir module; do
  stow --target=$target --dir=$dir $module
done < $stowed
