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
: ${_vabashvm="\nvabashvm:==>$_thispackage:"}
: ${_thisfilename=${0##*/}}
printf "${_vabashvm}Running [%s]..." "$0"
#printf -- "${_vabashvm}[%s]-" $*

: ${_urlversions="https://www.kernel.org/pub/software/scm/git/"}

if [[ ! $1 ]] 
then
	printf "${_vabashvm}No version chosen: will try to install latest..." 
	: ${_gitpack=$(curl $_urlversions 2>/dev/null | grep "git-[0-9]\.[0-9.]*tar\.gz" | sed "s|</a>.*$||" | sed "s|^.*>||" | sort -r | head -1)}
else
	: ${_gitpack=git-$1.tar.gz}
fi	

: ${_gitfolder=$(echo $_gitpack | sed "s|.tar.gz||")}
: ${_gitversion=$(echo $_gitfolder | sed "s|git-||")}

printf "${_vabashvm}Preparing to install version [%s]..." "${_gitversion}"

git --version | grep " ${_gitversion}" #>/dev/null
[[ ! $? -eq 0 ]] &&  { # if it is not installed

    ## Get and install git
    printf "${_vabashvm}Downloading package..."

    : ${_installdir=/usr/local/git}
    cd /usr/src
    wget -q ${_urlversions}${_gitpack}

    [[ $? -eq 0 ]] && {
        # Install dependencies
        printf "${_vabashvm}Installing dependencies..."

        yum -y install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker >/dev/null
        [[ $? -eq 0 ]] && {

            printf "${_vabashvm}Installing package..."

            [[ -e ${_gitpack} ]] && tar xzf ${_gitpack} && cd ${_gitfolder}
            [[ $? -eq 0 ]] && make prefix=${_installdir} all >/dev/null 2>&1 && make prefix=${_installdir} install >/dev/null 2>&1 && {
                echo "pathmunge ${_installdir}/bin"$'\n'"export PATH" >> /etc/profile.d/z_vabashvm_${_thispackage}.sh
                #source /etc/profile.d/z_vabashvm_$_thispackage.sh
                #this will remove the version that comes by default with centOS
                yum -y remove git >/dev/null 2>&1
                printf "${_vabashvm}Installed."

            } || printf "${_vabashvm}Error installing package."

            # Cleaning
            rm -rf /usr/src/${_gitfolder}
            rm -rf /usr/src/${_gitpack}
        }
    } || printf "${_vabashvm}Error downloading package."

} || printf "${_vabashvm}Version [%s] already installed. Nothing to do." "$_gitversion"

printf "${_vabashvm}Terminated.[%s]" "$0"
exit 0
