#!/bin/bash

THISDIR=`pwd`
THATDIR=/Volumes/ALS/Software/SOMWork/SOMBen/SOM

if [ ! -z "$1" ]
then
    THATDIR=$1
fi

echo
echo Comparing stuff in $THISDIR to things in $THATDIR
echo
cd $THISDIR
for FILE in `ls *.m` 
do 
    echo -n " * * * * * * $FILE * * * * * " 
    Z=`diff -w $FILE $THATDIR` 
    if [ ! -z "$Z" ]
    then
	Z1=`echo $Z | grep "No such file" | wc -l`
	if [ ${Z1} -ne 0 ]
	then
	    echo -n " MISSING in target"
	else
	    Z1=`echo $Z | wc -l`
	    echo -n " $Z1 differences"
	fi
    fi
    echo
done

echo
echo Comparing stuff in $THATDIR to things in $THISDIR
echo
cd $THATDIR
for FILE in `ls *.m` 
do
    echo -n " * * * * * * $FILE * * * * * " 
    Z=`diff -w $FILE $THISDIR` 
    if [ ! -z "$Z" ]
    then
	Z1=`echo $Z | grep "No such file" | wc -l`
	if [ ${Z1} -ne 0 ]
	then
	    echo -n " MISSING in target"
	else
	    Z1=`echo $Z | wc -l`
	    echo -n " $Z1 differences"
	fi
    fi
    echo
done

cd $THISDIR

