#!/bin/bash
## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho 
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install heroku toolbelt 
## 
## This script was tested sucessfully in:
## - CentOS 6.5
## - CentOS 7
## ======================================================================

# if an error occurs stops
#set -e

: ${_vabashvm="\nvabashvm:==>"}

printf "${_vabashvm}Running [%s]..." "$0"
#printf -- "${_vabashvm}[%s]-" $*

: ${_thispackage="heroku"}

printf "${_vabashvm}Preparing to install [%s] ..." "$_thispackage"

which heroku >/dev/null 2>&1
[[ $? -eq 0 ]] && printf "${_vabashvm}Heroku toolbelt already installed. Nothing to do." && exit 0

## Get and install heroku
: ${_urlheroku="https://toolbelt.herokuapp.com/install.sh"}

: ${_installdir=/usr/local/heroku/bin}

rm -f install-heroku.sh

which wget >/dev/null 2>&1
if [[ ! $? -eq 0 ]]; then
	curl -s -o install-heroku.sh $_urlheroku
else
	wget -qc -O install-heroku.sh $_urlheroku
fi
## insert a test in heroku script to validate the installation script and then calls script
[[ $? -eq 0 ]] && sed -i "s|^SCRIPT$|SCRIPT\\n[[ ! \$? -eq 0 ]] \&\& echo \"Error in installation.\" \&\& exit 1|" install-heroku.sh && sh install-heroku.sh
[[ ! $? -eq 0 ]] && printf "${_vabashvm}[%s] not installed." "$_thispackage" && exit 0

rm -f z_vabashvm_$_thispackage.sh
echo "export PATH=${_installdir}:\$PATH" >> /etc/profile.d/z_vabashvm_$_thispackage.sh

rm -f install-heroku.sh

printf "${_vabashvm}Installation of [%s] terminated.\n" "$_thispackage"

exit 0
