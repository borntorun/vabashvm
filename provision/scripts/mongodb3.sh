#!/bin/bash

## This script was ****** NOT ****** tested sucessfully in:

## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install MongoDB v3.2
##
## $1 - redhat system version to install [6|7 default]
##
## This script was ****** NOT ****** tested sucessfully in:
## 		CentOS 7 (64bit)
## ======================================================================


## This script was ****** NOT ****** tested sucessfully in:


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

[[ ! "$1" == "6" ]] && [[ ! "$1" == "7" ]] && output "Invalid version." || {

  which mongod >/dev/null 2>&1
  [[ $? -eq 0 ]] && output "Already installed. Nothing to do." || {

    : ${version="7"}

    [[ ! $1 ]] && output "No platform version choosen..." || ([[ "$1" == "6" ]] && version="6")


    output "Installing platform version [%s]..."  "$version"

	  cat <<EOF >/etc/yum.repos.d/mongodb-org-3.2.repo
[mongodb-org-3.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/${version}/mongodb-org/3.2/x86_64/
gpgcheck=0
enabled=1
EOF
#gpgkey=https://www.mongodb.org/static/pgp/server-3.2.asc
    yum clean all >/dev/null
    yum -y install mongodb-org #>/dev/null
    [[ ! $? -eq 0 ]] && output "Error in installation." || {

      output "Package installed."
      output "Configuring..."

      sed -i "s|^enabled=1$|enabled=0|g" /etc/yum.repos.d/mongodb-org-3.2.repo
      [[ ! $? -eq 0 ]] && output "......Error configuring repo."

      #sed -i "s|^bind_ip=.*$|bind_ip=0.0.0.0|" /etc/mongod.conf
      #[[ ! $? -eq 0 ]] && output "......Error configuring bind_ip."

      cat <<EOF >>/etc/yum.conf
exclude=mongodb-org,mongodb-org-server,mongodb-org-shell,mongodb-org-mongos,mongodb-org-tools
EOF
      [[ ! $? -eq 0 ]] && output "......Error configuring yum.conf with exclude."

      output "Configuring SELINUX..."
      which semanage >/dev/null 2>&1
      [[ ! $? -eq 0 ]] && output "......Installing configuring dependencies ..." && yum -y install policycoreutils-python >/dev/null

      [[ $? -eq 0 ]] && semanage port -a -t mongod_port_t -p tcp 27017  >/dev/null
      output "......Ok."

      output "Configuring firewall..."
      firewall-cmd --permanent --zone=public --add-port=27017/tcp >/dev/null && firewall-cmd --permanent --zone=public --add-port=28017/tcp >/dev/null && firewall-cmd --reload >/dev/null
      ([[ ! $? -eq 0 ]] && output "......Error configuring firewall.") || output "......Ok."

      output "Starting service..."
      chkconfig --levels 2345 mongod on
      systemctl start mongod >/dev/null
      ([[ ! $? -eq 0 ]] && output "......Error starting service.") || output "......Service is running."
    }
  }
}

printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:End [%s]." "$0"

exit 0
