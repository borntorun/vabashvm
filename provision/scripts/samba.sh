#!/bin/bash

## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Configure a Samba Share
##
## $1 - share name
## $2 - user (must exist)
## $3 - path to create at /home/<user>
##
## User will be added to "smbgrp" group, with password equal to login
## This script was tested sucessfully in:
## 		CentOS 7 (64bit)
## ======================================================================

# if an error occurs stops
#set -e

: ${_thispackage="Samba Share"}
: ${_thisfilename=${0##*/}}
printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:Running [%s]..." "$0"
#printf -- "[%s]-" $*
output()
{
	(printf "\n\t$(date +"%H:%M:%S"):==>$_thispackage:";	printf "$@")
}

: ${vabashvm_share=$1}
: ${vabashvm_user=$2}
: ${vabashvm_path=$3}


grep -q smbgrp /etc/group
[[ ! $? -eq 0 ]] && groupadd smbgrp && {
  gpasswd -a $vabashvm_user smbgrp > /dev/null
  grep -e "^smbgrp.*${vabashvm_user}$" /etc/group > /dev/null

  tee <<EOF >> passtmp$vabashvm_user
$vabashvm_user
$vabashvm_user
EOF
  smbpasswd -a $vabashvm_user < passtmp$vabashvm_user && rm passtmp$vabashvm_user
}

tee -a /etc/samba/smb.conf <<EOF >/dev/null
[$vabashvm_share]
comment = $vabashvm_share share on $HOSTNAME
path = /home/$vabashvm_user/$vabashvm_path
valid users = @smbgrp
browsable = yes
writable = yes
guest ok = no
create mask = 0775
directory mask = 0775
EOF

[[ ! $? -eq 0 ]] && output "Error in installation." || {
  #sudo chcon -u system_u -t samba_etc_t /etc/samba/smb.conf

  mkdir -p /samba/anonymous
  chmod -R 0755 /samba/anonymous/ && chown -R nobody:nobody /samba/anonymous/ && chcon -R -t samba_share_t /samba/anonymous/ && \
  firewall-cmd --permanent --zone=public --add-service=samba >/dev/null 2>&1 && firewall-cmd --reload >/dev/null 2>&1 && \
  systemctl enable smb.service && systemctl enable nmb.service && systemctl restart smb.service && systemctl restart nmb.service

  systemctl status smb.service | grep "Active: active (running)"
  [[ ! $? -eq 0 ]] && output "Error in installation."
}

printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:End [%s]." "$0"

exit 0
