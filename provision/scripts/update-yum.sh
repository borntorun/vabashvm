#!/bin/bash

## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: Jo�o Carvalho 
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install Node.js global via packager manager
## Red Hat� Enterprise Linux� / RHEL, CentOS and Fedora
## as described in https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager#enterprise-linux-and-fedora
##
## This script was tested sucessfully in:
## 		CentOS 7
## ======================================================================

: ${_vabashvm="\nvabashvm:==>"}

printf "${_vabashvm}Running [%s]..." "$0"
#printf -- "${_vabashvm}[%s]-" $*

: ${vabashvm_thispackage="System update"}

yum -y update

[[ ! $? -eq 0 ]] && printf "${_vabashvm}[%s] failed!" "$vabashvm_thispackage" && exit 1

printf "${_vabashvm}[%s] terminated." "$vabashvm_thispackage"

exit 0