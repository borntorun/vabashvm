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

save_stdioerror()
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
restore_stdioerror()
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
output()
{
	(printf "\n$ioutil_package";	printf "$@")
}
# Force print output to original stdout
# - to log messages always to the original stdout
output_force()
{
	[[ $ioutil_quiet = 0  ]] && (printf "\n$ioutil_package";	printf "$@") 1>&3 || output "$@"
}
# Print output to original stdout only if quiet is on
# - to log messages to the original stdout (if output is not redirect message will not be written anywhere)
# - this may be used if quiet mode is on, and because output of some command will no be visible on screen, we can always report some related information to the screen that we dont want to log on file
output_notsoforce()
{
	[[ $ioutil_quiet = 0  ]] && (printf "\n$ioutil_package";	printf "$@") 1>&3
}
# Print to both (redirected if exists AND to original stdout)
# - self-explained...
output_both()
{
	[[ $ioutil_quiet = 0  ]] && (output "$@" && (printf "\n$ioutil_package";	printf "$@") 1>&3) || output "$@"	
}
set_quiet()
{
	if [[ ! $ioutil_quiet -eq 0 ]]
	then
		ioutil_quiet=0
		save_stdioerror
		set_quiet_now_aux=$(date +"%Y%m%d%-H%M")
		output "$set_quiet_now_aux:$@\n"
		printf "$set_quiet_now_aux:$@\n" 1>&2
		
	fi
}
unset_quiet()
{
	if [[ $ioutil_quiet -eq 0 ]]
	then
		restore_stdioerror
		ioutil_quiet=1
		cp $ioutil_errorfile "${ioutil_errorfile%/*}/error.last"
		cp $ioutil_logfile "${ioutil_logfile%/*}/log.last"
	fi
}

# To be called when an error must forced script to stop
exit_onerror()
{
	[[ $# -gt 0 ]] && output_both "$@"
	
	output_both "Script is terminating with error."
	
	[[ $ioutil_quiet = 0  ]] &&  output_force "You can find more information below or by consulting the log files:\nError file:\t[%s]\nLog file:\t[%s]\n" "$ioutil_errorfile" "$ioutil_logfile"
	
	unset_quiet		
	#[[ $ioutil_quiet = 0  ]] && [[ -f $ioutil_errorfile ]] && output_force "\n\n$ioutil_errorfile\n----------\n\n" && cat "$ioutil_errorfile"
			
	exit 1
}


exit_onterminating()
{
	[[ $# -gt 0 ]] && output_both "$@"
	
	output_both "Terminating."
	
	unset_quiet	
				
	exit 1
}

exit_onsucess()
{
	[[ $# -gt 0 ]] && output_both "$@"
	
	output_both "End."
	
	unset_quiet	
				
	exit 0
}

set_package()
{
	: ${ioutil_package="$1:==>"}	
}