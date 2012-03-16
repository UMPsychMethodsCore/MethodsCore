#!/bin/sh



thisdir=`dirname $0`

origdir=`pwd`
cd $thisdir
harddir=`pwd`
cd $origdir

export GIT_SSH=${harddir}/git_ssh.sh

branch=`cat $thisdir/../../.local/branch`

git reset HEAD --hard

git pull github/universe $branch:$branch

git checkout $branch

