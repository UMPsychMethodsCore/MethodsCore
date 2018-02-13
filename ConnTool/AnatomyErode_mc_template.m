%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% AnatomyErode_mc_template
%%% This script is used to resample and erode white matter and CSF images
%%% from segmentation. These step is necessary if you intend to use CompCor
%%% to extract noise components from WM/CSF when using ConnTool for resting
%%% state data analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The folder that contains your Subjects folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/data2/NFB/fmri/slab';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path where your logfiles will be stored
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LogTemplate = '[Exp]/Logs';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The list of subjects to process
%%% The format is 'subjectfolder',[runs to include]
%%% Note: [runs to include] is not actually used in this script, it is
%%% included only for ease of copy/pasting subject lists between scripts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjDir = {
    'S001',[1];
    };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Path to a functional image from your data
%%%
%%%  Variables you can use in your template are:
%%%      Exp      = path to your experiment directory
%%%      Subject  = name of subject from SubjDir 
%%% Example:
%%% ResampleTemplate = '[Exp]/Subjects/[Subject]/rest/run_01/s6w3rtrun_01.nii';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ResampleTemplate = '[Exp]/Subjects/[Subject]/wrestA.final.nii';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Pointers to for anatomic images.
%%%
%%%     AnatomyPath  --- path with your segmented images
%%%     AnatomyFiles --- list of anatomical images to resample and erode
%%% Example:
%%% AnatomyPath = '[Exp]/Subjects/[Subject]/func/coReg/'
%%% AnatomyFiles = {
%%%     'mwp2ht1spgr.nii';
%%%     'mwp3ht1spgr.nii';
%%%     };
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AnatomyPath = '[Exp]/Subjects/[Subject]/';
AnatomyFiles = {
    'wc2anat.nii';
    'wc3anat.nii';
    };


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Advanced Options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ErosionKernel
%%% The 3d kernel to use for erosion. Each voxel is replaced by the minimum
%%% value within the kernel neighborhood. You can use the special values of
%%% {7}, {19}, {27} which represent face, edge, and corner connectivity
%%% respectively, or define a 3D binary array representing your custom
%%% kernel.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ErosionKernel = {7};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ErosionSteps
%%% The number of times to perform the erosion operation
%%% There should either be a single value, or 1 value for each image in
%%% AnatomyFiles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ErosionSteps = [2];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ImageThreshold
%%% The value threshold used to binarize the images prior to erosion.
%%% Anything below this value will be 0, anything equal or above will be 1
%%% Similar to ErosionSteps, this should either be a single value, or 1
%%% value for each image in AnatomyFiles if you need different thresholds.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ImageThreshold = 0.333;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Minimum mask warning
%%% If any mask is less than or equal to this size, a warning will be
%%% presented and logged
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MinMask = 5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Do not edit below this line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mcRoot
%DEVSTART
mcRoot = '/home/mangstad/repos/MethodsCore';
%DEVSTOP

%[DEVmcRootAssign]

addpath(fullfile(mcRoot,'matlabScripts'));
addpath(fullfile(mcRoot,'ConnTool'));
addpath(fullfile(mcRoot,'SPM','SPM12','spm12_with_R6906'));

AnatomyErode_mc_central
