#!/bin/bash

## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install Node.js global via packager manager
## RHEL, CentOS and Fedora
## as described in https://github.com/nodesource/distributions
##
## $1 - optional - the Node.js version to install 4|5|6
##
## This script was tested sucessfully in:
## 		CentOS 7 (64bit)
## ======================================================================

# if an error occurs stops
#set -e

: ${_thispackage="Node.js"}
: ${_thisfilename=${0##*/}}
printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:Running [%s]..." "$0"
#printf -- "[%s]-" $*
output()
{
	(printf "\n\t$(date +"%H:%M:%S"):==>$_thispackage:";	printf "$@")
}

## verify if there is a specifiv node version to install
: ${vabashvm_nodeversion=$1}

[[ -z $vabashvm_nodeversion ]] && output "Version not specified." || {
  output "Installing nodesource repo..."
  curl -L https://rpm.nodesource.com/setup_$vabashvm_nodeversion.x 2>/dev/null | sudo bash - >/dev/null
  [[ ! $? -eq 0 ]] && output "Error downloading rpm package." || {
    output "Installing dependencies..."
    sudo yum -y install gcc-c++ make 1>/dev/null
    [[ ! $? -eq 0 ]] && output "Error installing dependencies." || {
      sudo yum clean all
      output "Installing package..."
      sudo yum -y install nodejs 1>/dev/null
      output "Node version is:" && node -v
      [[ $? -eq 0 ]] && output "Package installed" || output "Error installing package."
    }
  }
}
printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:End [%s]." "$0"

exit 0




