#!/bin/bash
## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install tmux terminal multiplexer
##
## This script was tested sucessfully in:
## - CentOS 7 (64bit)
## ======================================================================

# if an error occurs stops
#set -e

: ${_thispackage="tmux"}
: ${_thisfilename=${0##*/}}
printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:Running [%s]..." "$0"
#printf -- "[%s]-" $*
output()
{
	(printf "\n\t$(date +"%H:%M:%S"):==>$_thispackage:";	printf "$@")
}
## verify if there is a specifiv user where to apply tmux on login
: ${vabashvm_user=$1}


which tmux >/dev/null 2>&1
[[ $? -eq 0 ]] && output "tmux already installed. Nothing to do." && exit 0

output "Preparing to install..."
output "Installing dependencies..."

## Get and install dependencies
: ${_dep1="https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz"}
sudo yum install -y libevent-devel ncurses-devel glibc-static >/dev/null 2>&1 && wget "${_dep1}" >/dev/null 2>&1 && tar xzvf libevent-2.0.21-stable.tar.gz >/dev/null 2>&1 && cd libevent-2.0.21-stable && ./configure >/dev/null 2>&1 && make >/dev/null 2>&1 && sudo make install >/dev/null 2>&1
[[ ! $? -eq 0 ]] && output "Error installing dependencies." && exit 1


## Get and install tmux
output "Installing tmux..."
: ${_installdir=/usr/local/tmux}
cd /usr/local && sudo git clone https://github.com/tmux/tmux.git >/dev/null 2>&1 && cd tmux && sudo sh autogen.sh >/dev/null 2>&1 && sudo ./configure >/dev/null 2>&1 && sudo make >/dev/null 2>&1
[[ ! $? -eq 0 ]] && output "Error installing tmux." && exit 1

output "Configuring path..."
cd
echo "pathmunge ${_installdir}"$'\n'"export PATH" >> $_thispackage-profile-tmp.sh
sudo mv $_thispackage-profile-tmp.sh /etc/profile.d/z_vabashvm_$_thispackage.sh
[[ -d /home/$vabashvm_user ]] && {
  sudo cat <<EOF >>"/home/$vabashvm_user/.bashrc"

# Start tmux terminal
# If not running interactively, do not do anything
[[ \$- != *i* ]] && return
[[ -z "\$TMUX" ]] && exec tmux
EOF
}

output "Cleaning..."
rm -f z_vabashvm_$_thispackage.sh
rm -rf libevent-2.0.21-stable
rm libevent-2.0.21-stable.tar.gz

output "Installed."

printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:End [%s]." "$0"

exit 0
