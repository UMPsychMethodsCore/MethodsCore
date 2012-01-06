#!/bin/bash

#A program to reorganize permutation test results from svmbatch for later processing

permdir='/net/data4/MAS/SVM/FIR_6_10_perms/perms'  #String pointing to location of the permutation test directories

targetdir='/net/data4/MAS/SVM/FIR_6_10_perms/perms_analyze/' #where you want to put your files after conversion

cd $permdir

weights=`find -name "weight*HEAD"` #get a list of all your weight buckets

mkdir $targetdir

let "i=1"

for w in $weights; do
    3dAFNItoANALYZE -4D $targetdir/$i $w
    let "i=$i+1"
done
