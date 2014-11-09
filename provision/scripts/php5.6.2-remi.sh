#!/bin/bash
## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho 
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install php - verion 5.6 inluded in distribution Remi repo
##
## This script was tested sucessfully in:
## - CentOS 7 (64bit)
## ======================================================================

# if an error occurs stops
#set -e

: ${_thispackage="php-remi5.6"}
: ${_thisfilename=${0##*/}}
printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:Running [%s]..." "$0"
#printf -- "[%s]-" $*
output()
{
	(printf "\n\t$(date +"%H:%M:%S"):==>$_thispackage:";	printf "$@")
}

output "Installing..."

yum -y --enablerepo=remi --enablerepo=remi-php56 --enablerepo=epel install php php-cli php-fpm php-intl php-mysqlnd php-pgsql php-pecl-mongo >/dev/null

[[ $? -eq 0 ]] && output "Installed." || output "Not installed."

printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:End [%s]." "$0"

exit 0
