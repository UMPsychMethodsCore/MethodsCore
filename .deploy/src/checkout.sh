#!/bin/sh

#Grab Current Root
mcRoot=`pwd`

mkdir -p .local

#Check if in detached head state
headContent=`cat .git/HEAD`
colonLoc=`expr index "$headContent" :`

#Identify Current Version
if [ $colonLoc -eq 0 ]
then
    cat .git/HEAD > .local/CurrentVersionSHA
else
    cat .git/`cat .git/HEAD | awk '{print $NF'}` > .local/CurrentVersionSHA
fi

#spm8Batch Localizations
if [ -d .local/spm8Batch ]; then
    cp .local/spm8Batch/spm8Batch_Global .local/spm8Batch/spm8Setup spm8Batch
fi


# Replace specified wildcards from all files

if [ -f .local/deployment ]; then #Only run this if in a deployment
    templatelist=`find . -iname "*_mc_template*"`

    for file in $templatelist
    do
	sed -i -e '/%DEVSTART/,/%DEVSTOP/ d' \
	    -e "s:%\[DEVmcRootAssign\]:mcRoot = \'$mcRoot\':" \
	    -e "s:%\[DEVmcRoot\]:$mcRoot:"  \
	    $file
    done
fi
