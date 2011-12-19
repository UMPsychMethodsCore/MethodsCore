#!/bin/bash

#A program to reorganize permutation test results from svmbatch for later processing

permdir=  #String pointing to location of the permutation test directories

targetdir= #where you want to put your files after conversion

cd $permdir

weights=`find -name "weight*HEAD"` #get a list of all your weight buckets

let "i=1"

for w in $weights; do
    3dAFNItoANALYZE -4D $targetdir/$i $w
    let "i=$i+1"
done
