#!/bin/sh
## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================

global_path_script="${BASH_SOURCE[0]}"
## while is a symbolic link follow path..
while [[ -h "$global_path_script" ]]; do
  cd "$(dirname "$global_path_script")"
  global_path_script="$(readlink "$global_path_script")"
done
global_path_script="$(cd -P "$(dirname "$global_path_script")" && pwd)"

## verify syntax
sh -n "${global_path_script}"/vabashvm.sh

[[ ! $? -eq 0 ]] && exit 1
#printf "%s\n" $*

## call script
"${global_path_script}"/vabashvm.sh $*
