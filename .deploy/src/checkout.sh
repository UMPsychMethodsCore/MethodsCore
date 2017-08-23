#!/bin/sh

#Grab Current Root
mcRoot=`pwd`  #Since this is called from post-checkout hook, working directory will be top of work tree unless changed in hook

mkdir -p .local

#Check if in detached head state
headContent=`grep ref: .git/HEAD`

#Identify Current Version
if [ -z "$headContent" ]
then
    cat .git/HEAD > .local/CurrentVersionSHA
else
    cat .git/`cat .git/HEAD | awk '{print $NF}'` > .local/CurrentVersionSHA
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
	sed -i'.bak' -e "/%DEVSTART/,/%DEVSTOP/ d; s:%\[DEVmcRootAssign\]:mcRoot = \'$mcRoot\':; s:%\[DEVmcRoot\]:$mcRoot:" $file
	rm ${file}.bak
    done
fi
