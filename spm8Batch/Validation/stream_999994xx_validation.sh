#!/bin/bash
#
#
# Robert C. Welsh
#
# Copyright 2013
# 
# This stream is for testing the spm8Batch system
# To run this you should be in a directory with the 999994xx subject
# folder just below you. Then issue the command
#
# nohup ./stream_999994xx_validation.sh &> stream_999994xx_validation.log &
# 
# It will take about 15-20 minute to run, longer if you have a slower
# machine. 
# 
# Then take a look at the log and look for any errors.
#

SUBJECT=999994xx

LOCAL_LOG=full_stream_${SUBJECT}_validation.log

THEDATE=`date`

echo 
echo Start $THEDATE
echo

THISDIR=`pwd`
export UMSTREAM_STATUS_FILE=${THISDIR}/${SUBJECT}_validation_umstream_status_file

let STAGE=0

let STAGE++
PSTAGE=`echo $STAGE | awk '{printf "%02d",$1}'`
echo 
echo "* * * * * * *sliceTime8 * * * * * * *"
echo 
sliceTime8 -M ./ ${SUBJECT} -v run_ -n a8_ -B &> ${PSTAGE}_${LOCAL_LOG}
cat ${UMSTREAM_STATUS_FILE}

let STAGE++
PSTAGE=`echo $STAGE | awk '{printf "%02d",$1}'`
echo 
echo "* * * * * * *realignfMRI * * * * * * *"
echo 
realignfMRI -M ./ ${SUBJECT} -v a8_run_ -n r -A -O realign_a8 -B &> ${PSTAGE}_${LOCAL_LOG}
cp ${SUBJECT}/func/realign_a8.nii ${SUBJECT}/func/run_01/
cat ${UMSTREAM_STATUS_FILE}

let STAGE++
PSTAGE=`echo $STAGE | awk '{printf "%02d",$1}'`
echo
echo "* * * * * * *coregOverlay* * * * * * "
echo
coregOverlay -w coReg_a8 -M ./ ${SUBJECT} -v realign_a8 -o ht1overlay -B &> ${PSTAGE}_${LOCAL_LOG}
cat ${UMSTREAM_STATUS_FILE}

let STAGE++
PSTAGE=`echo $STAGE | awk '{printf "%02d",$1}'`
echo
echo "* * * * * * *coregHiRes* * * * * * "
echo
coregHiRes -w coReg_a8 -M ./ ${SUBJECT} -o ht1overlay -h ht1spgr -B &> ${PSTAGE}_${LOCAL_LOG}
cat ${UMSTREAM_STATUS_FILE}

let STAGE++
PSTAGE=`echo $STAGE | awk '{printf "%02d",$1}'`
echo
echo "* * * * * * *newSeg* * * * * * "
echo
newSeg -a func/coReg_a8 -w func/coReg_a8/newSeg -M ./ ${SUBJECT} -h ht1spgr -I r3mm_avg152T1 -n wns3mm_ -B &> ${PSTAGE}_${LOCAL_LOG}
cat ${UMSTREAM_STATUS_FILE}

let STAGE++
PSTAGE=`echo $STAGE | awk '{printf "%02d",$1}'`
echo
echo "* * * * * * *warpfMRI* * * * * * "
echo
warpfMRI -W -w coReg_a8/newSeg -M ./ ${SUBJECT} -h ht1spgr -v ra8_run_ -n wns3mm_ -I r3mm_avg152T1 -B &> ${PSTAGE}_${LOCAL_LOG}
cat ${UMSTREAM_STATUS_FILE}

let STAGE++
PSTAGE=`echo $STAGE | awk '{printf "%02d",$1}'`
echo
echo "* * * * * * *pcafMRI* * * * * * "
echo
pcafMRI -w coReg_a8/newSeg -M ./ ${SUBJECT} -v wns3mm_ra8_run_ -p 1 -B &> ${PSTAGE}_${LOCAL_LOG}
cat ${UMSTREAM_STATUS_FILE}

let STAGE++
PSTAGE=`echo $STAGE | awk '{printf "%02d",$1}'`
echo
echo "* * * * * * *vbm8HiRes* * * * * * "
echo
vbm8HiRes -a func/coReg_a8 -w func/coReg_a8/vbm8 -M ./ ${SUBJECT} -h ht1spgr -n vbm83mm_ -I r3mm_avg152T1 -B &> ${PSTAGE}_${LOCAL_LOG}
cat ${UMSTREAM_STATUS_FILE}

let STAGE++
PSTAGE=`echo $STAGE | awk '{printf "%02d",$1}'`
echo
echo "* * * * * * *warpfMRI* * * * * * "
echo
warpfMRI -W -w coReg_a8/vbm8 -M ./ ${SUBJECT} -h ht1spgr -v ra8_run_ -n vbm83mm_ -I r3mm_avg152T1 -B &> ${PSTAGE}_${LOCAL_LOG}
cat ${UMSTREAM_STATUS_FILE}

let STAGE++
PSTAGE=`echo $STAGE | awk '{printf "%02d",$1}'`
echo
echo "* * * * * * *pcafMRI* * * * * * "
echo
pcafMRI -w coReg_a8/vbm8 -M ./ ${SUBJECT} -v vbm83mm_ra8_run_ -p 1 -B &> ${PSTAGE}_${LOCAL_LOG}
cat ${UMSTREAM_STATUS_FILE}

echo
echo Finished
echo

echo Concatenating logs
echo
cat [0,1][0-9]_${LOCAL_LOG} > ${LOCAL_LOG}

echo
echo "Completed, full log can be found in ${LOCAL_LOG}"
echo

THEDATE=`date`

echo 
echo Done $THEDATE
echo

