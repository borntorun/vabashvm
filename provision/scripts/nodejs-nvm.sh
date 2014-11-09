#!/bin/bash

## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install Node.js with Node Version Manager
## Node.js will be installed on home folder of the user calling the script
##
## $1 - username to determine the home folder to install to
## $2 - optional - the Node.js version to install (if not present nvm will be installed with no default Node.js version)
## 
## This script was tested sucessfully in:
## 		CentOS 7 (64bit)
## ======================================================================

# if an error occurs stops
#set -e

: ${_thispackage="Node.js-NVM"}
: ${_thisfilename=${0##*/}}
printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:Running [%s]..." "$0"
#printf -- "[%s]-" $*
output()
{
	(printf "\n\t$(date +"%H:%M:%S"):==>$_thispackage:";	printf "$@")
}

## important! change to home user folder
cd
## 

nvminstalled()
{
	[[ -e ~/.nvm/nvm.sh ]] && source ~/.nvm/nvm.sh
	nvm --version 1>/dev/null 2>&1
	[[ $? -eq 0 ]] && _nvminstalled=0 || _nvminstalled=1	
}

nvminstalled

## if nvm is not installed let's install it
if [[ ! ${_nvminstalled} -eq 0 ]] 
then
    output "Installing NVM..."
	wget --retry-connrefused -q -O - https://raw.githubusercontent.com/creationix/nvm/master/install.sh 2>/dev/null | sh -
	if [[ $? -eq 0 ]]
	then
		source ~/.nvm/nvm.sh
		echo "source ~/.nvm/nvm.sh" >> ~/.bash_profile
		nvminstalled
	fi
fi

## verify if there is a specifiv node version to install
: ${vabashvm_nodeversion=$2}

if [[ ! -z $vabashvm_nodeversion ]]
then
	[[ ! ${_nvminstalled} -eq 0 ]] && output "NVM not installed. Cannot install Node.js version [%s]." "$vabashvm_nodeversion" || {
		output "Installing Node.js version [%s]..." "$vabashvm_nodeversion"
		nvm install $vabashvm_nodeversion 1>/dev/null 2>&1 && nvm use $vabashvm_nodeversion && nvm alias default $vabashvm_nodeversion
		[[ $? -eq 0 ]] && output "Node.js version [%s] installed." "$vabashvm_nodeversion" || output "Error installing Node.js version [%s]." "$vabashvm_nodeversion"
	}
fi

printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:End [%s]." "$0"

exit 0
