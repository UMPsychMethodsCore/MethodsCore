#!/bin/sh

#Grab Current Root
mcRoot=`pwd`

#Make sure .local directory exists
mkdir -p .local

#Identify Current Version
cat .git/`cat .git/HEAD | awk '{print $NF'}` > .local/CurrentVersionSHA

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