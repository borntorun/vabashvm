## ======================================================================
## vabashvm - https://github.com/borntorun/vabashvm
## Author: João Carvalho
## https://raw.githubusercontent.com/borntorun/vabashvm/master/LICENSE
## ======================================================================

util_isvalidip() #@ USAGE: util_isvalidip DOTTED-QUAD 
{ 
	#this function credits: Pro Bash Programming by Chris F.A. Johnson http://cfajohnson.com/books/cfajohnson/pbp/
	case $1 in 
	## reject the following: 
	## empty string 
	## anything other than digits and dots 
	## anything not ending in a digit 
	"" | *[!0-9.]* | *[!0-9]) echo 1; exit ;; 
	esac 
	## Change IFS to a dot, but only in this function 
	local IFS=. 
	## Place the IP address into the positional parameters; 
	## after word splitting each element becomes a parameter 
	set -- $1 	
	[ $# -eq 4 ] && ## must be four parameters 
	## each must be less than 256 
	## A default of 666 (which is invalid) is used if a parameter is empty 
	## All four parameters must pass the test 
	[ ${1:-666} -le 255 ] && [ ${2:-666} -le 255 ] && 
	[ ${3:-666} -le 255 ] && [ ${4:-666} -le 255 ] && echo 0 && exit
	echo 1	
} 

#
#echo $(util_isvalidip 192.168.99.\))
#echo $(util_isvalidip 192.168.99.1999)
#echo $(util_isvalidip 192.168.9a.199)
#echo $(util_isvalidip 192.1z.99.1999)
#echo $(util_isvalidip 1a.168.99.1999)
#echo $(util_isvalidip 168.99.199)
#echo $(util_isvalidip 192.168.99.10)
