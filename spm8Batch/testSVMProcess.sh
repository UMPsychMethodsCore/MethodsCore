#!/bin/bash
#
# Copyright Robert C. Welsh, 2010
# Ann Arbor MI
#

#
# Using 3dsvm of AFNI by S. Leconte process a subject/run
# for 3D SVM testing

#
# Inputs
# 
#  1 Subject name
#  2 Process flag = 1 if okay, 0 = abort
#  3 Test BRIK data
#  4 Model Directory
#  5 Output directory
#  6 Masking image
#  7 1D vector of on condition
#  8 1D vector of censor 
#### NO WE WON'T We will get 6, 7, and 8 from the modelInput.dat file.

if [ "$#" == "0" ] && [ "$#" != "8" ] 
then
    echo
    echo "testSVMProcess.sh"
    echo
    echo "#"
    echo "# Inputs"
    echo "# "
    echo "#  1 Subject name"
    echo "#  2 Process flag = 1 if okay, 0 = abort"
    echo "#  3 Test BRIK data"
    echo "#  4 Model directory"
    echo "#  5 Output directory"
    echo "#  6 Masking image"
    echo "#  7 1D vector of on condition"
    echo "#  8 1D vector of censor"
    echo
    exit
fi

if [ "$2" == "0" ]
then
    echo
    echo "Aborting"
    echo
    exit
fi

SUBJECT=$1
PROCESS=$2
TESTBRIK=$3
MODDIR=$4
OUTDIR=$5
MASK=$6
XON=$7
XCENSOR=$8


MASKHEAD=`echo ${MASK} | sed -e "s/\.BRIK/.HEAD/"`
TESTHEAD=`echo ${TESTBRIK} | sed -e "s/\.BRIK/.HEAD/"`

mkdir -p $OUTDIR

cd $OUTDIR

#if [ ! -d "${MODDIR}/modelInput.dat" ]
#then
#    echo 
#    echo "Need modelInput.dat in the training directory to proceeed"
#    echo
#    exit 0
#fi

#cp ${MODDIR}/modelInput.dat ./

#MASK=`grep "MASK=" modelInput.dat | awk -F= '{print $2}'`
#TRAIN=`grep "TRAIN=" modelInput.dat | awk -F= '{print $2}'`
#XCENSOR=`grep "XCENSOR=" modelInput.dat | awk -F= '{print $2}'`
#MODEL=`grep "MODEL=" modelInput.dat | awk -F= '{print $2}'`

echo "copying mask"
cp $MASK ./
echo "copying mask header"
cp $MASKHEAD ./
echo "copying test brik"
cp $TESTBRIK ./
echo "copying test head"
cp $TESTHEAD ./
echo "copying on"
cp $XON ./
echo "copying censor : ${XCENSOR}"
cp $XCENSOR ./

MASKNAME=`echo $MASK | awk -F/ '{print $NF}' | sed -e "s/\.BRIK//"`
LBRIK=`echo $TESTBRIK | awk -F/ '{print $NF}'  | sed -e "s/\.BRIK//"`
LON1D=`echo $XON | awk -F/ '{print $NF}'`
LCENSOR1D=`echo $XCENSOR | awk -F/ '{print $NF}'`
MODELNAME=`echo ${MODDIR} | awk -F/ '{print $NF}'`

# Alway add "TrainingSVMmodel" to the name.

PREDNAME=${MODELNAME}_Prediction

MODELNAME=${MODELNAME}_TrainingSVMModel

echo "copying model"
cp ${MODDIR}/${MODELNAME}* ./

theDate=`date`

echo                         > ${MODELNAME}.prelog
echo "testSVMProcess.sh"    >> ${MODELNAME}.prelog
echo $theDate               >> ${MODELNAME}.prelog
echo                        >> ${MODELNAME}.prelog
echo "Starting....."        >> ${MODELNAME}.prelog
echo                        >> ${MODELNAME}.prelog

echo 3dsvm -testvol ${LBRIK} -testlabels ${LON1D} -censor ${LCENSOR1D} -mask ${MASKNAME} -model ${MODELNAME}+orig -predictions ${PREDNAME} &> ${MODELNAME}.postlog
3dsvm -testvol ${LBRIK} -testlabels ${LON1D} -censor ${LCENSOR1D} -mask ${MASKNAME} -model ${MODELNAME}+orig -predictions ${PREDNAME} &> ${MODELNAME}.postlog

theDate=`date`
echo                        >> ${MODELNAME}.postlog
echo $theDate               >> ${MODELNAME}.postlog
echo "Finished"             >> ${MODELNAME}.postlog
echo                        >> ${MODELNAME}.postlog

cat ${MODELNAME}.prelog ${MODELNAME}.postlog > ${MODELNAME}.log

\rm ${MODELNAME}.prelog ${MODELNAME}.postlog


