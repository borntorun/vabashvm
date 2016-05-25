#!/bin/bash

## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install Samba amd configure an anonymous share as \\$HOSTNAME\Anonymous
##
## $1 - network workgroup
##
## This script was tested sucessfully in:
## 		CentOS 7 (64bit)
## ======================================================================

# if an error occurs stops
#set -e

: ${_thispackage="Samba"}
: ${_thisfilename=${0##*/}}
printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:Running [%s]..." "$0"
#printf -- "[%s]-" $*
output()
{
	(printf "\n\t$(date +"%H:%M:%S"):==>$_thispackage:";	printf "$@\n")
}

: ${vabashvm_workgroup=$1}
[[ -z $vabashvm_workgroup ]] && output "Error in parameters (1)." && exit 1

yum install -y samba samba-client samba-common >/dev/null 2>&1
[[ ! $? -eq 0 ]] && output "Error in installation (yum)." && exit 1

mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
tee /etc/samba/smb.conf <<EOF >/dev/null
[global]
workgroup = $vabashvm_workgroup
server string = Samba Server %v
netbios name = $HOSTNAME
security = user
map to guest = bad user
dns proxy = no
#============================ Share Definitions ==============================
[Anonymous]
path = /samba/anonymous
browsable = yes
writable = yes
guest ok = yes
read only = no
EOF

[[ ! $? -eq 0 ]] && output "Error in installation." || {
  #sudo chcon -u system_u -t samba_etc_t /etc/samba/smb.conf

  mkdir -p /samba/anonymous
  chmod -R 0755 /samba/anonymous/ && chown -R nobody:nobody /samba/anonymous/ && chcon -R -t samba_share_t /samba/anonymous/ && \
  firewall-cmd --permanent --zone=public --add-service=samba >/dev/null 2>&1 && firewall-cmd --reload >/dev/null 2>&1 && \
  systemctl enable smb.service >/dev/null 2>&1 && systemctl enable nmb.service >/dev/null 2>&1 && systemctl restart smb.service && systemctl restart nmb.service

  systemctl status smb.service | grep "Active: active (running)"
  [[ ! $? -eq 0 ]] && output "Error in installation." || {
    output "Samba installed."
  }

}

output "End ${0}"
#printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:End [%s]." "$0"

exit 0
