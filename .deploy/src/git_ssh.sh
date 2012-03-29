#!/bin/sh

thisdir=`dirname $0`

idfile=$thisdir/../../.local/deploy

ssh -i ${idfile} $@