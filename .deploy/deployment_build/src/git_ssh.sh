#!/bin/sh

thisdir=`pwd`
mcRoot=${thisdir}/../../..
idfile=${mcRoot}/.local/deploy

ssh -i ${idfile} $@