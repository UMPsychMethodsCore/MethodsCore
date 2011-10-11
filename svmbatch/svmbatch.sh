#!/bin/sh

#List of some useful variables


filelist1=`cat filelist1`
filelist2=`cat filelist2`
svmdir=`cat svmdir`



3dbucket -sessiondir $svmdir -prefixname bucket1 $filelist1
3dbucket -sessiondir $svmdir -prefixname bucket2 $filelist2

cd $svmdir

3dbucket -prefixname bucket bucket1 bucket2

3dcalc -a bucket -expr "a" -prefixname shortbucket -datum short

3dTcat -prefix timeshortbucket shortbucket

for i in $filelist1
do
echo 1 >>labels.1D
done

for i in $filelist2
do
echo 2 >> labels.1D
done

3dAutomask timeshortbucket

3dsvm -trainvol timeshortbucket -trainlabels labels.1D -mask automask -model model -bucket bucket

