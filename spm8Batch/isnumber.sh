# # # # # # # # # # # # # #
#
# A routine to be called at 
# a script initialization to
# load in a function to determine if a 
# parameter is a valid number, 
# integer or float.
#
# Robert C. Welsh
# July 1, 2005
#
# # # # # # # # # # # # # #

SUCCESS=0
FAILURE=1

isdigit()
{
    #Success is measured as a zero!
	local -i int
	if [ $# -eq 0 ]
	then
		return $FAILURE
	else
		(let int=$1)  2>/dev/null
		return $?	# Exit status of the let thread
	fi
}

# New code for determining is an input is a number - 2012-07-27 - RCWelsh

isnumber ()   # Test if the parameter is a number (integer or float)
{
    retVal=1;
    # do it by trying to printf the number fo get error if bad
    printf "%2.2f" $1 2> /dev/null > /dev/null
    retVal=$?
    return $retVal
}

# Now check to see if an integer - just require no "."

isinteger () # return a zero is success
{
    Z=`echo $1 | grep -e "\."`
    if [ -z "$Z" ] 
	then
	return 0
    else
	return 1
    fi
}


