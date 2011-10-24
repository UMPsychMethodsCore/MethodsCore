#!/bin/bash

 
#Read in variable values from associated files
filelist1=`cat filelist1`
filelist2=`cat filelist2`
svmdir=`cat svmdir`

if [ ! -d $svmdir ]
then
    mkdir $svmdir
fi

#Build bucket files out of each of your conditions
3dbucket -sessiondir $svmdir -prefixname bucket1 $filelist1
3dbucket -sessiondir $svmdir -prefixname bucket2 $filelist2

#Change to the svm working directory (presumably where this script was called from)
cd $svmdir

#Combine your two class bucket files into one super bucket
3dbucket -prefixname bucket bucket1+orig bucket2+orig

#Convert your bucket file to shorts
3dcalc -a bucket+orig -expr "a" -prefixname shortbucket -datum short

#Convert your short bucket to be of type "time" (required by 3dsvm)
3dTcat -prefix timeshortbucket shortbucket+orig

#Build filelist by appending 1s or 2s to label file based on number in each class category

for i in $filelist1
do
echo 1 >>labels.1D
done

for i in $filelist2
do
echo 2 >> labels.1D
done

#Build a mask (in the future we may want to learn more about these options, or allow for specification of a custom mask
3dAutomask timeshortbucket+orig

#Run your 3dsvm model
if [ $1 == 1 ]
then
    3dsvm -trainvol timeshortbucket+orig -trainlabels labels.1D -mask automask+orig -model model -bucket weightbucket -x 1

else
    3dsvm -trainvol timeshortbucket+orig -trainlabels labels.1D -mask automask+orig -model model -bucket weightbucket

fi

##To add:
#1) Model testing (on training data itself, be sure to use set detrend to no
#2) Ability to automatically split examples into training and test set, and do cross validation randomly
#3) Permutation tests (basically just a for loop with random permutation of labels file. Tricky thing is querying test model weights against giant population of permutation weights