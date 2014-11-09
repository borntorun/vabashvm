#!/bin/bash

## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho 
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install git globally (in /usr/local/git)
##
## $1 - version of git to install
## 
## This script was tested sucessfully in:
## - CentOS 6.5 (64bit))
## - CentOS 7 (64bit)
## ======================================================================

# if an error occurs stops
#set -e

: ${_thispackage="git"}
: ${_thisfilename=${0##*/}}
printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:Running [%s]..." "$0"
#printf -- "[%s]-" $*
output()
{
	(printf "\n\t$(date +"%H:%M:%S"):==>$_thispackage:";	printf "$@")
}

: ${_urlversions="https://www.kernel.org/pub/software/scm/git/"}

if [[ ! $1 ]] 
then
	output "No version chosen: will try to install latest..."
	: ${_gitpack=$(curl $_urlversions 2>/dev/null | grep "git-[0-9]\.[0-9.]*tar\.gz" | sed "s|</a>.*$||" | sed "s|^.*>||" | sort -r | head -1)}
else
	: ${_gitpack=git-$1.tar.gz}
fi	

: ${_gitfolder=$(echo $_gitpack | sed "s|.tar.gz||")}
: ${_gitversion=$(echo $_gitfolder | sed "s|git-||")}

output "Preparing to install version [%s]..." "${_gitversion}"

git --version | grep -q " ${_gitversion}" >/dev/null
[[ $? -eq 0 ]] && output "Version [%s] already installed. Nothing to do." "$_gitversion" || {

	## Get and install git
	output "Downloading package..."

	: ${_installdir=/usr/local/git}
	cd /usr/src
	wget -q ${_urlversions}${_gitpack} >/dev/null 2>&1

	[[ ! $? -eq 0 ]] && output "Error downloading package." || {

		# Install dependencies
		output "Installing dependencies..."
		yum -y install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker >/dev/null
		[[ $? -eq 0 ]] && output "Installing package..." && [[ -e ${_gitpack} ]] && tar xzf ${_gitpack} && cd ${_gitfolder}
		[[ $? -eq 0 ]] && make prefix=${_installdir} all >/dev/null 2>&1
		[[ $? -eq 0 ]] && make prefix=${_installdir} install >/dev/null 2>&1
		[[ $? -eq 0 ]] && echo "pathmunge ${_installdir}/bin"$'\n'"export PATH" >> /etc/profile.d/z_vabashvm_${_thispackage}.sh
		#this will remove the version that comes by default with centOS
		#yum -y remove git >/dev/null 2>&1
		[[ $? -eq 0 ]] && output "Installed."  || output "Error installing."

	}
}

# Cleaning
rm -rf /usr/src/${_gitfolder}
rm -rf /usr/src/${_gitpack}

printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:End [%s]." "$0"

exit 0
