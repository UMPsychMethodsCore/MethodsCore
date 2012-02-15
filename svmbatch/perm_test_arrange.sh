#!/bin/bash

#A program to reorganize permutation test results from svmbatch for later processing


#Parameter Processing

while [ "$1" != "" ]; do
    case $1 in
	-p)
	    shift
	    permdir=$1
	    
	    ;;
	-t)
	    shift
	    targetdir=$1
	    ;;
	*)
	    
    esac
    shift
done

cd $permdir

weights=`find -name "weight*HEAD"` #get a list of all your weight buckets

mkdir $targetdir

let "i=1"

for w in $weights; do
    3dAFNItoANALYZE -4D $targetdir/$i $w >/dev/null
    echo "Converting file $i"
    let "i=$i+1"
done
