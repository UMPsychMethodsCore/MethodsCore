#!/bin/sh



thisdir=`dirname $0` #Directory that contains this script

cd $thisdir
harddir=`pwd`


export GIT_SSH=${harddir}/git_ssh.sh

branch=`cat ${harddir}/../../.local/branch`

git reset --hard HEAD

git pull github/universe $branch:$branch

git checkout $branch
