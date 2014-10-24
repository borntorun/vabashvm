#!/bin/bash

## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho 
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================
## Run configuration scripts to provision the vm
##
## $1 - path to folder where scripts are located
## 
## This script was tested sucessfully in:
## 		CentOS 7
## ======================================================================

# if an error occurs stops
#set -e

: ${_vabashvm="\nvabashvm:==>"}

printf "${_vabashvm}Running config script (config.sh)..."

remote_path=$1
#printf "${_vabashvm}%s\n" "$remote_path"

for file in ${remote_path}vabashvm-provision-*
do

	isargs=$(echo $file | grep ".args$")
	[[ ! -z $isargs ]] && continue

	#printf "${_vabashvm}%s\n" "$file"

	if [[ -f $file ]]
	then
		array_args=()
		## get parameters if exists
		if [[ -f ${file}.args ]]
		then
			##IFS=$'\r\n'                              #read -d '' -r -a array_args < "$file.args"
			##array_args=($(cat "${file}.args"))
			mapfile -t <"${file}.args"
		fi
		#printf "${_vabashvm}[%s]\n" "${MAPFILE[@]}"
		## veriry type os script
		echo $file | grep "\-user\-" >/dev/null
		result=$?

		if [[ $result -eq 0 ]]
		then
			## first arg is username for which running script as
			if [[ ! -z ${MAPFILE[0]} ]]
			then
				sudo -u "${MAPFILE[0]}" -H "$file" "${MAPFILE[@]}"
			fi
		else
			## run script normal
			sh "$file" "${MAPFILE[@]}"			
		fi
	fi
done

printf "${_vabashvm}Terminating config script (config.sh)."

exit 0