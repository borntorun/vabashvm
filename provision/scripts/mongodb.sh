#!/bin/bash

## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install MongoDB
##
## $1 - version to install [32|64 default]
## 
## This script was tested sucessfully in:
## 		CentOS 7 (64bit)
## ======================================================================

# if an error occurs stops
#set -e
: ${_thispackage="MongoDB"}
: ${_vabashvm="\nvabashvm:==>$_thispackage:"}
: ${_thisfilename=${0##*/}}
printf "${_vabashvm}Running [%s]..." "$0"
#printf -- "${_vabashvm}[%s]-" $*

which mongod >/dev/null 2>&1
[[ $? -eq 0 ]] && printf "${_vabashvm}Already installed. Nothing to do." && exit 0

: ${version="x86_64"}

if [[ ! $1 ]] 
then
	printf "${_vabashvm}No version choosen: will install x86_64..." 
else
	[[ "$1" == "32" ]] && version="i686" 	
fi	

printf "${_vabashvm}Installing version [%s]..."  "$version"

cat <<EOF >/etc/yum.repos.d/mongodb.repo
[mongodb]
name=MongoDB Repository
baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/${version}/
gpgcheck=0
enabled=1
EOF

yum clean metadata >/dev/null
yum -y install mongodb-org >/dev/null
[[ ! $? -eq 0 ]] && printf "${_vabashvm}Error installing MongoDB." && exit 0
printf "${_vabashvm}Package installed."
printf "${_vabashvm}Configuring..."

sed -i "s|^enabled=1$|enabled=0|g" /etc/yum.repos.d/mongodb.repo
[[ ! $? -eq 0 ]] && printf "${_vabashvm}Error configuring repo."
sed -i "s|^bind_ip=.*$|bind_ip=0.0.0.0|" /etc/mongod.conf
[[ ! $? -eq 0 ]] && printf "${_vabashvm}Error configuring bind_ip."

which semanage >/dev/null 2>&1
[[ ! $? -eq 0 ]] && printf "${_vabashvm}Installing configuring dependencies ..." && yum -y install policycoreutils-python >/dev/null

semanage port -a -t mongod_port_t -p tcp 27017  >/dev/null

printf "${_vabashvm}Configuring firewall..."
firewall-cmd --permanent --zone=public --add-port=27017/tcp >/dev/null
firewall-cmd --permanent --zone=public --add-port=28017/tcp >/dev/null
firewall-cmd --reload >/dev/null

printf "${_vabashvm}Starting service..."
chkconfig --levels 2345 mongod on
systemctl start mongod >/dev/null
[[ ! $? -eq 0 ]] && printf "${_vabashvm}Error starting service." || printf "${_vabashvm}Installed and running."

printf "${_vabashvm}Terminated.[%s]" "$0"

exit 0
