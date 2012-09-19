#!/bin/sh

thisdir=`dirname $0`

#Copy hooks
cp $thisdir/src/post-checkout $thisdir/../.git/hooks

#Do a checkout to create CurrentVersionSHA
git checkout HEAD

git config core.filemode false
