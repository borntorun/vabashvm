#!/bin/sh
## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install epel release
##
## $1 - version 6|7
##
## This script was tested sucessfully in:
## - CentOS 7 (64bit)
## ======================================================================

: ${_thispackage="EPEL Release"}
: ${_vabashvm="\nvabashvm:==>$_thispackage:"}
: ${_thisfilename=${0##*/}}
printf "${_vabashvm}Running [%s]..." "$0"
#printf -- "${_vabashvm}[%s]-" $*


yum repolist all | grep -q epel
[[ ! $? -eq 0 ]] && {

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

    [[ _isok -eq 0 ]] && {
        printf "${_vabashvm}Preparing to install version epel-%s %s..." "$_version" "$_arch"

        cat <<EOF >/etc/yum.repos.d/epel-bootstrap.repo
[epel]
name=Bootstrap EPEL
mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=epel-${_version}&arch=${_arch}
failovermethod=priority
enabled=0
gpgcheck=0
EOF
        yum --enablerepo=epel -y install epel-release >/dev/null
        rm -f /etc/yum.repos.d/epel-bootstrap.repo
        yum repolist | grep "epel/$_arch" >/dev/null

    } || printf "${_vabashvm}Invalid parameteres."

} || printf "${_vabashvm}Seems to be already installed.Nothing to do."

printf "${_vabashvm}Terminated.[%s]" "$0"
printf "\n"

exit 0