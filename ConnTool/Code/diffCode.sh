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
for FILE in `ls SOM*.m` ; do echo " * * * * * * $FILE * * * * * " ;  diff $FILE $THATDIR ; done

echo
echo Comparing stuff in $THATDIR to things in $THISDIR
echo
cd $THATDIR
for FILE in `ls SOM*.m` ; do echo " * * * * * * $FILE * * * * * " ;  diff $FILE $THISDIR; done

cd $THISDIR

