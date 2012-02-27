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

isnumber ()   # Test if the parameter is a number (integer or float)
{
    retVal=1;
    nPeriod=`echo $1 | awk -F . '{print NF}'`
    if [ "$nPeriod" -ne "1" -a "$nPeriod" -ne "2" ]
	then
	return $FAILURE
    fi
    theNumber=`echo $1 | sed 's/\.//g' `
    isdigit $theNumber
    retVal=$?
    if [ "$retVal" == "0"  ]
	then
	return $SUCCESS
    else
	return $FAILURE
    fi
}

