#!/bin/bash
#
# A little script to discard the first 2/3 volumes
# of any run. It will run recursively
# looking for files that end in 0001-0002/3
#
# Modified to look for NIFTI images (.nii or .nii.gz)
# 2011 April 18
#
# Modified to accept a file extension for finding files.
# 2012 Dec 18
#
# Explicitly put in exclusion of directoy name of ANALYZE
#
# Copyright Robert C. Welsh, Ann Arbor Michigan. 2005-2011
# 
#

theDIRS=""

searchDir=$1

if [ -z "$1" ]
then
    echo "Usage:"
    echo 
    echo "   findVols.sh [directory name] [volumeWILD] [subdir] [fileextension]"
    echo ""
    echo "       e.g. findVols.sh 050128mh ravol"
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

# Default to using just nii, the calling program has responsbility to set to img

if [ -z "${4}" ]
then
    FILEXT=nii
else
    FILEXT=$4
fi

# How many images are in this directory?

nIMGS=`ls $2*.${FILEXT}* 2> /dev/null | wc |  awk '{print $1}'`
if (( $nIMGS > 0 ))
then
    #
    # Get the full path to the directory that contains
    # our files of interest.
    #
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

# Become recursive for the other directories present.
for newDIR in `ls -l 2> /dev/null | grep -e drw -e lrw | awk '{print $NF}'`
do
  if [ -d "${newDIR}" ]
      then
      if [ "${newDIR}" != "ANALYZE" ]
      then
	  foundDIR=`findVols.sh "$newDIR" "$2" "$3" "$FILEXT"`
	  if [ ! -z "${foundDIR}" ]
	  then
	      theDIRS=${theDIRS},${foundDIR}
	  fi
      fi
  fi
done

tmpDIRS=`echo $theDIRS | sed 's/,,/,/g'`
theDIRS=$tmpDIRS

echo $theDIRS

#
# All done.
#
