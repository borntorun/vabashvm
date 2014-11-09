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
: ${_thisfilename=${0##*/}}
printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:Running [%s]..." "$0"
#printf -- "[%s]-" $*
output()
{
	(printf "\n\t$(date +"%H:%M:%S"):==>$_thispackage:";	printf "$@")
}

which mongod >/dev/null 2>&1
[[ $? -eq 0 ]] && output "Already installed. Nothing to do." || {

	: ${version="x86_64"}

	[[ ! $1 ]] && output "No platform version choosen..." || ([[ "$1" == "32" ]] && version="i686")

	output "Installing platform version [%s]..."  "$version"

	cat <<EOF >/etc/yum.repos.d/mongodb.repo
[mongodb]
name=MongoDB Repository
baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/${version}/
gpgcheck=0
enabled=1
EOF

	yum clean metadata >/dev/null
	yum -y install mongodb-org >/dev/null
	[[ ! $? -eq 0 ]] && output "Error in installation." || {

		output "Package installed."
		output "Configuring..."

		sed -i "s|^enabled=1$|enabled=0|g" /etc/yum.repos.d/mongodb.repo
		[[ ! $? -eq 0 ]] && output "Error configuring repo."

		sed -i "s|^bind_ip=.*$|bind_ip=0.0.0.0|" /etc/mongod.conf
		[[ ! $? -eq 0 ]] && output "Error configuring bind_ip."

		which semanage >/dev/null 2>&1
		[[ ! $? -eq 0 ]] && output "Installing configuring dependencies ..." && yum -y install policycoreutils-python >/dev/null

		[[ $? -eq 0 ]] && semanage port -a -t mongod_port_t -p tcp 27017  >/dev/null

		output "Configuring firewall..."
		firewall-cmd --permanent --zone=public --add-port=27017/tcp >/dev/null && firewall-cmd --permanent --zone=public --add-port=28017/tcp >/dev/null && firewall-cmd --reload >/dev/null
		[[ ! $? -eq 0 ]] && output "Error configuring firewall."

		output "Starting service..."
		chkconfig --levels 2345 mongod on
		systemctl start mongod >/dev/null
		[[ ! $? -eq 0 ]] && output "Error starting service." || output "Service running."
	}
}

printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:End [%s]." "$0"

exit 0