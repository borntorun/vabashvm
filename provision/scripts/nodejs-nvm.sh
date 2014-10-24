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
## 		CentOS 7
## ======================================================================

# if an error occurs stops
#set -e

: ${_vabashvm="\nvabashvm:==>"}

printf "${_vabashvm}Running [%s]..." "$0"
#printf -- "${_vabashvm}[%s]-" $*

: ${vabashvm_thispackage="Node.js with NVM"}
: ${vabashvm_thisfilename=${0##*/}}

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
        printf "${_vabashvm}Installing NVM..."
		wget --retry-connrefused -q -O - https://raw.githubusercontent.com/creationix/nvm/master/install.sh | sh -
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
	[[ ! ${_nvminstalled} -eq 0 ]] && (printf "${_vabashvm}NVM not installed. Cannot install Node.js version %s." "$vabashvm_nodeversion") && exit 0
	printf "${_vabashvm}Installing Node [%s]..." "$vabashvm_nodeversion"
	(nvm install $vabashvm_nodeversion 1>/dev/null 2>&1) && (nvm use $vabashvm_nodeversion) &&  (nvm alias default $vabashvm_nodeversion)	
fi

printf "${_vabashvm}Installation of [%s] terminated." "$vabashvm_thispackage"

exit 0
