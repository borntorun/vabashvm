#!/bin/bash
## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho 
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install php (for httpd)
##
## This script was tested sucessfully in:
## - CentOS 7 (64bit)
## ======================================================================

# if an error occurs stops
#set -e

: ${_thispackage="php"}
: ${_vabashvm="\nvabashvm:==>$_thispackage:"}
: ${_thisfilename=${0##*/}}
printf "${_vabashvm}Running [%s]..." "$0"
#printf -- "${_vabashvm}[%s]-" $*

printf "${_vabashvm}Installing..."

yum -y install php php-cli php-fpm php-intl php-mysqlnd php-pgsql php-pecl-mongo >/dev/null
([[ $? -eq 0 ]] && php -v && printf "${_vabashvm}Installed.") || printf "${_vabashvm}Not installed."

printf "${_vabashvm}Terminated.[%s]" "$0"
printf "\n"

exit 0
