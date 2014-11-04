#!/bin/bash
## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Very basic and simple script to enable port or port range on the firewall (CentOS 7 systems) 
## - port or range will be permanently enabled ONLY in default zone usually "public" zone
## - no validation are made on arguments - !!!Be Carefull!!!
##
## mandatory:
## $1 a valid protocol 
## $2 start port of range
## optional:
## $3 final port of range
##
## ex: firewallcmd-port-range tcp 3010
## ex: firewallcmd-port-range tcp 3010 3050
##
## This script was tested sucessfully in:
## - CentOS 7 (64bit)
## ======================================================================

# if an error occurs stops
#set -e

: ${_thispackage="firewallcmd-port-range"}
: ${_vabashvm="\nvabashvm:==>$_thispackage:"}
: ${_thisfilename=${0##*/}}
printf "${_vabashvm}Running [%s]..." "$0"
#printf -- "${_vabashvm}[%s]-" $*


printf "${_vabashvm}Configuring port(s)..."

: ${_isok=0}

case $# in
	2)	printf "%s/%s" "$2" "$1"
	    firewall-cmd --permanent --add-port="$2/$1" >/dev/null
		_isok=$(echo $?)
		;;
	3)	printf "%s-%s/%s" "$2" "$3" "$1"
	    firewall-cmd --permanent --add-port="$2-$3/$1" >/dev/null
		_isok=$(echo $?)
		;;
	*)	printf "${_vabashvm}Error in number of parameteres.\nUsage: %s <protocol> <port> [<port>]\n" "$0"
		_isok=1
		;;
esac

[[ $_isok -eq 0 ]] && firewall-cmd --reload >/dev/null

printf "${_vabashvm}Terminated.[%s]" "$0"

exit 0
