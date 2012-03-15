#!/bin/sh

thisdir=`pwd`

#Make .local directory if it doesn't exist
mkdir -p ${thisdir}/../../.local

cd ${thisdir}/../.local
touch deployment
touch branch
ssh-keygen -f deploy -N ""