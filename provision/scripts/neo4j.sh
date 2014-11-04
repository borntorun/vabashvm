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
: ${_version="2.1.5"}
: ${_vabashvm="\nvabashvm:==>$_thispackage:"}
: ${_thisfilename=${0##*/}}
printf "${_vabashvm}Running [%s]..." "$0"
#printf -- "${_vabashvm}[%s]-" $*

systemctl status neo4dj-service.service 2>/dev/null | grep "Loaded: loaded" >/dev/null
if [[ ! $? -eq 0 ]]
then
    printf "${_vabashvm}Preparing to install version %s..." "$_version"
    ## Get and install neo4j
    : ${_installpack="neo4j-community-${_version}"}
    : ${_urltar="http://dist.neo4j.org/${_installpack}-unix.tar.gz"}
    : ${_installdir=/opt/neo4j/bin}

    #echo "$_installpack"
    #echo "$_urltar"
    #echo "$_installdir"
    #exit


    printf "${_vabashvm}Installing java opensdk 1.7 if needed..."
    yum -y install java*1.7*openjdk* >/dev/null

    ## restarting firewall to prevent possible error https://bugzilla.redhat.com/show_bug.cgi?id=1099031
    systemctl restart firewalld

    cd /opt

    ## Get pack untar it and cd to folder
    printf "${_vabashvm}Downloading %s package ...\n" "$_thispackage"
    curl -O "$_urltar" >/dev/null 2>/dev/null && tar -xzf "${_installpack}-unix.tar.gz" && mv "$_installpack" neo4j && cd neo4j

    if [[ $? -eq 0 ]]
    then
        printf "${_vabashvm}Installing ..."
        ## Installl pack
        echo $'\n\n'"Y"$'\n' | ./bin/neo4j-installer install >/dev/null
        ## Permits remote access
        sed -i "s|^#org.neo4j.server.webserver.address=|org.neo4j.server.webserver.address=|"  conf/neo4j-server.properties
        ## Installs as a service
        systemctl enable neo4j-service.service >/dev/null 2>/dev/null
        ## Start service
        systemctl start neo4j-service.service >/dev/null 2>/dev/null
        ## Path to profile
        echo "export PATH=${_installdir}:\$PATH" >> /etc/profile.d/z_vabashvm_${_thispackage}.sh
        ## Test service
        systemctl status neo4j-service.service 2>/dev/null | grep "Active: active" >/dev/null
        [[ $? -eq 0 ]] && printf "${_vabashvm}Installation succeded." || printf "${_vabashvm}Error: Possible error in installation."

        ## Open firewall port
        firewall-cmd --permanent --add-port=7474/tcp >/dev/null && firewall-cmd --reload >/dev/null
        [[ $? -eq 0 ]] && printf "${_vabashvm}Configured firewall for neo4j port:7474"

    fi
else
    printf "${_vabashvm}%s already installed. Nothing to do." "$_thispackage" && exit 0
fi

printf "${_vabashvm}Terminated.[%s]" "$0"
printf "\n"

exit 0
