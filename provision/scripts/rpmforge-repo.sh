#!/bin/sh
## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install rpmforge repo
##
## $1 - version 6|7
##
## This script was tested sucessfully in:
## - CentOS 7 (64bit)
## ======================================================================

: ${_thispackage="RPMForge Repo"}
: ${_thisfilename=${0##*/}}
printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:Running [%s]..." "$0"
#printf -- "[%s]-" $*
output()
{
	(printf "\n\t$(date +"%H:%M:%S"):==>$_thispackage:";	printf "$@")
}

: ${_version="$1"}
: ${_arch="$(uname -i)"}

: ${_isok=0}
case "$_version" in
	"6"|"7")
		;;
	*)
		_isok=1
	;;
esac

[[ ! _isok -eq 0 ]] && output "Invalid parameteres." || {

	yum repolist all | grep -iq "rpmforge"
	[[ $? -eq 0 ]] && output "Package is already installed." || {

		output "Preparing to install version rpmforge %s %s..." "$_version" "$_arch"
		rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
		[[ $? -eq 0 ]] && yum -y install http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el${_version}.rf.${_arch}.rpm >/dev/null 2>/dev/null
		[[ $? -eq 0 ]] && sed -i "s|^enabled.*=.*1$|enabled = 0|g" /etc/yum.repos.d/rpmforge.repo
		[[ $? -eq 0 ]] && yum repolist all | grep -i "rpmforge"
		[[ $? -eq 0 ]] && output "Installed." || output "Error: not installed."
	}
}

printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:End [%s]." "$0"

exit 0