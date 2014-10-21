#!/bin/bash

# if an error occurs stops
#set -e

printf "\nRunning config script (config.sh)...\n"

remote_path=$1
printf "%s\n" "$remote_path"

for file in ${remote_path}vabashvm-provision-*
do

	isargs=$(echo $file | grep ".args$")
	[[ ! -z $isargs ]] && continue

	#printf "%s\n" "$file"

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
		#printf "[%s]\n" "${MAPFILE[@]}"
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

printf "\nTerminating config script (config.sh).\n"

exit 0