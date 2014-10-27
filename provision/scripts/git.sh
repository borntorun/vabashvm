#!/bin/bash

## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho 
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install git
##
## $1 - version of git to install
## 
## This script was tested sucessfully in:
## - CentOS 6.5
## - CentOS 7
## ======================================================================

# if an error occurs stops
#set -e

: ${_vabashvm="\nvabashvm:==>"}

printf "${_vabashvm}Running [%s]..." "$0"
#printf -- "${_vabashvm}[%s]-" $*

: ${_thispackage="git"}
: ${_urlversions="https://www.kernel.org/pub/software/scm/git/"}

if [[ ! $1 ]] 
then
	printf "${_vabashvm}No version chosen: will try to install latest..." 
	: ${_gitpack=$(curl $_urlversions | grep "git-[0-9]\.[0-9.]*tar\.gz" | sed "s|</a>.*$||" | sed "s|^.*>||" | sort -r | head -1)}
else
	: ${_gitpack=git-$1.tar.gz}
fi	

: ${_gitfolder=$(echo $_gitpack | sed "s|.tar.gz||")}
: ${_gitversion=$(echo $_gitfolder | sed "s|git-||")}

printf "${_vabashvm}Preparing to install [%s] version [%s]..." "$_thispackage" "${_gitversion}"

git --version | grep " ${_gitversion}" #>/dev/null
[[ $? -eq 0 ]] && printf "${_vabashvm}Git version [%s] already installed." "$_gitversion" && exit 0

# Install dependencies
yum -y install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker >/dev/null

## Get and install git

: ${_installdir=/usr/local/git}
cd /usr/src

wget -q ${_urlversions}${_gitpack}
[[ -e ${_gitpack} ]] && tar xzf ${_gitpack} && cd ${_gitfolder}
[[ $? -eq 0 ]] && make prefix=${_installdir} all >/dev/null && make prefix=${_installdir} install >/dev/null

if [[ $? -eq 0 ]]
then 
	echo "export PATH=${_installdir}/bin:\$PATH" >> /etc/profile.d/z_vabashvm_$_thispackage.sh
	#source /etc/profile.d/z_vabashvm_$_thispackage.sh
	#this will remove the version that comes by default with centOS
	#yum -y remove git >/dev/null
fi

# Cleaning
rm -rf /usr/src/${_gitfolder}
rm -rf /usr/src/${_gitpack}

printf "${_vabashvm}Installation of [%s] terminated.\n" "$_thispackage"
exit 0