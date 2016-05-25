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
## $3 - path to create at /home/<user> ex: "devel" will share the path: /home/<user>/devel
##
## User will be added to "smbgrp" group, with password equal to login
## Group "smbgrp" will be created if does not exists
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
	(printf "\n\t$(date +"%H:%M:%S"):==>$_thispackage:";	printf "$@\n")
}

: ${vabashvm_share=$1}
: ${vabashvm_user=$2}
: ${vabashvm_path=/home/$2/$3}

[[ -z $1 ]] && output "Error in parameters (1)." && exit 1
[[ -z $2 ]] && output "Error in parameters (2)." && exit 1
[[ -z $3 ]] && output "Error in parameters (3)." && exit 1

grep -q "\[${vabashvm_share}\]" /etc/samba/smb.conf
[[ $? -eq 0 ]] && output "Share already exists." && exit 1

grep -e "^${vabashvm_user}.*/home/${vabashvm_user}:" /etc/passwd
[[ ! $? -eq 0 ]] && output "Invalid user." && exit 1

grep -q smbgrp /etc/group
[[ ! $? -eq 0 ]] && {
  output "Adding group smbgrp"
  groupadd smbgrp
}
grep -e "^smbgrp.*${vabashvm_user}$" /etc/group  > /dev/null
[[ ! $? -eq 0 ]] && {
  output "Adding user to group"
  gpasswd -a $vabashvm_user smbgrp > /dev/null 2>&1
  [[ ! $? -eq 0 ]] && output "Error in installation (user/group)." && exit 1
  tee <<EOF >> passtmp$vabashvm_user
$vabashvm_user
$vabashvm_user
EOF
  smbpasswd -a $vabashvm_user < passtmp$vabashvm_user && rm passtmp$vabashvm_user
  [[ ! $? -eq 0 ]] && output "Error in installation (user samba pwd)." && exit 1
}

tee -a /etc/samba/smb.conf <<EOF >/dev/null

[$vabashvm_share]
comment = $vabashvm_share share on $HOSTNAME
path = $vabashvm_path
valid users = @smbgrp
browsable = yes
writable = yes
guest ok = no
create mask = 0775
directory mask = 0775
EOF


[[ ! $? -eq 0 ]] && output "Error in installation." || {

  [[ ! -d $vabashvm_path ]] && mkdir -p "$vabashvm_path"
  chmod -R 0775 "$vabashvm_path" && chcon -R -t samba_share_t "$vabashvm_path" && chown -R $vabashvm_user:smbgrp "$vabashvm_path" && \
  systemctl restart smb.service && systemctl restart nmb.service

  systemctl status smb.service | grep "Active: active (running)"
  [[ ! $? -eq 0 ]] && output "Error in installation."
}

output "End ${0}"
#printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:End [%s]." "$0"

exit 0
