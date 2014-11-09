#!/bin/bash

## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Install Node.js global via packager manager
## RHEL, CentOS and Fedora
## as described in https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager#enterprise-linux-and-fedora
##
## This script was tested sucessfully in:
## 		CentOS 7 (64bit)
## ======================================================================

: ${_thispackage="System update"}
: ${_thisfilename=${0##*/}}
printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:Running [%s]..." "$0"
#printf -- "[%s]-" $*
output()
{
	(printf "\n\t$(date +"%H:%M:%S"):==>$_thispackage:";	printf "$@")
}
yum -y update >/dev/null
[[ ! $? -eq 0 ]] && output "Failed!" || {
	output "System updated"
	_numero=$(yum history | head -4 | tail -1 | awk '{printf $1}')
	(yum history info $_numero | grep -qi "Install kernel" || yum history info $_numero | grep -qi "Updated kernel") && {
		output "Kernel updated. Installing kernel-devel..."
		yum -y install gcc kernel-devel kernel-headers >/dev/null

#cat <<EOF >xpto-vabashvm-provision-000-asap-vboxguestadditions.sh
#: \${_thispackage="Setup vboxguestaddtions"}
#: \${_thisfilename=\${0##*/}}
#printf "\nvabashvm:\$(date +"%H:%M:%S"):==>\$_thispackage:Running [%s]..." "\$0"
#output()
#{
#	(printf "\n\t\$(date +"%H:%M:%S"):==>\$_thispackage:";	printf "\$@")
#}
#output "Setup VirtualBox Guest Additions..."
#\$(find / -name vboxadd | grep "init/vboxadd") setup 2>/dev/null
#EOF
	}
}

printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:End [%s]." "$0"

exit 0