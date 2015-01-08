#!/bin/bash

# Robert C. Welsh
# Ann Arbor, MI 2013
# 
# This is an example of running the ConnTool from the unix command line. 
# You will need to point to matlab.
#
# If you wish to run a command in the background in bash shell type:
#
#  nohup ./test_ConnTool_01.sh &> test_ConnTool_01.log &
#
# This will send all output and error messages to the log file.
#
# Use at your own risk.

# Point to matlab
MATLAB=/Applications/MATLAB_R2011b.app/bin/matlab

# EXPDIR is the directory where scripts live.
EXPDIR=/Users/rcwelsh/Experiments/ALS2008/matlabScripts/fcMRI/fcMRI_Network/BioMarker

STARTDATE=`date`

echo 
echo Starting up matlab to run connectivity at $STARTDATE
echo

# Start up matlab. Everything between the "EOF's" is inside matlab.

${MATLAB} -nodisplay -nojvm <<EOF

%
% Get into the correct directory
%
cd('$EXPDIR');
%
% Execute the script
%
ConnTool_PCC_3

exit

EOF

FINISHDATE=`date`

echo 
echo Finished running matlab job for connectivity at $STARTDATE
echo

#
# All done
#
