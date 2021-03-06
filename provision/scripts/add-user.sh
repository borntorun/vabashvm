#!/bin/bash

## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## This script permits to add a user to the system
##
## $1 - username
##		user will be in wheel group and in the sudoers file
## 
## This script was tested sucessfully in:
## 		CentOS 7 (64bit)
## ======================================================================

# if an error occurs stops
set -e

: ${_thispackage="Adding user"}
: ${_thisfilename=${0##*/}}
printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:Running [%s]..." "$0"
#printf -- "[%s]-" $*
output()
{
	(printf "\n\t$(date +"%H:%M:%S"):==>$_thispackage:";	printf "$@")
}

if [[ $# -eq 1 ]] && [[ ! -z $1 ]]
then

	if id -u "$1" >/dev/null 2>&1; then
		output "User [$1] already exists.\n"
	else
		useradd -m -G wheel "$1"
		#set passwd equal to login
		echo "$1"$'\n'"$1"$'\n' | passwd "$1"
				
		## Give user permissions to exec sudo with no passwd:
		##
		## - create a script that allows sudoers be edited with visudo in an automated way
		cat <<EOF >> /tmp/vabashvm-provision-user-sudoers.sh
#!/bin/bash

#Edit sudoers with visudo credits to Brian Smith here:
#https://www.ibm.com/developerworks/community/blogs/brian/entry/edit_sudoers_file_from_a_script4?lang=en

set -e

if [ ! -z "\$1" ]; then
		echo "$1        ALL=(ALL)       NOPASSWD: ALL" >> \$1        
else
		export EDITOR=\$0
		visudo
fi
EOF
		if [[ -e /tmp/vabashvm-provision-user-sudoers.sh ]]
		then
			## Run the script
			chmod u+x /tmp/vabashvm-provision-user-sudoers.sh
			/tmp/vabashvm-provision-user-sudoers.sh
			rm -f /tmp/vabashvm-provision-user-sudoers.sh
			##
		fi
	fi
else
	output "User not provided."
fi

printf "\nvabashvm:$(date +"%H:%M:%S"):==>$_thispackage:End [%s]." "$0"

exit 0
