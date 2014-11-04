#!/bin/bash
## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho 
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install MariaDB (MySql) Database Server
##
## $1 - version
## #2 - root_pwd
## optional:
##  $3 - user_admin and $4 - user_admin_pwd
##      optional: $5 - remote_net_access
##
## ex1: 10.0 Passw0rd
## ex2: 10.0 Passw0rd john Passw0rd
## ex3: 10.0 Passw0rd john Passw0rd 192.168.40.%
##
## This script was tested sucessfully in:
## - CentOS 7 (64bit)
## ======================================================================

# if an error occurs stops
#set -e

: ${_thispackage="MariaDB (MySql)"}
: ${_vabashvm="\nvabashvm:==>$_thispackage:"}
: ${_thisfilename=${0##*/}}
printf "${_vabashvm}Running [%s]..." "$0"
#printf -- "${_vabashvm}[%s]-" $*

: ${_isok=0}

case $# in
	2|4|5)
	    case "$1" in
	        "10.0"|"5.5")
	            ;;
	        *)
	            _isok=1
	            ;;
	    esac

		;;
	*)	_isok=1
		;;
esac


if [[ _isok -eq 0 ]]
then
    : ${_version="$1"}
    printf "${_vabashvm}Preparing to install version %s..." "$_version"

    # verify package installed
    which mysql >/dev/null 2>&1
    if [[ $? -eq 0 ]]
    then
        # remove previous install
        printf "${_vabashvm}Removing previous installs..."
        yum -y remove MariaDB* >/dev/null && yum -y remove mysql* >/dev/null && ([[ -d /var/lib/mysql ]] && mv /var/lib/mysql /var/lib/_vabashvmbackup$(date +%s)_mysql)
    else
        echo >/dev/null
    fi

    if [[ $? -eq 0 ]]
    then

        ## Get and install mariadb

        : ${_root_pwd="$2"}
        : ${_user_admin="$3"}
        : ${_user_admin_pwd="$4"}
        : ${_remote_net="$5"}


        cat <<EOF >/etc/yum.repos.d/MariaDB.repo
# MariaDB 10.0 CentOS repository list - created 2014-11-02 21:53 UTC
# http://mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/${_version}/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF

        # install it
        yum clean all
        printf "${_vabashvm}Installing..."
        yum -y install MariaDB-server MariaDB-client >/dev/null

        ##bind ip
        [[ $? -eq 0 ]] && sed -i "s|^\[mysqld\]$|\[mysqld\]\nbind-address = 127.0.0.1|"  /etc/my.cnf.d/server.cnf

        [[ $? -eq 0 ]] && systemctl restart mysql
        [[ $? -eq 0 ]] && systemctl enable mysql
        [[ $? -eq 0 ]] && systemctl status mysql 2>/dev/null | grep "Active: active" >/dev/null
        [[ $? -eq 0 ]] && printf "${_vabashvm}Installation succeded." || printf "${_vabashvm}Error: Possible error in installation."

        printf "${_vabashvm}Configuring..."


        mysqladmin -u root password "$_root_pwd" 2>/dev/null
        mysql -u root -p"$_root_pwd" -e "UPDATE mysql.user SET Password=PASSWORD('$_root_pwd') WHERE User='root'"
        [[ $? -eq 0 ]] && mysql -u root -p"$_root_pwd" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
        [[ $? -eq 0 ]] && mysql -u root -p"$_root_pwd" -e "DELETE FROM mysql.user WHERE User=''"
        [[ $? -eq 0 ]] && mysql -u root -p"$_root_pwd" -e "FLUSH PRIVILEGES"

        if [[ $3 && $4 ]]
        then
            [[ $? -eq 0 ]] && mysql -u root -p"$_root_pwd" -e "GRANT ALL PRIVILEGES ON *.* TO '$_user_admin'@'localhost' IDENTIFIED BY '$_user_admin_pwd' WITH GRANT OPTION"
            [[ $? -eq 0 ]] && mysql -u root -p"$_root_pwd" -e "GRANT ALL PRIVILEGES ON *.* TO '$_user_admin'@'127.0.0.1' IDENTIFIED BY '$_user_admin_pwd' WITH GRANT OPTION"
            [[ $? -eq 0 ]] && mysql -u root -p"$_root_pwd" -e "GRANT ALL PRIVILEGES ON *.* TO '$_user_admin'@'::1' IDENTIFIED BY '$_user_admin_pwd' WITH GRANT OPTION"
            if [[ $? -eq 0 ]] && [[ $5 ]]
            then
                mysql -u root -p"$_root_pwd" -e "GRANT ALL PRIVILEGES ON *.* TO '$_user_admin'@'$_remote_net' IDENTIFIED BY '$_user_admin_pwd' WITH GRANT OPTION"
                [[ $? -eq 0 ]] && sed -i "s|^.*bind-address|#bind-address|"  /etc/my.cnf.d/server.cnf
            fi
        fi

        [[ $? -eq 0 ]] && firewall-cmd --permanent --add-port=3306/tcp >/dev/null && firewall-cmd --reload >/dev/null && systemctl restart mysql

        [[ $? -eq 0 ]] && printf "${_vabashvm}Configuring ok."

        #echo
        #echo ======================================================
        #mysql -u "$_user_admin" -p"$_user_admin_pwd" -e "status"
        #echo ======================================================
        #mysql -u root -p"$_root_pwd" -e "status"
        #echo ======================================================
    else
        printf "${_vabashvm}Could not install."
    fi
else
    printf "${_vabashvm}Invalid parameteres."
fi

printf "${_vabashvm}Terminated.[%s]" "$0"
printf "\n"

exit 0
