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
	-p | --permutation )
	    permutationmode=1
	    shift
	    permcount=$1
	    ;;

    esac
    shift
done



#FUNCTIONS


function totem_batch { #Read totem.suf, mk totemtemp, assemble totems, update filelist to point to totems
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
totem_build "$filelist1" #Quoting here DOES matter. Otherwise it will take only first element as $1
totem_build "$filelist2"


filelist1=`slash_strip "$filelist1"`
filelist1=`prepend $totemtemp "$filelist1"`
filelist1=`hdr_append "$filelist1"`

filelist2=`slash_strip "$filelist2"`
filelist2=`prepend $totemtemp "$filelist2"`
filelist2=`hdr_append "$filelist2"`

}


function svm_prep { #Read in filelists, svmdir, and make svmdir
filelist1=`cat filelist1`
filelist2=`cat filelist2`
if [ -f svmdir ]; then
    svmdir=`cat svmdir`
fi

if [ ! -d $svmdir ]; then
    mkdir $svmdir
fi

filelist1_orig="$filelist1"
filelist2_orig="$filelist2"
svmdir_orig="$svmdir"

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

function afni_bucket_build { #Build converted bucket files from list $1, named $2
3dbucket -sessiondir $svmdir -prefixname $2 $1 2>/dev/null
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

function label_permute { #Randomly permute the labels in a given label file
for i in `cat $1`; do echo "$RANDOM $i"; done | sort | sed -r 's/^[0-9]+//' > plabels.1D
rm labels.1D
mv plabels.1D labels.1D
}

function mask_build { #Build automask
3dAutomask timeshortbucket+orig
}

function set_train_rules { #Set rules for 3dsvm training based on options
maskrule="-mask automask+orig"
if [ "$totem" = "1" -o "$nomodelmask" = "1" ]; then
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
    -trainvol $1+orig \
    -trainlabels labels.1D \
    $maskrule \
    -model  model \
    $kernelrule \
    $crossvrule

}

function svm_batchtrain { #Based on curval of $filelists and $svmdir, does all the lifting
afni_bucket_build "$filelist1" "bucket1"
afni_bucket_build "$filelist2" "bucket2"
afni_bucket_combine "bucket1 bucket2" "bucket"
afni_bucket_short "bucket" "bucketshort"
afni_bucket_time "bucketshort" "bucketshorttime"
label_build
if [ "$permute" = "1" ]; then
    cd $svmdir
    label_permute labels.1D
fi
set_train_rules
svm_train "bucketshorttime"
}


function totem_clean { #delete your temporary totem files, if they existed
if [ "$totem" = "1" ] 
    then
    rm $totemtemp -rf
fi

}

function set_test_rules { #Set rules for 3dsvm testing based on options
echo You need to finish this one Dan
}

function svm_test { #Test model $1 against volume $2
3dsvm \
    -model $1+orig \
    -testvol $2+orig \
    -predictions $pname\
    -nodetrend

}

function svm_batchtest { #Test model $1 against constructed volume based on hdrs in $2
afni_bucket_build "$2" "testbucket"
afni_bucket_short "testbucket" "testbucketshort"
afni_bucket_time "testbucketshort" "testbucketshorttime"
set_test_rules
svm_test $1 "testbucketshorttime"
}

function super_crossvalid { #no arguments. Performs LOO-CV manually, and saved predictions
svmdir_orig=$svmdir
filelist1_orig=$filelist1
filelist2_orig=$filelist2

mkdir $svmdir_orig/LOOCV/

biglist=`echo -e "$filelist1\n$filelist2"`
for file in $biglist; do
    echo "Now working on LOOCV for $file"
    pname="$file" #this is the file predictions will get written to. file specific will be better
    loodir=`hdr_strip \`slash_strip $file \` ` #Make file into a dirname
    pname=`echo "$loodir" | sed 's:/::'`
    svmdir=`echo $svmdir_orig/LOOCV/$loodir   ` #build a dir from loodir and svmdir_orig
    filelist1=`echo "$filelist1_orig" | sed "\:$file: d" ` #remove $file from filelist1
    filelist2=`echo "$filelist2_orig" | sed "\:$file: d" ` #remove $file from filelist2
    svm_batchtrain #train up a model based on the updated filelist and svmdir
    svm_batchtest "model" "$file"
done
}

function permutation_test { #will perfrom $1 permutations on data, writing out weight buckets at each step
permute=1
mkdir $svmdir/perms
for i in `seq 1 $1`; do
echo "Running permutation $i of $1"
svmdir=`echo $svmdir_orig/perms/$i`
mkdir $svmdir
cd $svmdir
ln -s $svmdir_orig/bucketshorttime* .
cp $svmdir_orig/labels.1D ./labels.1D
label_permute labels.1D
set_train_rules
svm_train "bucketshorttime"
done
}


function main {
svm_prep

if [ "$totem" = "1" ]; then
    
totem_batch
    
fi



if [ "$scrossv" != "1" ]; then
    echo "Training one and only model"
    svm_batchtrain
else
    echo "Entering Super Cross Validation Mode!"
    super_crossvalid
fi

if [ "$permutationmode" = "1" ]; then
    echo "Entering permutation mode"
    permutation_test $permcount
fi

if [ "$totem" = "1" ]; then
    
totem_clean
    
fi

}


main



##To add:
#1) Model testing (on training data itself, be sure to use set detrend to no
#2) Ability to automatically split examples into training and test set, and do cross validation randomly
#3) Permutation tests (basically just a for loop with random permutation of labels file. Tricky thing is querying test model weights against giant population of permutation weights

