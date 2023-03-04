#!/bin/sh

# determine package manager
package_manager=undetermined
for candidate in apt brew; do
  command -v $candidate >/dev/null 2>&1 && package_manager=$candidate
done

# determine commands to use
case $package_manager in
  apt) install_packages="sudo apt update && apt install -y";;
  brew) install_packages="brew update && brew install";;
esac

# determine which dependencies need to be installed
for dependency in $dependencies; do
  command -v $dependency >/dev/null 2>&1 || packages_to_install="$packages_to_install $dependency"
done

# install dependencies that aren't already installed
if [ "$packages_to_install" ]; then
  eval "$install_packages$packages_to_install"
fi
