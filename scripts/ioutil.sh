## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================

: ${ioutil_quiet=1}
: ${ioutil_now=$(date +"%Y%m%d%-H%M")}
: ${ioutil_errorfile="$1.$ioutil_now"}
: ${ioutil_logfile="$2.$ioutil_now"}

#echo $ioutil_quiet
#echo $ioutil_now
#echo $ioutil_errorfile
#echo $ioutil_logfile

ioutil_save_stdioerror()
{
	# Save std output/error
	if [[ $ioutil_quiet = 0 ]]
	then
		exec 4>&2
		exec 2>$ioutil_errorfile
	
		exec 3>&1
		exec 1>$ioutil_logfile
	fi
	
	# Redirect std error to error file
	
}
ioutil_restore_stdioerror()
{
	# Restore original stdout/stderr
	if [[ $ioutil_quiet = 0  ]]
	then
		exec 2>&4
		exec 4>&-

		exec 1>&3
		exec 3>&-
	fi 
	
}

# Print to the output that is defined
# - to log messages to whatever output is defined
ioutil_output()
{
	(printf "\n$ioutil_package";	printf "$@")
}
# Force print output to original stdout
# - to log messages always to the original stdout
ioutil_output_force()
{
	[[ $ioutil_quiet = 0  ]] && (printf "\n$ioutil_package";	printf "$@") 1>&3 || ioutil_output "$@"
}
# Print output to original stdout only if quiet is on
# - to log messages to the original stdout (if output is not redirect message will not be written anywhere)
# - this may be used if quiet mode is on, and because output of some command will no be visible on screen, we can always report some related information to the screen that we dont want to log on file
ioutil_output_notsoforce()
{
	[[ $ioutil_quiet = 0  ]] && (printf "\n$ioutil_package";	printf "$@") 1>&3
}
# Print to both (redirected if exists AND to original stdout)
# - self-explained...
ioutil_output_both()
{
	[[ $ioutil_quiet = 0  ]] && (ioutil_output "$@" && (printf "\n$ioutil_package";	printf "$@") 1>&3) || ioutil_output "$@"	
}
ioutil_set_quiet()
{
	if [[ ! $ioutil_quiet -eq 0 ]]
	then
		ioutil_quiet=0
		ioutil_save_stdioerror
		local set_quiet_now_aux=$(date +"%Y%m%d%-H%M")
		ioutil_output "$set_quiet_now_aux:$@\n"
		printf "$set_quiet_now_aux:$@\n" 1>&2
		
	fi
}
ioutil_unset_quiet()
{
	if [[ $ioutil_quiet -eq 0 ]]
	then
		ioutil_restore_stdioerror
		ioutil_quiet=1
		cp "$ioutil_errorfile" "${ioutil_errorfile%/*}/error.last"
		cp "$ioutil_logfile" "${ioutil_logfile%/*}/log.last"
	fi
}

# To be called when an error must forced script to stop
ioutil_exit_onerror()
{
	[[ $# -gt 0 ]] && ioutil_output_both "$@"
	
	ioutil_output_both "Script is terminating with error."
	
	[[ $ioutil_quiet = 0  ]] &&  ioutil_output_force "You can find more information below or by consulting the log files:\nError file:\t[%s]\nLog file:\t[%s]\n" "$ioutil_errorfile" "$ioutil_logfile"
	
	ioutil_unset_quiet		
			
	exit 1
}


ioutil_exit_onterminating()
{
	[[ $# -gt 0 ]] && ioutil_output_both "$@"
	
	ioutil_output_both "Terminating."
	
	ioutil_unset_quiet	
				
	exit 1
}

ioutil_exit_onsucess()
{
	[[ $# -gt 0 ]] && ioutil_output_both "$@"
	
	ioutil_output_both "End."
	
	ioutil_unset_quiet	
				
	exit 0
}

ioutil_set_package()
{
	: ${ioutil_package="$1:==>"}	
}