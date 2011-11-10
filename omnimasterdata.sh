#!/bin/bash

thisdir=`pwd`

R --vanilla &>$thisdir/logs/R.log <<EOF
source('$thisdir/rsrc/MasterDataProcessor.R',echo=TRUE)
q()
EOF
