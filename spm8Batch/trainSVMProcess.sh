#!/bin/bash
#
# Copyright Robert C. Welsh, 2010
# Ann Arbor MI
#

#
# Using 3dsvm of AFNI by S. Leconte process a subject/run
# for 3D SVM training

#
# Inputs
# 
#  1 Subject name
#  2 Process flag = 1 if okay, 0 = abort
#  3 Input BRIK data
#  4 Output directory
#  5 Masking image
#  6 1D vector of on condition
#  7 1D vector of censor 
#  8 Flag to wipe the output directory first.

if [ "$#" == "0" ] && [ "$#" != "8" ] 
then
    echo
    echo "trainSVMProcess.sh"
    echo
    echo "#"
    echo "# Inputs"
    echo "# "
    echo "#  1 Subject name"
    echo "#  2 Process flag = 1 if okay, 0 = abort"
    echo "#  3 Input BRIK data"
    echo "#  4 Output directory"
    echo "#  5 Masking image"
    echo "#  6 1D vector of on condition"
    echo "#  7 1D vector of censor"
    echo "#  8 Flag to wipe the output directory first."
    echo
    exit
fi

if [ "$2" == "0" ]
then
    echo -n " Aborting "
    exit
fi

SUBJECT=$1
PROCESS=$2
INBRIK=$3
OUTDIR=$4
MASK=$5
ON1D=$6
CENSOR1D=$7
WIPEFLAG=$8

MHEAD=`echo $MASK | sed -e "s/\.BRIK/.HEAD/"`
DHEAD=`echo $INBRIK | sed -e "s/\.BRIK/.HEAD/"`

mkdir -p $OUTDIR

cd $OUTDIR

if [ "${WIPEFLAG}" == "1" ]
then
    echo -n " Removing previous model estimation/training "
    rm *
fi

cp $MASK ./
cp $MHEAD ./
cp $INBRIK ./
cp $DHEAD ./
cp $ON1D ./
cp $CENSOR1D ./

MASKNAME=`echo $MASK | awk -F/ '{print $NF}' | sed -e "s/\.BRIK//"`
LBRIK=`echo $INBRIK | awk -F/ '{print $NF}'  | sed -e "s/\.BRIK//"`
LON1D=`echo $ON1D | awk -F/ '{print $NF}'`
LCENSOR1D=`echo $CENSOR1D | awk -F/ '{print $NF}'`
MODELNAME=`pwd | awk -F/ '{print $NF}'`

# Alway add "TrainingSVMmodel" to the name.

MODELNAME=${MODELNAME}_TrainingSVMModel

theDate=`date`

echo                         > ${MODELNAME}.prelog
echo "trainSVMProcess.sh"   >> ${MODELNAME}.prelog
echo $theDate               >> ${MODELNAME}.prelog
echo                        >> ${MODELNAME}.prelog
echo "Starting....."        >> ${MODELNAME}.prelog
echo                        >> ${MODELNAME}.prelog

3dsvm -trainvol ${LBRIK} -trainlabels ${LON1D} -censor ${LCENSOR1D} -mask ${MASKNAME} -model ${MODELNAME} -bucket ${MODELNAME}_Bucket &> ${MODELNAME}.postlog

theDate=`date`
echo                        >> ${MODELNAME}.postlog
echo $theDate               >> ${MODELNAME}.postlog
echo "Finished"             >> ${MODELNAME}.postlog
echo                        >> ${MODELNAME}.postlog

cat ${MODELNAME}.prelog ${MODELNAME}.postlog > ${MODELNAME}.log

\rm ${MODELNAME}.prelog ${MODELNAME}.postlog

# Write out what went into making this predictive model so we can test it more easily.

echo "TRAIN=${LON1D}"            >   modelInput.dat
echo "XCENSOR=${LCENSOR1D}"     >>   modelInput.dat
echo "MASK=${MASKNAME}"         >>   modelInput.dat
echo "MODEL=${MODELNAME}"       >>   modelInput.dat

#
# All done.
#
