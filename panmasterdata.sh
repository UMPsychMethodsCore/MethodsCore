#!/bin/bash

thisdir=`pwd`

R --vanilla &>$thisdir/logs/R.log <<EOF
$thisdir/rsrc/MasterDataProcessor.R
EOF
