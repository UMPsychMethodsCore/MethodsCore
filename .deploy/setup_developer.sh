#!/bin/sh

thisdir=`dirname $0`

#Copy hooks
cp $thisdir/src/post-checkout $thisdir/../.git/hooks