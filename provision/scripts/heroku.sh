#!/bin/bash
## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho 
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install heroku toolbelt 
## 
## This script was tested sucessfully in:
## - CentOS 6.5 (64bit)
## - CentOS 7 (64bit)
## ======================================================================

# if an error occurs stops
#set -e

: ${_thispackage="heroku"}
: ${_thisfilename=${0##*/}}
printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:Running [%s]..." "$0"
#printf -- "[%s]-" $*
output()
{
	(printf "\n\t$(date +"%H:%M:%S"):==>$_thispackage:";	printf "$@")
}

which heroku >/dev/null 2>&1
[[ $? -eq 0 ]] && output "Heroku toolbelt already installed. Nothing to do." && exit 0

output "Preparing to install..."

## Get and install heroku
: ${_urlheroku="https://toolbelt.herokuapp.com/install.sh"}

: ${_installdir=/usr/local/heroku/bin}

rm -f install-heroku.sh

which wget >/dev/null 2>&1
if [[ ! $? -eq 0 ]]; then
	curl -s -o install-heroku.sh $_urlheroku >/dev/null 2>/dev/null
else
	wget -qc -O install-heroku.sh $_urlheroku >/dev/null 2>/dev/null
fi
## insert a test in heroku script to validate the installation script and then calls script
[[ $? -eq 0 ]] && sed -i "s|^SCRIPT$|SCRIPT\\n[[ ! \$? -eq 0 ]] \&\& echo \"Error in installation.\" \&\& exit 1|" install-heroku.sh && sh install-heroku.sh
[[ ! $? -eq 0 ]] && output "Not installed." && exit 0

rm -f z_vabashvm_$_thispackage.sh

echo "pathmunge ${_installdir}"$'\n'"export PATH" >> /etc/profile.d/z_vabashvm_$_thispackage.sh

rm -f install-heroku.sh

output "Installed."

printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:End [%s]." "$0"

exit 0
