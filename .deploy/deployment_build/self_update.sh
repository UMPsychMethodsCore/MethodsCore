#!/bin/sh

thisdir=`pwd`

mcRoot={$thisdir}/../..

export GIT_SSH=${thisdir}/git_ssh.sh

releasebranch=`cat ${mcRoot}/.local/branch`

git reset $releasebranch --hard

git pull origin $releasebranch

git checkout $releasebranch

