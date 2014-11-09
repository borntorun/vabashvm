#!/bin/bash
## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Configure hostname 
## 
## $1 hostname
## $2 ip address to configure on hosts file
##
## This script was tested sucessfully in:
## - CentOS 7 (64bit)
## ======================================================================

# if an error occurs stops
#set -e
: ${_thispackage="hostname"}
: ${_thisfilename=${0##*/}}
printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:Running [%s]..." "$0"
#printf -- "[%s]-" $*
output()
{
	(printf "\n\t$(date +"%H:%M:%S"):==>$_thispackage:";	printf "$@")
}

util_isvalidip() #@ USAGE: util_isvalidip DOTTED-QUAD 
{ 
	#this function credits: Pro Bash Programming by Chris F.A. Johnson http://cfajohnson.com/books/cfajohnson/pbp/
	case $1 in 
	## reject the following: 
	## empty string 
	## anything other than digits and dots 
	## anything not ending in a digit 
	"" | *[!0-9.]* | *[!0-9]) echo 1; exit ;; 
	esac 
	## Change IFS to a dot, but only in this function 
	local IFS=. 
	## Place the IP address into the positional parameters; 
	## after word splitting each element becomes a parameter 
	set -- $1 	
	[ $# -eq 4 ] && ## must be four parameters 
	## each must be less than 256 
	## A default of 666 (which is invalid) is used if a parameter is empty 
	## All four parameters must pass the test 
	[ ${1:-666} -le 255 ] && [ ${2:-666} -le 255 ] && 
	[ ${3:-666} -le 255 ] && [ ${4:-666} -le 255 ] && echo 0 && exit
	echo 1	
} 

if [[ $# -eq 2 ]] && [[ $(util_isvalidip "$2") -eq 0 ]]
then
	printf "\nHOSTNAME=%s" "$1" >> /etc/sysconfig/network
	printf "\n%s %s" "$2" "$1" >> /etc/hosts
else
	output "Not configuring - incorrect parameters."
fi

printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:End [%s]." "$0"


exit 0
