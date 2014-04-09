#!/bin/bash
#
# A little script to discard the first 2/3 volumes
# of any run. It will run recursively
# looking for files that end in 0001-0002/3
#
# Modified to look for NIFTI images (.nii or .nii.gz)
# 2011 April 18
#
# Copyright Robert C. Welsh, Ann Arbor Michigan. 2005-2011
# 

theDIRS=""

searchDir=$1

if [ -z "$1" ]
then
    echo "Usage:"
    echo 
    echo "   findVols.sh directory_name [volumeWILD [subdir]"
    echo ""
    echo "       e.g. findVols.sh 050128mh ravol"
    echo
    exit 0
fi

if [ -z "$2" ]
then
    echo "Usage:"
    echo 
    echo "   findVols.sh directory_name volumeWILD [subdir]"
    echo ""
    echo "       e.g. findVols.sh 050128mh raprun"
    echo
    exit 0
fi

if [ ! -d $searchDir ]
then
    exit
fi

# Bugger out if anatomy directory.
if [ $searchDir == "anatomy" ]
then
   exit
fi

cd $searchDir

if [ ! -z $4 ]
then
    PWD=`pwd `
    echo "1: ${PWD}, 1:$1, 2:$2, 3:$3, 4:$4"  >> ${HOME}/debug_findVols2.log
fi


# How many images (.nii only) are in this directory?

nIMGS=`ls $2*.nii 2> /dev/null | wc |  awk '{print $1}'`
if (( $nIMGS > 0 ))
then
    thisDIR=`pwd`
    if [ -z "$3" ]
    then
	theDIRS=${theDIRS},${thisDIR}
    else
	yesno=`echo $thisDIR | grep $3`
	if [ ! -z "$yesno" ]
	then
	    theDIRS=${theDIRS},${thisDIR}
	fi
    fi
fi

if [ ! -z $4 ]
then
    PWD=`pwd `
    echo "2: ${PWD}, 1:$1, 2:$2, 3:$3, 4:$4" >> ${HOME}/debug_findVols2.log
fi

# Become recursive for the other directories present.
for newDIR in `ls -1 2> /dev/null`
do
    if [ ! -z $4 ]
    then
	PWD=`pwd `
	echo "3: ${PWD}, 1:$1, 2:$2, 3:$3, 4:$4" >> ${HOME}/debug_findVols2.log
    fi
    if [ -d "${newDIR}" ]
    then
	if [ ! -z $4 ]
	then
	    PWD=`pwd `
	    echo "4: ${PWD}, 1:$1, 2:$2, 3:$3, 4:$4, newDIR:${newDIR}" >> ${HOME}/debug_findVols2.log
	fi
	foundDIR=`findVols2.sh $newDIR $2 $3 $4 | tail -1`
	if [ ! -z "${foundDIR}" ]
	then
	    theDIRS=${theDIRS},${foundDIR}
	fi
	if [ ! -z $4 ]
	then
	    PWD=`pwd `
	    echo "5: ${PWD}, 1:$1, 2:$2, 3:$3, 4:$4" >> ${HOME}/debug_findVols2.log
	fi
    fi
done

tmpDIRS=`echo $theDIRS | sed 's/,,/,/g'`
theDIRS=$tmpDIRS

echo $theDIRS

#
# All done.
#
