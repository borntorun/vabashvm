#!/bin/bash
## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Configure network interfaces to use eth* name rules (CentOS 7 systems)
##
## This script was tested sucessfully in:
## - CentOS 7 (64bit)
## ======================================================================

# if an error occurs stops
#set -e

: ${_thispackage="CentOS-7-net-eth-rules"}
: ${_vabashvm="\nvabashvm:==>$_thispackage:"}
: ${_thisfilename=${0##*/}}
printf "${_vabashvm}Running [%s]..." "$0"
#printf -- "${_vabashvm}[%s]-" $*


printf "${_vabashvm}Configuring..."

: ${_index=0}
: ${_filerules="/etc/udev/rules.d/99-configeth.rules"}

rm -f "$_filerules"

for file in /sys/class/net/*
do
	[[ "$file" == "/sys/class/net/lo" ]] && continue


	_actualdevname=${file##*/}
	_newdevname="eth${_index}"
	_newfile="/etc/sysconfig/network-scripts/ifcfg-${_newdevname}"

    printf "${_vabashvm}Configuring [%s]" "$_newdevname"

	printf "SUBSYSTEM==\"net\", ACTION==\"add\", DRIVERS==\"?*\", ATTR{address}==\"%s\", ATTR{dev_id}==\"0x0\", ATTR{type}==\"1\", KERNEL==\"eth*\", NAME=\"eth%s\"\n" "$(cat $file/address)" "$((_index++))" >> "$_filerules"

	mv "/etc/sysconfig/network-scripts/ifcfg-${_actualdevname}" "$_newfile"
    sed -i "s|^HWADDR=.*$||g" "$_newfile"
    echo "HWADDR=$(cat $file/address)" >> "$_newfile"
	sed -i "s|$_actualdevname|$_newdevname|g" "$_newfile"

done

printf "${_vabashvm}Terminated.[%s]" "$0"

exit 0
