#!/bin/sh
## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install epel repo (https://fedoraproject.org/wiki/EPEL)
##
## $1 - version 6|7
##
## This script was tested sucessfully in:
## - CentOS 7 (64bit)
## ======================================================================

: ${_thispackage="EPEL Repo"}
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

[[ ! _isok -eq 0 ]] &&  output "Invalid parameteres." || {

	yum repolist all | grep -q epel
	[[ $? -eq 0 ]] && output "Error in installation or package is already installed." || {

		output "Preparing to install version epel %s %s..." "$_version" "$_arch"

		cat <<EOF >/etc/yum.repos.d/epel-bootstrap.repo
[epel]
name=Bootstrap EPEL
mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=epel-${_version}&arch=${_arch}
failovermethod=priority
enabled=0
gpgcheck=0
EOF
		[[ $? -eq 0 ]] && yum -y --enablerepo=epel install epel-release >/dev/null 2>/dev/null
		[[ $? -eq 0 ]] && rm -f /etc/yum.repos.d/epel-bootstrap.repo
		[[ $? -eq 0 ]] && sed -i "s|^enabled.*=.*1$|enabled = 0|g" /etc/yum.repos.d/epel.repo
		[[ $? -eq 0 ]] && yum repolist all | grep "epel"
		[[ $? -eq 0 ]] && output "Installed." || output "Error installing."
	}
}

printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:End [%s]." "$0"

exit 0