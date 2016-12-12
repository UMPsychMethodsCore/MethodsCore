#!/bin/bash

SUBJDIR=$1

OPNAME=$(basename $0 .sh)
VERHASH=$(sha1sum $0 | awk '{print $1}')


if [ ! -z $2 ]
then
	JSONFILE=$2
else
	JSONFILE="register_root.json"
fi

cd $SUBJDIR
PDIR=`pwd`

PATTERNS="run*.nii t1*.nii t2*.nii dtiDataSet.nii"
for PAT in $PATTERNS
do
	FILES=$(find $PDIR -name "${PAT}" | sort)
	FILELIST="$FILELIST $FILES"
done

MASTERPROC=`pwd`/master_process.dat
CROSSREF=`pwd`/raw/raw_data_cross_reference.dat
if [ ! -f "${CROSSREF}" ]
then
	echo -e "\nError:  expected cross ref file ${CROSSREF} not found!  No json created.\n"
	exit
fi

SUBJECTCODE=$( head -n1 $CROSSREF | awk '{print $2}')
SUBJECTFOLDERNAME=$(basename `pwd`)

# fix format for dicom/pfile
TS=$(head -n1 $CROSSREF | awk '{print $5}' | cut -d_ -f1)
DATE=$(echo $TS | cut -d_ -f1)
MM=$(echo $DATE | cut -d/ -f1)
DD=$(echo $DATE | cut -d/ -f2)
YYYY=20${DATE: -2}
SESSIONDATE="${YYYY}-${MM}-${DD}"
echo "{\"OpType\":\"${OPNAME}\"," > $JSONFILE
echo "\"VerHash\":\"${VERHASH}\"," >> $JSONFILE
echo "\"ParamDict\":\"{}\"," >> $JSONFILE
echo "\"SubjectCode\":\"${SUBJECTCODE}\"," >> $JSONFILE
echo "\"SessionDate\":\"${SESSIONDATE}\"," >> $JSONFILE
echo "\"SubjectFolderName\":\"${SUBJECTFOLDERNAME}\"," >> $JSONFILE
echo "\"Series\":" >> $JSONFILE
echo -e "\t[" >> $JSONFILE

NUMFILES=$(echo $FILELIST | wc -w)
LASTFILE=$(echo $FILELIST | awk '{ print $NF }')
for RUNNII in $FILELIST
do

	## Figure which series type (TO DO: DTI)
	BASE=$(basename $RUNNII .nii)

	## func
	if [[ "${BASE}" == run* ]]
	then
		TASK=$(basename $(dirname `dirname $RUNNII`))
		RUNNAME=$(basename $RUNNII .nii)
		LINE=$(grep $TASK $MASTERPROC | grep $RUNNAME)
		TS=$(echo $LINE | awk '{print $3}')
		SERIESTYPE=func_$TASK

	## anatomy
	elif [[ "${BASE}" == t1* ]]
	then
		SERIESTYPE=$(basename $RUNNII .nii)
		
		## To do: account for repeat structurals
		LINE=$(grep $SERIESTYPE $MASTERPROC)
		TS=$(echo $LINE | awk '{print $3}')
	fi 

	if [[ "${TS}" == */* ]]
	then 
		TIME=$(echo $TS | cut -d_ -f2)
		HH=$(echo $TIME | cut -d: -f1)
		SS=$(echo $TIME | cut -d: -f2)
		DATE=$(echo $TS | cut -d_ -f1)
		MM=$(echo $DATE | cut -d/ -f1)
		DD=$(echo $DATE | cut -d/ -f2)
		YYYY=20${DATE: -2}
		SERIESDATETIME="${YYYY}-${MM}-${DD} ${HH}:${SS}"	
	else
		SERIESDATETIME=$(echo ${TS:0:4}-${TS:4:2}-${TS:6:2} ${TS:9:2}:${TS:11:2})
	fi
	HASH=$(sha1sum $RUNNII | awk '{print $1}')
	echo -e "\t\t{\"RawFile\":" >> $JSONFILE
	echo -e "\t\t\t{\"Path\":\"${RUNNII}\"," >> $JSONFILE
	echo -e "\t\t\t\"Hash\":\"${HASH}\"}," >> $JSONFILE

	echo -e "\t\t\"SeriesType\":\"${SERIESTYPE}\"," >> $JSONFILE

	if [ "$RUNNII" == "$LASTFILE" ]
	then
		echo -e "\t\t\"SeriesDateTime\":\"${SERIESDATETIME}\"}" >> $JSONFILE
	else
		echo -e "\t\t\"SeriesDateTime\":\"${SERIESDATETIME}\"}," >> $JSONFILE
	fi

done
echo -e "\t]" >> $JSONFILE

echo "}" >> $JSONFILE
