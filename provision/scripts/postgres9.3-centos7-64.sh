#!/bin/bash
## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho 
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install postgres 9.3 Database Server
##
## optional:
## $1 - user in the system to create in server
## #2 - remote_net_access in the form nnn.nnn.nnn.nnn/prefix (no validation is made)
##
## This script was tested sucessfully in:
## - CentOS 7 (64bit)
## ======================================================================

# if an error occurs stops
#set -e

: ${_thispackage="postgres"}
: ${_thisfilename=${0##*/}}
printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:Running [%s]..." "$0"
#printf -- "[%s]-" $*
output()
{
	(printf "\n\t$(date +"%H:%M:%S"):==>$_thispackage:";	printf "$@")
}

: ${_user_="$1"}
: ${_remote_net="$2"}
: ${_data_dir="/var/lib/pgsql/9.3/data/"}
: ${_instal_dir="/usr/local/pgsql/bin"}

output "Installing..."

yum -y install http://yum.postgresql.org/9.3/redhat/rhel-7-x86_64/pgdg-centos93-9.3-1.noarch.rpm >/dev/null
[[ $? -eq 0 ]] && output "Repo installed." && yum -y install postgresql93-server postgresql93-contrib >/dev/null
[[ ! $? -eq 0 ]] && output "Error installing package." || {

	output "Package installed.\n"
	/usr/pgsql-9.3/bin/postgresql93-setup initdb
	[[ ! $? -eq 0 ]] && output "Error: running [postgresql93-setup initdb]."

	systemctl enable postgresql-9.3.service && systemctl start postgresql-9.3.service
	[[ ! $? -eq 0 ]] && output "Error enabling or starting service."

	## permits remote access
	[[ ! -z $_remote_net ]] && {
		cp "${_data_dir}pg_hba.conf" "${_data_dir}pg_hba.conf.original"
		[[ $? -eq 0 ]] && echo "host all all ${_remote_net} trust" >> "${_data_dir}pg_hba.conf"

		cp "${_data_dir}postgresql.conf" "${_data_dir}postgresql.conf.original"
		[[ $? -eq 0 ]] &&  sed -i "s|^#listen_addresses.*$|listen_addresses = '*'|" "${_data_dir}postgresql.conf"
	}
	## create user
	[[ ! -z $_remote_net ]] && {
		sudo -u postgres createuser -s "$_user_" >/dev/null 2>/dev/null
		[[ ! $? -eq 0 ]] && output "Error: User [%s] not created." "${_user_}"
	}
	firewall-cmd --permanent --add-port=5432/tcp >/dev/null && firewall-cmd --reload >/dev/null
	[[ ! $? -eq 0 ]] && output "Error enabling firewall.\n"
	systemctl restart postgresql-9.3.service
	[[ ! $? -eq 0 ]] && output "Error starting service."
	echo "pathmunge ${_instal_dir}/bin"$'\n'"export PATH" >> /etc/profile.d/z_vabashvm_${_thispackage}.sh
}

printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:End [%s]." "$0"

exit 0
