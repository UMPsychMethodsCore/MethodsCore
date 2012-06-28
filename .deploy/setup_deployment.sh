#!/bin/sh

thisdir=`dirname $0`


# Add universe remote
git remote add github/universe git@github.com:UMPsychMethodsCore/MethodsCore

# Copy hooks
cp $thisdir/src/post-checkout $thisdir/../.git/hooks


#Make .local directory if it doesn't exist, and add deployment
mkdir -p ${thisdir}/../.local

#Mark this as a deployment
touch $thisdir/../.local/deployment

#Add file to indicate which branch should be updated by self-checkout
echo public > $thisdir/../.local/branch

#Make keyfiles
ssh-keygen -f $thisdir/../.local/deploy -N ""

#Do a checkout to create CurrentVersionSHA
git checkout HEAD
