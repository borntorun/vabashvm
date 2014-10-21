quiet=1
ioutil_now=$(date +"%Y%m%d%-H%M")
ioutil_errorfile="$1.$ioutil_now"
ioutil_logfile="$2.$ioutil_now"

save_stdioerror()
{
	# Save std output/error
	if [[ $quiet = 0 ]]
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
	if [[ $quiet = 0  ]]
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
	printf "$@"
}
# Force print output to original stdout
# - to log messages always to the original stdout
output_force()
{
	[[ $quiet = 0  ]] && printf "$@" 1>&3 || output "$@"
}
# Print output to original stdout only if quiet is on
# - to log messages to the original stdout (if output is not redirect message will not be written anywhere)
# - this may be used if quiet mode is on, and because output of some command will no be visible on screen, we can always report some related information to the screen that we dont want to log on file
output_notsoforce()
{
	[[ $quiet = 0  ]] && printf "$@" 1>&3
}
# Print to both (redirected if exists AND to original stdout)
# - self-explained...
output_both()
{
	[[ $quiet = 0  ]] && (output "$@" && printf "$@" 1>&3) || output "$@"	
}
set_quiet()
{
	if [[ ! $quiet -eq 0 ]]
	then
		quiet=0
		save_stdioerror
		set_quiet_now_aux=$(date +"%Y%m%d%-H%M")
		output "$set_quiet_now_aux:$@\n"
		printf "$set_quiet_now_aux:$@\n" 1>&2
		
	fi
}
unset_quiet()
{
	if [[ $quiet -eq 0 ]]
	then
		restore_stdioerror
		quiet=1
		cp $ioutil_errorfile "${ioutil_errorfile%/*}/error.last"
		cp $ioutil_logfile "${ioutil_logfile%/*}/log.last"
	fi
}

# To be called when an error must forced script to stop
exit_onerror()
{
	[[ $# -gt 0 ]] && output_both "\n$@"
	
	output_both "\n\nScript is terminating with error."
	
	[[ $quiet = 0  ]] &&  output_force "\nYou can find more information below or by consulting the log files:\nError file:\t[%s]\nLog file:\t[%s]\n" "$ioutil_errorfile" "$ioutil_logfile"
	
	unset_quiet		
	#[[ $quiet = 0  ]] && [[ -f $ioutil_errorfile ]] && output_force "\n\n$ioutil_errorfile\n----------\n\n" && cat "$ioutil_errorfile"
			
	exit 1
}


exit_onterminating()
{
	[[ $# -gt 0 ]] && output_both "\n$@"
	
	output_both "\n\nTerminating."
	
	unset_quiet	
				
	exit 1
}

exit_onsucess()
{
	[[ $# -gt 0 ]] && output_both "\n$@"
	
	output_both "\n\nEnd."
	
	unset_quiet	
				
	exit 0
}