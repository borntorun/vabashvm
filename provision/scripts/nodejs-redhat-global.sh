#!/bin/bash

## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho 
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install Node.js global via packager manager
## Red Hat® Enterprise Linux® / RHEL, CentOS and Fedora
## as described in https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager#enterprise-linux-and-fedora
##
## This script was tested sucessfully in:
## 		CentOS 7
## ======================================================================

# if an error occurs stops
#set -e

: ${_vabashvm="\nvabashvm:==>"}

printf "${_vabashvm}Running [%s]..." "$0"
#printf -- "${_vabashvm}[%s]-" $*

: ${vabashvm_thispackage="Node.js"}

printf "${_vabashvm}Installing [%s]..." "$vabashvm_thispackage"

curl -L https://rpm.nodesource.com/setup | sudo bash - 1>/dev/null

sudo yum -y install gcc-c++ make 1>/dev/null

sudo yum -y install nodejs #1>/dev/null

printf "${_vabashvm}Installation of [%s] terminated." "$vabashvm_thispackage"

exit 0
