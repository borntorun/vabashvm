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

: ${_thispackage="RPMForge Release"}
: ${_vabashvm="\nvabashvm:==>$_thispackage:"}
: ${_thisfilename=${0##*/}}
printf "${_vabashvm}Running [%s]..." "$0"
#printf -- "${_vabashvm}[%s]-" $*

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

if [[ _isok -eq 0 ]]
then
    printf "${_vabashvm}Preparing to install version rpmforge-%s %s..." "$_version" "$_arch"

    rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
    yum -y install http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el${_version}.rf.${_arch}.rpm >/dev/null

else
    printf "${_vabashvm}Invalid parameteres."
fi

printf "${_vabashvm}Terminated.[%s]" "$0"
printf "\n"

exit 0