#!/bin/sh



thisdir=`dirname $0` #Directory that contains this script

origdir=`pwd` #working directory from whence this script was called
cd $thisdir
harddir=`pwd`


export GIT_SSH=${harddir}/git_ssh.sh

branch=`cat $thisdir/../../.local/branch`

git reset HEAD --hard

git pull github/universe $branch:$branch

git checkout $branch

