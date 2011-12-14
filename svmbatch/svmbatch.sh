#!/bin/bash

#A program to perform SVM based only on lists of files

#CONSTANTS





#Parameter Processing

totem=
crossv=
totemtemp=/tmp/totems #Where to store your totem files/examples






while [ "$1" != "" ]; do
    case $1 in
	-t | --totem )
	    totem=1  #Operate in totem stacking mode
	    #shift
	    #totemtemp=$1
	    echo Running in Totem Mode
	    ;;
	-c | --crossv )	
	    crossv=1
	    ;; #Will perform cross validation per SVM-light
	-C | --CROSSV ) 
	    scrossv=1
	    ;; #will do super cross validation (per dan)
	-k | --kernel ) 
	    kernelmode=1 #Kernel has been specified
	    shift
	    kernel=$1
	    echo Kernel specified is $kernel
	    ;;
	-d | --directory )
	    shift
	    svmdir=$1
	    ;;
	--nomodelmask ) 
	    nomodelmask=1
	    ;;

    esac
    shift
done




#FUNCTIONS

function totem_build { #

#if in totem mode

if [ "$totem" == 1 ];
    then
    mkdir $totemtemp
    totembatch "$filelist1"
    totembatch "$filelist2"

    filelist1= `hdr_append  `prepend $totemtemp  `slash_strip "$filelist1"` ` `
    filelist2= `hdr_append  `prepend $totemtemp  `slash_strip "$filelist2"` ` `

    #filelist1=`cat filelist1 | sed -e 's:/:_:2g' -e 's:^:/'$totemtemp: -e 's:$:.hdr:'` #Update the filelist to point to where the totem-ed files are
    #filelist2=`cat filelist2 | sed -e 's:/:_:2g' -e 's:^:/'$totemtemp: -e 's:$:.hdr:'`


fi
}

function totembatch { #Read totem.suf, mk totemtemp, assemble totems, update filelist to point to totems

totemsuf=`cat totem.suf`

mkdir $totemtemp

function totem_build {

for  file in $1; do
    totemlist=  #Clear totemlist. Holds names of files to go into totem
    newname= #Clear newname. Holds name of target totem
    for suf in $totemsuf; do
	totemlist=`echo $totemlist $file/$suf` #loop over suffixes, and build up the list of subfiles
    done
    newname=`slash_strip $file`
    fslmerge -z $totemtemp/$newname $totemlist  #use fsl to merge your subfiles in the z direction into totems
    newname=
done
}

totem_build $filelist1 #Quoting doesn't matter here for list ops
totem_build $filelist2 #And function will not quote anyway

filelist1=`hdr_append \`prepend $totemtemp \\\`slash_strip "$filelist1" \\\` \` `
filelist2=`hdr_append \`prepend $totemtemp \\\`slash_strip "$filelist2" \\\` \` `
}


#Read in variable values from associated files

function svm_prep { #Read in filelists, svmdir, totem.suf and make svmdir

filelist1=`cat filelist1`
filelist2=`cat filelist2`

if [ -f svmdir ]
    then
    svmdir=`cat svmdir`
fi

if [ ! -d $svmdir ]
    then
    mkdir $svmdir
fi

if [ "$totem" = "1" ]; thhen    totemlist=  #Clear the totemlist variable. This will hold the list of all the subfiles going into your totem
    for suf in $totemsuf;
      do
      totemlist=`echo $totemlist $file/$suf` #loop over suffixes, and build up the list of subfiles
    done
    newname=`echo $file | sed 's:/:_:2g'` #edit the filename to have underscores instead of slashes, it will keep the temp directory cleaner
    fslmerge -z $totemtemp/$newname $totemlist  #use fsl to merge your subfiles in the z direction into totems
    newname=
    done
}


#Read in variable values from associated files

function svm_prep { #Read in filelists, svmdir, and make svmdir

filelist1=`cat filelist1`
filelist2=`cat filelist2`

if [ -f svmdir ]
    then
    svmdir=`cat svmdir`
fi

if [ ! -d $svmdir ]
    then
    mkdir $svmdir
fi



}

function slash_strip { #Strip all slashes off $1,prepend slash 
echo "$1" | sed -e 's:/:_:g' -e 's:^:/:'
}

function prepend { #Will prepend $1 to all of $2
echo "$2" | sed "s:^:/$1:"
}

function hdr_append { #Add .hdr to end of $1
echo "$1" | sed "s:$:.hdr:"
}

function hdr_strip { #Remove all instances of .hdr from $1
echo "$1" | sed "s:.hdr::"
}

function afni_bucket_build { #Build converted bucket files from list $1
3dbucket -sessiondir $svmdir -prefixname bucket$2 $1
}

function afni_bucket_combine { #Combine buckets specified in $1, name them $2
cd $svmdir

bucketlist=
for bucket in $1; do
    bucketlist=`echo $bucketlist $bucket+orig `
done

3dbucket -prefixname $2 $bucketlist
}

function afni_bucket_short { #Convert bucket specified in $1 to short, named by $2
cd $svmdir
3dcalc -a $1+orig -expr "a" -prefixname $2 -datum short
}

function afni_bucket_time { #convert bucket in $1 to be of type time, named $2
cd $svmdir
3dTcat -prefix $2 $1+orig
}

function afni_build { #Build bucket files from list in $1, name suf $2 (convert, combine, calc, timeify)

#Build bucket files out of each of your conditions
3dbucket -sessiondir $svmdir -prefixname bucket$2 $1
3dbucket -sessiondir $svmdir -prefixname bucket2 $filelist2

#Change to the svm working directory (presumably where this script was called from)
cd $svmdir

#Combine your two class bucket files into one super bucket
3dbucket -prefixname bucket bucket1+orig bucket2+orig

#Convert your bucket file to shorts
3dcalc -a bucket+orig -expr "a" -prefixname shortbucket -datum short

#Convert your short bucket to be of type "time" (required by 3dsvm)
3dTcat -prefix timeshortbucket shortbucket+orig
}

function label_build { #Make label file

for i in $filelist1
  do
  echo 1 >>labels.1D
done

for i in $filelist2
  do
  echo 2 >> labels.1D
done
}

function mask_build { #Build automask
3dAutomask timeshortbucket+orig
}

function set_train_rules { #Set rules for 3dsvm training based on options
maskrule="-mask automask+orig"
if [ "$totem" = "1" | "$nomodelmask" = "1" ]; then
    maskrule="-nomodelmask"
fi

crossvrule=""
if [ "$crossv" = "1" ]; then
    crossvrule="-x 1"
fi

kernelrule="-bucket weightbucket"
if [ "$kernelmode" = "1" ]; then #if running in kernel mode
    kernelrule="-kernel $kernel"
fi
}

function svm_train { #Train on timeshort labeled in $1
#Run your 3dsvm model
3dsvm \
    -trainvol $1+orig\
    -trainlabels labels.1D\
    $maskrule -model \
    model \
    $kernelrule \
    $crossvrule

}

function totem_clean { #delete your temporary totem files, if they existed
if [ "$totem" = "1" ] 
    then
    rm $totemtemp -rf
fi

}

function set_test_rules { #Set rules for 3dsvm testing based on options

function svm_test { #Test model #1 against volume #2
3dsvm \
    -model $1 \
    -testvol $2 \
    -predictions $pname\
    -nodetrend

}



function main {
svm_prep
totem_build
afni_build
label_build
mask_build
setrules
svm_train
}



#Super looper down here?

#main #If nothing special, just run it I guess?

svm_prep

svmdir_orig=$svmdir
filelist1_orig="$filelist1"
filelist2_orig="$filelist2"


biglist=`echo -e "$filelist1\n$filelist1"` #Concatenate your two lists
for file in $biglist
  do
  curdir=`hdr_strip \`slash_strip $file \` `
  svmdir=`echo $svmdir_orig/$curdir`	
  filelist1=`echo "$filelist1" | sed "\:$file: d" ` #Because our $file has tons of slashes, we use : as the delimeter
  filelist2=`echo "$filelist2" | sed "\:$file: d" `
  
  echo "$svmdir"
#  echo "$filelist1"
 # echo "$filelist2"

#   totem_build
#   afni_build
#   label_build
#   mask_build
#   setrules
#   svm_train
done


##To add:
#1) Model testing (on training data itself, be sure to use set detrend to no
#2) Ability to automatically split examples into training and test set, and do cross validation randomly
#3) Permutation tests (basically just a for loop with random permutation of labels file. Tricky thing is querying test model weights against giant population of permutation weights

