
. isnumber.sh

for THING in a 1 a1 1.1 1.1.1 0.1
do
    isnumber $THING
    retVal=$?
    if [ "$retVal" == "0" ]
	then
	echo $retVal NUMBER $THING
    else
	echo $retVal NOTNUMBER $THING 
    fi
done

for THING in a b c 1 2 3 4 . 
do 
    isdigit $THING
    retVal=$?
    if [ "$retVal" == "0" ]
	then
	echo $retVal DIGIT $THING
    else
	echo $retVal NOTDIGIT $THING 
    fi
done
    
for THING in  1 2 1.1 1.1.1 0.1 4
do
    isinteger $THING
    retVal=$?
    if [ "$retVal" == "0" ]
	then
	echo $retVal INTEGER $THING
    else
	echo $retVal FLOAT $THING 
    fi
done

