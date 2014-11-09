#!/bin/bash
## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho 
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install NEO4J Graph Database Server
##
## This will install v 2.1.5. Not configuring version as passing parameter
## because at this time not sure about general repository for neo4j versions
##
## This script was tested sucessfully in:
## - CentOS 7 (64bit)
## ======================================================================

# if an error occurs stops
#set -e

: ${_thispackage="neo4j"}
: ${_thisfilename=${0##*/}}
printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:Running [%s]..." "$0"
#printf -- "[%s]-" $*
output()
{
	(printf "\n\t$(date +"%H:%M:%S"):==>$_thispackage:";	printf "$@")
}


: ${_version="2.1.5"}

systemctl status neo4dj-service.service 2>/dev/null | grep "Loaded: loaded" >/dev/null
[[ $? -eq 0 ]] && output "Already installed. Nothing to do." || {
	output "Preparing to install version %s..." "$_version"
	## Get and install neo4j
	: ${_installpack="neo4j-community-${_version}"}
	: ${_urltar="http://dist.neo4j.org/${_installpack}-unix.tar.gz"}
	: ${_installdir=/opt/neo4j/bin}

	#echo "$_installpack"
	#echo "$_urltar"
	#echo "$_installdir"
	#exit

	output "Installing java opensdk 1.7 if needed..."
	yum -y install java*1.7*openjdk* >/dev/null

	# dependencies
	yum -y install lsof >/dev/null

	## restarting firewall to prevent possible error https://bugzilla.redhat.com/show_bug.cgi?id=1099031
	systemctl restart firewalld

	## Get pack untar it and cd to folder
	output "Downloading %s package ...\n" "$_thispackage"
	##
	cd /opt
	##
	curl -O "$_urltar" >/dev/null 2>/dev/null && tar -xzf "${_installpack}-unix.tar.gz" && mv "$_installpack" neo4j && cd neo4j

	[[ ! $? -eq 0 ]] && output "Error downloading or uncompressing package" || {

		output "Installing ..."
		## Installl pack
		echo $'\n\n'"Y"$'\n' | ./bin/neo4j-installer install >/dev/null

		[[ ! $? -eq 0 ]] && output "Error installing." || {
			output "Installed."
			## Permits remote access
			sed -i "s|^#org.neo4j.server.webserver.address=|org.neo4j.server.webserver.address=|" conf/neo4j-server.properties
			## Installs as a service ## Start service
			systemctl enable neo4j-service.service >/dev/null
			[[ $? -eq 0 ]] && output "Service Enabled."
			systemctl start neo4j-service.service >/dev/null
			[[ $? -eq 0 ]] && output "Service Started."
			## Path to profile
			echo "pathmunge ${_installdir}"$'\n'"export PATH" >> /etc/profile.d/z_vabashvm_${_thispackage}.sh
			## Open firewall port
			firewall-cmd --permanent --add-port=7474/tcp >/dev/null && firewall-cmd --reload >/dev/null
			[[ $? -eq 0 ]] && output "Firewall configured for neo4j port:7474"  || output "Error configuring firewall."
			## Test service
			systemctl restart neo4j-service.service >/dev/null
			systemctl status neo4j-service.service | grep "Active: active"
			[[ $? -eq 0 ]] && output "Service running." || output "Error: Service not running."
		}
	}
}

printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:End [%s]." "$0"

exit 0
