#!/bin/bash

#A program to perform SVM based only on lists of files

#CONSTANTS

#FUNCTIONS

function totembatch {
    #Given a filelist, suffixlist, and totem directory, loop over
    #combinations of filelist and suffixlist, and build totems

    totemsuf=`cat totem.suf`
    
    for  file in $1; do
	totemlist=  #Clear the totemlist variable. This will hold the list of all the subfiles going into your totem
	for suf in $totemsuf; do
		totemlist=`echo $totemlist $file/$suf` #loop over suffixes, and build up the list of subfiles
	done
	newname=`echo $file | sed 's:/:_:2g'` #edit the filename to have underscores instead of slashes, it will keep the temp directory cleaner
	fslmerge -z $totemtemp/$newname $totemlist  #use fsl to merge your subfiles in the z direction into totems
	newname=
    done
}


#Parameter Processing

totem=
crossv=
totemtemp=/tmp/totems #Where to store your totem files/examples


while [ "$1" != "" ]; do
    case $1 in
	-t | --totem )	totem=1  #Operate in totem stacking mode
			#shift
			#totemtemp=$1
			echo Running in Totem Mode
			;;
	-c | --crossv )	crossv=1;; #Will perform cross validation
	-k | --kernel ) kernelmode=1 #Kernel has been specified
			shift
			kernel=$1
			echo Kernel specified is $kernel
			;;
	-d | --directory ) shift ; svmdir=$1
			
    esac
    shift
done
       

##Main Function



#Read in variable values from associated files



filelist1=`cat filelist1`
filelist2=`cat filelist2`

if [ -f svmdir ]
then
    svmdir=`cat svmdir`
fi

if [ ! -d $svmdir ]
then
    mkdir $svmdir
fi

#if in totem mode

if [ "$totem" == 1 ]; 
    then
    mkdir $totemtemp
    totembatch "$filelist1"
    totembatch "$filelist2"

    filelist1=`cat filelist1 | sed -e 's:/:_:2g' -e 's:^:/'$totemtemp: -e 's:$:.hdr:'` #Update the filelist to point to where the totem-ed files are
    filelist2=`cat filelist2 | sed -e 's:/:_:2g' -e 's:^:/'$totemtemp: -e 's:$:.hdr:'`


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

#maskrule="-mask automask+orig"
if [ "$totem" = "1" ]
then
    maskrule="-nomodelmask"
fi

crossvrule="-x 1"
if [ "$crossv" = "1" ]
then
    crossvrule="-x 1"
fi

if [ "$kernelmode" = "1" ] #if running in kernel mode
then
	kernelrule="-kernel $kernel"
else
	kernelrule="-bucket weightbucket"
fi

#Run your 3dsvm model
3dsvm -trainvol timeshortbucket+orig -trainlabels labels.1D $maskrule -model model $kernelrule $crossvrule

if [ "$totem" = "1" ] #delete your temporary totem files, if they existed
then
    rm $totemtemp -rf
fi



##To add:
#1) Model testing (on training data itself, be sure to use set detrend to no
#2) Ability to automatically split examples into training and test set, and do cross validation randomly
#3) Permutation tests (basically just a for loop with random permutation of labels file. Tricky thing is querying test model weights against giant population of permutation weights
