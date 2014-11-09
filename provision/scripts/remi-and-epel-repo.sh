#!/bin/sh
## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install remi repo (http://rpms.famillecollet.com/)
## Install epel repo (https://fedoraproject.org/wiki/EPEL)
##
## $1 - version 6|7
##
## This script was tested sucessfully in:
## - CentOS 7 (64bit)
## ======================================================================

: ${_thispackage="Epel+Remi-Repo"}
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

	yum repolist all | grep -iq "epel\|remi"
	[[ $? -eq 0 ]] && output "Package is already installed." || {

		output "Installing epel-release %s %s..." "$_version" "$_arch"

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
		[[ $? -eq 0 ]] && yum repolist all | grep -i "epel"
		[[ $? -eq 0 ]] && {
			output "Installing remi repo %s %s..." "$_version" "$_arch"
			wget http://rpms.famillecollet.com/enterprise/remi-release-${_version}.rpm >/dev/null 2>/dev/null
			[[ $? -eq 0 ]] && rpm -Uvh remi-release-${_version}*.rpm >/dev/null 2>/dev/null
			[[ $? -eq 0 ]] && yum repolist all | grep -i "remi"
		}
		[[ $? -eq 0 ]] && output "Installed." || output "Error: Not installed."
	}
}

printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:End [%s]." "$0"

exit 0