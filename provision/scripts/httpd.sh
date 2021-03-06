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
: ${_thisfilename=${0##*/}}
printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:Running [%s]..." "$0"
#printf -- "[%s]-" $*
output()
{
	(printf "\n\t$(date +"%H:%M:%S"):==>$_thispackage:";	printf "$@")
}

output "Installing..."

yum -y install httpd openssl mod_ssl >/dev/null
[[ ! $? -eq 0 ]] && output "Error installing package." || {
	output "Installed."
	httpd -v
	systemctl restart httpd >/dev/null && systemctl enable httpd >/dev/null

	# configure firewall
	output "Configuring firewall..."
	firewall-cmd --add-service=http --permanent >/dev/null && firewall-cmd --add-service=https --permanent >/dev/null && firewall-cmd --reload >/dev/null
	[[ $? -eq 0 ]] && output "Firewall configured." || output "Errors configuring firewall."
}

printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:End [%s]." "$0"

exit 0
