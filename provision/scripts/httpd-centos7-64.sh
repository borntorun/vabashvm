#!/bin/bash
## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho 
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install httpd - Apache Web Server
##
## This script was tested sucessfully in:
## - CentOS 7 (64bit)
## ======================================================================

# if an error occurs stops
#set -e

: ${_thispackage="httpd"}
: ${_vabashvm="\nvabashvm:==>$_thispackage:"}
: ${_thisfilename=${0##*/}}
printf "${_vabashvm}Running [%s]..." "$0"
#printf -- "${_vabashvm}[%s]-" $*

printf "${_vabashvm}Installing..."

yum -y install httpd openssl mod_ssl >/dev/null
[[ $? -eq 0 ]] && printf "${_vabashvm}Configuring %s service..." "$_thispackage" && systemctl restart httpd && systemctl enable httpd

# configure firewall
[[ $? -eq 0 ]] && printf "${_vabashvm}Configuring firewall..." && firewall-cmd --add-service=http --permanent >/dev/null && firewall-cmd --add-service=https --permanent >/dev/null && firewall-cmd --reload >/dev/null

httpd -v

printf "${_vabashvm}Terminated.[%s]" "$0"
printf "\n"

exit 0
