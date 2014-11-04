#!/bin/bash

## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================

script_name="vabashvm"
script_description="$script_name - Creation and Provision VM with VirtualBox and Vagrant\nhttps://github.com/borntorun/vabashvm"

## Global Config Environment
IFS="$(printf '\n\t')"
#
global_uname=$(uname)
global_path_local=$(pwd)
global_path_script="${BASH_SOURCE[0]}"
## while is a symbolic link follow path..
while [[ -h "$global_path_script" ]]; do
  cd "$(dirname "$global_path_script")"
  global_path_script="$(readlink "$global_path_script")"
done
global_path_script="$(cd -P "$(dirname "$global_path_script")" && pwd)"
#
cd "$global_path_local"
# PATH TO WHERE CREATE LOG FILES
global_path_log="$global_path_local/.log/"
# PATH TO UTIL SCRIPTS
global_path_utilscripts="$global_path_script/scripts/"
# PATH TO PROVISTION ENVIRONMENT
global_provision_path="${global_path_script}/provision/"
global_provision_path_scripts="${global_provision_path}/scripts/"
global_provision_filepackages="${global_provision_path}packages"
# PATH TO WHERE INIT VAGRANT VM
global_vms_path="$global_path_local/machines/"
global_vm_path="${global_vms_path}#vm#/"
global_vm_path_provision="${global_vm_path}provision/"
global_vm_path_provision_scripts="${global_vm_path_provision}scripts/"
global_vm_filepackages="${global_vm_path_provision}packages"
global_provision_dummy_file="${global_vm_path_provision}packages"
global_config_private_network=""
# PATH TO WHERE TO COPY THE PROVISION FILES IN THE VM GUEST
global_provision_remotepath="/tmp/"

printusage ()
{
	ioutil_output_force "\nUsage: $1 -b<box_name> [-r<url_remote_box>] [-m<vm_name>] [-g] [-q] [-h]\n\n"
	ioutil_output_force "%-25s-%s" "box_name" "mandatory! the name of vagrant box from which create the vm"	
	ioutil_output_force "%-25b-%b" "vm_name" "the name to give to the vm"
	ioutil_output_force "%-25b-%b" "url_remote_box" "the remote url from where to retrieve the vagrant box (not used yet...)"
	ioutil_output_force "%-25b-%b" "-q" "quiet mode (log messages and error output will be redirected to files in ./log/)"
	ioutil_output_force "%-25b-%b" "-g" "to update the virtual box guest additions on the guest system"
	ioutil_output_force "%-25b-%b" "-h" "show usage"
	exit 1
}
printdebug ()
{
	printf "%-35s:%s\n" "global_path_log" "$global_path_log"
	printf "%-35s:%s\n" "global_path_script"  "$global_path_script"
	printf "%-35s:%s\n" "global_path_utilscripts" "$global_path_utilscripts"

	printf "%-35s:%s\n" "global_provision_path"  "$global_provision_path"
	
	printf "%-35s:%s\n" "global_provision_path_scripts" "$global_provision_path_scripts"
	printf "%-35s:%s\n" "global_provision_filepackages" "$global_provision_filepackages"
	printf "%-35s:%s\n" "global_provision_dummy_file" "$global_provision_dummy_file"
	printf "%-35s:%s\n" "global_provision_remotepath" "$global_provision_remotepath"
	
	printf "%-35s:%s\n" "global_path_local" "$global_path_local"
	printf "%-35s:%s\n" "global_vms_path"  "$global_vms_path"
	printf "%-35s:%s\n" "global_vm_path" "$global_vm_path"
	printf "%-35s:%s\n" "global_vm_path_provision" "$global_vm_path_provision"
	printf "%-35s:%s\n" "global_vm_path_provision_scripts" "$global_vm_path_provision_scripts"
	printf "%-35s:%s\n" "global_vm_filepackages" "$global_vm_filepackages"

	printf "%-35s:%s\n" "global_config_private_network" "$global_config_private_network"
}
if [[ ! -d $global_path_log ]]
then
	mkdir "$global_path_log"
	[[ ! $? -eq 0 ]] && printf "\nScript can not continue. Can not create [%s] folder" "$global_path_log" && exit 1
fi

# Source Util Functions
source ${global_path_utilscripts}ioutil.sh "${global_path_log}error" "${global_path_log}log"
source ${global_path_utilscripts}util.sh

if [ $# -eq 0 ]  
then
  printusage "$script_name"
fi 

while getopts :b:m:r:hgq opt 
do
	case $opt in
	\?)	ioutil_output_force "\nInvalid options: -$OPTARG\n"
		printusage "$script_name"
		;;
	q)	auxquiet=1;;
	b)	[[ ! $vmbox ]] && vmbox="$OPTARG";;
	m)	[[ ! $vmname ]] && vmname="$OPTARG";;
	r)	[[ ! $vmboxurl ]] && vmboxurl="$OPTARG";;
	g)  [[ ! $vbguestupdate ]] &&  vbguestupdate=1;;	
	:)	ioutil_output_force "\nOption -$OPTARG requires an argument.\n"
		printusage		
		;;
	h)	#ioutil_output_force "Help:\n"
		printusage "$script_name"	
		;;
	esac
done

[[ $auxquiet ]] && ioutil_set_quiet "$script_description"

## Testing vagrant version
vagrant_version=$(vagrant -v | sed "s|Vagrant ||" | sed "s|\.||g")
([[ ! $? -eq 0 ]] || [[ ! $vagrant_version ]] || [[ $vagrant_version -lt 165 ]]) && ioutil_exit_onerror "\nVagrant v.>=1.6.5 must be installed"

## Validate parameters
[[ $vmname == -* ]] && ioutil_exit_onerror "\nName of vm (%s) is invalid." "$vmname"
[[ $vmbox == -* ]] && ioutil_exit_onerror "\nName of box (%s) is invalid." "$vmbox"
[[ ! $vmbox ]] && ioutil_exit_onerror "\nName of box (-b) must be specified."
[[ ! $vmname ]] && vmnameaux=$vmbox || vmnameaux=$vmname

# Set environment for vm
global_vm_path=$(echo "$global_vm_path" | sed "s|#vm#|$vmnameaux|")
global_vm_path_provision=$(echo "$global_vm_path_provision" | sed "s|#vm#|$vmnameaux|")
global_vm_path_provision_scripts=$(echo "$global_vm_path_provision_scripts" | sed "s|#vm#|$vmnameaux|")
global_vm_filepackages=$(echo "$global_vm_filepackages" | sed "s|#vm#|$vmnameaux|")

shift $(($OPTIND - 1))
#printf "Remaining arguments are: %s\n" "$*"

## Get other options
while test $# -gt 0
do
	#echo $1
    case "$1" in
		--update) update=1;;			
		--vbguestupdate) vbguestupdate=1;;			
    esac
    shift
done

copy_vagrantfile_template()
{
	## Copy Vagrantfile template to vm folder
	local aux_vagrantfile="${global_vm_path}Vagrantfile"
	cp "${global_provision_path}templates/$1" "${aux_vagrantfile}"
	[[ ! -f ${aux_vagrantfile} ]] && ioutil_exit_onerror "File [%s] could not be copied" "${global_provision_path}$1"
	
	[[ $vmname ]] && sed -i "s/^.*#vabashvm-vm-name#/\t\tv.name = \"$vmname/" "${aux_vagrantfile}"	
	sed -i "s|^.*#vabashvm-vm-box#|\tconfig.vm.box = \"$vmbox|" "${aux_vagrantfile}"	
	[[ $vmboxurl ]] && sed -i "s/^.*#vabashvm-vm-box#/#config.vm.box_url = \"$vmboxurl/" "${aux_vagrantfile}"
}
test_vagrantbox_exists()
{
	## Test is box was added to Vagrant boxes
	ioutil_output "Testing vagrant box..."
	vagrant box list | grep "$vmbox" >/dev/null
	[[ ! $? -eq 0 ]] && ioutil_exit_onerror "Vagrant box [%s] does not exists. Please add the box first." "$vmbox"	
}
test_vbguestplugin_exists()
{
	# Test if plugin vagrant-vbguest is installed (if not ask to install...)	
	ioutil_output "Testing vagrant-vbguest plugin..."

	vagrant plugin list | grep -q "vagrant-vbguest"
	[[ ! $? -eq 0 ]] && novbguestplugin=1
	
	if [[ $novbguestplugin ]]
	then
		ioutil_output_force "Plugin for virtual box guest additions vagrant-vbguest is not installed."
		ioutil_output_force "Do you want to install it? (y/n)"
		while :
		do
			read 
			case "$REPLY" in
				[Yy])
					ioutil_output_notsoforce "Installing plugin..."					
					vagrant plugin install vagrant-vbguest
					vagrant plugin list | grep "vagrant-vbguest" >/dev/null
					[[ $? -eq 0 ]] && unset novbguestplugin
					break
				;;
				[Nn]) 
					ioutil_output_both "Plugin vagrant-vbguest will not be installed."
					break
				;;
				*) ioutil_output_force "Please, reply (y or n)";;
			esac
		done
	fi
}
uncomment_line_vagrantfile() 
{
	## this function must receive a string to subst; the text is expected to be commenting a line like ex: #<text>#...rest of line
	## all what it does is subst that text with empty space...well with a tab to keep formating clean, removing the commnent
	sed -i "s/^.*$1/\t/" "${global_vm_path}Vagrantfile"
}
reportlineoutput()
{
	ioutil_output_both "\t%-25s:%s" "${@}"
}
report_wait_confirmation()
{
	# Everything seems ok, report and wait confirmation...	
	ioutil_output_both "Reporting:\n"	
	reportlineoutput "Folder will be created" "$global_vm_path"
	reportlineoutput "Vagrant Box to use" "$vmbox"
	[[ $vmname ]] && reportlineoutput "VM Name" "$vmname"
	[[ ! $vmname ]] && reportlineoutput "VM Name" "default name by vagrant"
	[[ $novbguestplugin ]] && reportlineoutput "Plugin vagrant-vbguest" "is not installed. VB Guest additions may not work properly."
	[[ $vbguestupdate ]] && [[ $novbguestplugin ]] && reportlineoutput "VB Guest Additions" "will ***NOT*** be updated. Install vagrant-vbguest plugin first."
	[[ $vbguestupdate ]] && [[ ! $novbguestplugin ]] && reportlineoutput "VB Guest Additions" "will be updated." 

	ioutil_output_force "Is this correct? (y/n)"	
	while :
	do
		read 	
		case "$REPLY" in
		[Yy]) 
			break;;
		[Nn]) ioutil_exit_onterminating "User choose to terminate script.";;
		*) ioutil_output_force "Please, reply (y or n)";;
		esac
		
	done
}
ioutil_set_package "$script_name"

test_vagrantbox_exists

test_vbguestplugin_exists

#printdebug

report_wait_confirmation

#If we get here Confirmation is ok...let's go...
ioutil_output_both "Creating machine...\n"

if [[ ! -d $global_vms_path ]]
then
	mkdir "$global_vms_path"
	[[ ! $? -eq 0 ]] && ioutil_exit_onerror "Script can not continue. Can not create [%s] folder" "$global_vms_path"
fi
# Create vm folder tree and go inside...
[[ -d $global_vm_path ]]  && ioutil_exit_onerror "Remove folder [%s] first " "$global_vm_path"
mkdir "$global_vm_path"
[[ ! $? -eq 0 ]] && ioutil_exit_onerror "Error creating folder [%s]" "$global_vm_path"
ioutil_output "Folder created: [%s]" "$global_vm_path"
mkdir "$global_vm_path_provision" 
[[ ! $? -eq 0 ]] && ioutil_exit_onerror "Error creating folder [%s]" "$global_vm_path_provision"
ioutil_output "Folder created: [%s]" "$global_vm_path_provision"
mkdir "$global_vm_path_provision_scripts" 
[[ ! $? -eq 0 ]] && ioutil_exit_onerror "Error creating folder [%s]" "$global_vm_path_provision_scripts"
ioutil_output "Folder created: [%s]\n" "$global_vm_path_provision_scripts"
cd "$global_vm_path"
[[ ! $? -eq 0 ]] && ioutil_exit_onerror "Error accessing folder [%s]" "$global_vm_path"

# Create Vagrantfile vm from box ... 
vagrant init "$vmbox" "$vmboxurl"
[[ ! $? -eq 0 ]] && ioutil_exit_onerror "Error vagrant init"
[[ ! -f ${global_vm_path}Vagrantfile ]] && ioutil_exit_onerror "Error init vagrant - no Vagrantfile"
mv "${global_vm_path}Vagrantfile" "${global_vm_path}Vagrantfile.original"
[[ ! -f ${global_vm_path}Vagrantfile.original ]] && ioutil_exit_onerror "Error #3 vagrant file original...."

convert_to_dospath()
{	
	## Convert posix path to windows (under several environments: for now supportted [MINGW32(git bash)])
	## - this is necessary for ruby to work when provisioning files to the vm guest
	## - use: some_var=$(convert_to_dospath "$somevar_with_path_to_convert")
	case $global_uname in
		MINGW32_NT*|MSYS_NT)
			local aux
			aux=$(echo "$1" | sed 's|^\/||')		
			aux=$(echo "$aux" | sed 's|\/|\\\\\\\\|g')		
			aux=$(echo "$aux" | sed 's|^.|\0:|')
			echo "$aux"						
			;;
		*)
			echo "$1"
			;;
	esac
}

vi_file()
{
	if [[ $auxquiet ]]
	then			
		vi "$1" 1>&3
	else		
		vi "$1"
	fi
}

provision_files()
{
	local i=1
	local filesource_provision
	local filedest_provision
	local file_name
	local args_file
	local args_file_dest
	local args_string
	local prefix	
	local typefiles	
		
	osfiles=( "$@" )
	#printf "Line:%s\n" "${osfiles[@]}"			
	
	for line in	"${osfiles[@]}"
	do
	
		typefiles="${line:1:1}"
		line=$(echo "$line" | sed "s|^+.:||")		
		file_name=$(echo "$line" | sed "s|:args.*$||g")
		
		case $typefiles in
			s) typefiles="sys";;
			u) typefiles="user";;
			p) typefiles="asap";;
			n) ## private network config
				args_string=$(echo "$line" | sed "s|^.*:args:||")
				#printf "%s\n" "$args_string"
				
				[[ -z $args_string ]] && continue
				
				local _netmask=$(echo "$args_string" | sed "s/^.*|//")
				local _ip=$(echo "$args_string" | sed "s/|.*$//")
				
				([[ ! $(util_isvalidip "$_ip") -eq 0 ]] || [[ ! $(util_isvalidip "$_netmask") -eq 0 ]]) && ioutil_output_force "Invalid format network config: [%s]" "$args_string" && continue
				
				global_config_private_network=${global_config_private_network}"\n\tconfig.vm.network \"private_network\", ip: \"${_ip}\", auto_config: true, netmask: \"${_netmask}\""
				
				continue
				;;
			*) ioutil_exit_onerror "Error in packages file";;
		esac

		printf -v idxprefix -- "-%03d-" "$i"
		printf -v prefix "vabashvm-provision$idxprefix$typefiles-"
		i="$(($i+1))"
		
		filesource_provision=$(convert_to_dospath "${global_provision_path_scripts}${file_name}")
		filedest_provision="${global_provision_remotepath}${prefix}${file_name}"
		
		args_file="${global_vm_path_provision_scripts}${idxprefix}${file_name}.args"
		args_file_dest="${filedest_provision}.args"
		
		## include file provision in Vagrantfile
		sed -i "s|^.*#vabashvm-file-source#|\tconfig.vm.provision \"file\", source: \"$filesource_provision\", destination: \"$filedest_provision\"\n\t#vabashvm-file-source#|" "${global_vm_path}Vagrantfile"			
		
		#printf "%s\n" "$line" "$typefiles" "$file_name" "$filesource_provision" "$filedest_provision" 
			
		args_string=$(echo "$line" | sed "s|^.*:args:||")
		
		if [[ ! -z $args_string ]] && [[ ! $args_string == $line ]]
		then
			##1.->## evaluate arguments inline
			args_string=$(echo "$args_string" | sed "s/|/\n/g")
			local IFS=$'\r\n'							
			printf "%s" "$args_string" >> "$args_file"				
			[[ ! $? -eq 0 ]] && ioutil_exit_onerror "Could not create args file [%s]" "$args_file"
			## to view/edit args file
			#vi_file "$args_file"
		else
			##2.->## evaluate arguments file
			##$(echo "$line" | grep ":args$")		#if result not empty script has args line
			local args_par=$(echo "$line" | grep ":args$")
			if [[ ! -z $args_par ]] 
			then
				## to view/edit args file
				vi_file "$args_file"
				([[ ! $? -eq 0 ]] || [[ ! -f $args_file ]]) && ioutil_exit_onerror "Could not create args file [%s]" "$args_file"				 
			fi
		fi
		if [[ -f  $args_file ]]
		then
			#printf "%s\n" "$args_file" "$args_file_dest"		
			
			## include file args provision in Vagrantfile
			sed -i "s|^.*#vabashvm-file-source#|\tconfig.vm.provision \"file\", source: \""$(convert_to_dospath "$args_file")"\", destination: \"$args_file_dest\"\n\t#vabashvm-file-source#|" "${global_vm_path}Vagrantfile"
		fi
	done		
}
provision_filesconfig()
{
	if [[ ! -f $global_vm_filepackages ]]
	then
		cp "${global_provision_filepackages}" "${global_vm_filepackages}"
		[[ ! $? -eq 0 ]] && ioutil_exit_onerror "Error copying file [%s]" "$global_provision_filepackages"
	fi
	## view/edit packages files
	vi_file "$global_vm_filepackages"	
}

provision_filesrun()
{
	local listpackages
	
	#version for bash v>4 ##mapfile -t listpackages < <(grep "^+s:\|^+u:" "$global_vm_filepackages" | sed "s|$1:||")
	
	## this IFS config extends to 'provision_files' function below
	local IFS=$'\r\n'
	
	listpackages=$(grep "$1" "$global_vm_filepackages")
		
	if [[ ! -z $listpackages ]]
	then
		#printf "File:%s\n" $listpackages	
		#provision_files "$2" $listpackages	
		provision_files $listpackages	
	fi
	
}

provision_software_packages()
{
	provision_filesrun "^+s:\|^+u:"
}

provision_priority_packages()
{
	provision_filesrun "^+p:"
}
provision_priority_network()
{
	provision_filesrun "^+n:"	
}

provision_priority_packages_check()
{
	grep -q "$1" "$global_vm_filepackages"
	([[ $? -eq 0 ]] && echo "0") || echo "1"
}

provision_global()
{
	sed -i "s|#vabashvm_global_path_provision_scripts#|"$(convert_to_dospath "${global_provision_path_scripts}")"|g" "${global_vm_path}Vagrantfile"
	sed -i "s|#vabashvm_path_to_vm_provision#|"$(convert_to_dospath "$global_vm_path_provision")"|g" "${global_vm_path}Vagrantfile"
	sed -i "s|#vabashvm_destination_provision_remotepath#|"$global_provision_remotepath"|g" "${global_vm_path}Vagrantfile"
	
	local dummy_file="vabashvm-provision-dummy" 
	
	sed -i "s|^.*#vabashvm-file-source#|\tconfig.vm.provision \"file\", source: \""$(convert_to_dospath "${global_provision_path_scripts}${dummy_file}")"\", destination: \"${global_provision_remotepath}${dummy_file}\"\n\t#vabashvm-file-source#|" "${global_vm_path}Vagrantfile"
	
	[[ ! -z $global_config_private_network ]] && sed -i "s|^.*#vabashvm-private-network#|\t${global_config_private_network}|" "${global_vm_path}Vagrantfile"
}
vagrant_final()
{
	## Final "boot" Vagrantfile-Final template
	## - this template is the one that will remain as the Vagrantfile to boot the machine for use
	copy_vagrantfile_template Vagrantfile-Final

	if [[ ! $novbguestplugin ]]
	then
		## plugin exists 
		(uncomment_line_vagrantfile "#vbguest.no_remote#" && uncomment_line_vagrantfile "#vbguest.auto_update_false#")
		[[ ! $? -eq 0 ]] && ioutil_exit_onerror "Error on config (2)"
	fi
	
	provision_global
	
	## no need to boot because didnt halt previous step
	#vagrant up --provision
	#[[ ! $? -eq 0 ]] && ioutil_exit_onerror "Error on boot up (F)"
	
}
vagrant_secondup()
{
	## Second boot Vagrantfile-2 template
	## - this template is the one that will boot the machine for provisioning... or not
	## - in case that there are no prority packages to run the 1st boot is skipped and this will be the first template (boot)
	copy_vagrantfile_template Vagrantfile-2

	if [[ ! $novbguestplugin ]]
	then
		## plugin exists 
		(uncomment_line_vagrantfile "#vbguest.no_remote#" && ( [[ $vbguestupdate ]]  && uncomment_line_vagrantfile "#vbguest.auto_update_true#" ) || ( uncomment_line_vagrantfile "#vbguest.auto_update_false#" ))
		[[ ! $? -eq 0 ]] && ioutil_exit_onerror "Error on config (2)"
	fi
	
	provision_global
	
	provision_software_packages
		
	## 2nd boot with provision
	vagrant up --provision
	[[ ! $? -eq 0 ]] && ioutil_exit_onerror "Error on boot up (2)"
	
	## dont need to halt the machine
	#vagrant halt
	#[[ ! $? -eq 0 ]] && ioutil_exit_onerror "Error on halt (2)"
	#	
	## Backup 2nd vagrantfile
	mv "${global_vm_path}Vagrantfile" "${global_vm_path}Vagrantfile.2"

}
vagrant_firstup()
{
	## First boot Vagrantfile-1 template
	## - this template will be used for provisioning the priority packages ex:to do a system update
	copy_vagrantfile_template Vagrantfile-1
	
	[[ "$prioritynetwork" == "0" ]] && provision_priority_network
	
	provision_global
	
	[[ "$prioritypack" == "0" ]] && provision_priority_packages
	
	if [[ ! $novbguestplugin ]]
	then
		(uncomment_line_vagrantfile "#vbguest.no_remote#" && uncomment_line_vagrantfile "#vbguest.auto_update_false#")
		[[ ! $? -eq 0 ]] && ioutil_exit_onerror "Error on config (1)"
	fi
	
	## 1st boot up
	vagrant up 
	[[ ! $? -eq 0 ]] && ioutil_exit_onerror "Error on boot up (1)"
	vagrant halt
	[[ ! $? -eq 0 ]] && ioutil_exit_onerror "Error on halt (1)"
	#
	## Backup 1st vagrantfile
	mv "${global_vm_path}Vagrantfile" "${global_vm_path}Vagrantfile.1"
}	

provision_filesconfig

prioritynetwork=$(provision_priority_packages_check "^+n:")

prioritypack=$(provision_priority_packages_check "^+p:")

([[ "$prioritynetwork" == "0" ]] || [[ "$prioritypack" == "0" ]]) && vagrant_firstup

vagrant_secondup

vagrant_final

ioutil_exit_onsucess "Machine [%s] is running..." "$vmname"

exit 0