#!/bin/bash

# Find out where the current command lives and execute some common code.

theCommand=`which $0`
thisDir=`dirname $theCommand`

# Bring in the global definitions that all of these
# routines need.
#

. ${thisDir}/spm8Batch_Global

#
# a command to mail myself something.
#

if [ "$#" -lt "4" ] 
then
    USERNAME=${DEFAULTUSER}
else
    USERNAME=$4
fi

ATSIGN=`echo ${USERNAME} | grep "@"`
if [ -z "${ATSIGN}" ]
then
    EMAILDEST="${USERNAME}@${MAILRECPT}"
else
    EMAILDEST="${USERNAME}"
fi

# Get the job status

if [ -z "$3" ] 
then
    JOBSTATUS=SUCCESSFUL
else
    JOBSTATUS=$3
fi

echo "theDate=\`date\`"                                                  >> $2
echo "mail -s 'spm8Batch:$1:${JOBSTATUS}' ${EMAILDEST} <<EOF"            >> $2
echo "$1 job status:${JOBSTATUS} at \${theDate} on host ${HOSTNAME}"     >> $2
echo "EOF"                                                               >> $2

# 
# all done
#
