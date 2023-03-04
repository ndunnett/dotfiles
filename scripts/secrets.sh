#!/bin/sh

# read in existing vars from .secrets
secrets=$dotfiles_dir/.secrets
if test -f $secrets; then
  . $secrets
else
  touch $secrets
fi

# loop over templates
for template in $(find $dotfiles_dir/secret_templates -type f); do
  # populate unset vars to .secrets
  for var in $(cat $template | grep -Eo "\\\${.*?}" | sed "s/^\${//g" | sed "s/}$//g"); do
    if [ -z $(eval "echo \$$var") ]; then
      read -p "$var: " $var
      echo "$var=$(eval "echo \$$var")" >> $dotfiles_dir/.secrets
    fi
  done

  # create secret file
  file_name=$(basename $template)
  file_path=$(echo ${template%/*} | sed "s|$dotfiles_dir/secret_templates|$dotfiles_dir/config/secret|g")
  file=$file_path/$file_name
  mkdir -p $file_path && touch $file

  # render template to file
  eval "echo \"$(cat $template)\"" > $file
done
