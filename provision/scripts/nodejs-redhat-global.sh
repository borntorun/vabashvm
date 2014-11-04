#!/bin/bash

## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install Node.js global via packager manager
## RHEL, CentOS and Fedora
## as described in https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager#enterprise-linux-and-fedora
##
## This script was tested sucessfully in:
## 		CentOS 7 (64bit)
## ======================================================================

# if an error occurs stops
#set -e

: ${_thispackage="Node.js"}
: ${_vabashvm="\nvabashvm:==>$_thispackage:"}
: ${_thisfilename=${0##*/}}
printf "${_vabashvm}Running [%s]..." "$0"
#printf -- "${_vabashvm}[%s]-" $*


printf "${_vabashvm}Installing..."

curl -L https://rpm.nodesource.com/setup | sudo bash - 1>/dev/null
[[ ! $? -eq 0 ]] && printf "${_vabashvm}Error downloading rpm package." && exit 0

sudo yum -y install gcc-c++ make 1>/dev/null
[[ ! $? -eq 0 ]] && printf "${_vabashvm}Error installing dependencies." && exit 0

sudo yum -y install nodejs #1>/dev/null
[[ ! $? -eq 0 ]] && printf "${_vabashvm}Error installing package." && exit 0

printf "${_vabashvm}Package installed"

printf "${_vabashvm}Terminated.[%s]" "$0"

exit 0
