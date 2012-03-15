#!/bin/sh

thisdir=`pwd`

mcroot={$thisdir}/../..

export GIT_SSH=${thisdir}/git_ssh.sh

git reset HEAD --hard

git pull origin develop

git checkout develop

