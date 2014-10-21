#!/bin/bash

## This script permits to add a user to the system
## $1 - username 
##
## username will be in wheel group and in the sudoers file
## 
printf "Running [%s]...\n" "$0"
# if an error occurs stops
set -e

#if user already exists echo...
if id -u $1 >/dev/null 2>&1; then
	printf "User [$1] already exists\n"
else
	## Add the user and put it in wheel group 
	## 
	adduser -m -G wheel $1
	#set passwd equal to login
	echo $1$'\n'$1$'\n' | passwd $1
	#end
	
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
	## Run the script
	chmod u+x /tmp/vabashvm-provision-user-sudoers.sh
	/tmp/vabashvm-provision-user-sudoers.sh
	rm -f /tmp/vabashvm-provision-user-sudoers.sh
	##
fi

printf "Ending adding user [$1].\n"

exit 0