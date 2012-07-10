#!/usr/bin/ksh
paFile=${1}.m
paFile99=wfu_${1}99.m
paFile2=wfu_${1}2.m
paFile5=wfu_${1}5.m
spm99=/ansir2/WFU/distribution/SPM99/$1.m
spm2=/ansir10/bwagner/SPM/spm2/$1.m
spm5=/ansir10/bwagner/SPM/spm5/$1.m

echo "99"
diff --brief $paFile $spm99
diff --brief $paFile99 $spm99
echo "2"
diff --brief $paFile $spm2
diff --brief $paFile2 $spm2
echo "5"
diff --brief $paFile $spm5
diff --brief $paFile5 $spm5

