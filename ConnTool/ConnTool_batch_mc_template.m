%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GENERAL OPTIONS
%%%	These options are shared among many of our scripts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The folder that contains your subject folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/Volumes/ALS/ALS2008/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Path where your images are located
%%%
%%%  Variables you can use in your template are:
%%%       Exp = path to your experiment directory
%%%       iSubject = index for subject
%%%       Subject = name of subject from SubjDir (using iSubject as index of row)
%%%       iRun = index of run (listed in Column 3 of SubjDir)
%%%       Run = name of run from RunDir (using iRun as index of row)
%%%        * = wildcard (can only be placed in final part of template)
%%% Examples:
%%% ImageTemplate = '[Exp]/Subjects/[Subject]/func/run_0[iRun]/';
%%% ImageTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ImageTemplate = '[Exp]/Subjects/[Subject]/connect/func/[Run]/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% A list of run folders where the script can find functional images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RunDir = {
	'run_01';
};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The list of subjects to process
%%% The format is 'subjectfolder',subject number in masterfile,[runs to include]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjDir = {
'111129eb',1,[1];
          };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The TR your data was collected at
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TR = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Prefixes for slicetiming, realignment, normalization, and smoothing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stp = 'a';
%rep = 'r';
%nop = 'w';
%smp = 's';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Preprocessing that has already been completed on images
%%% [slicetime realign normalize smooth]
%%% If you are only running First Level (i.e. Preprocessing is already done)
%%% setting these will add the appropriate prefix to the basefile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%alreadydone = [1 1 1 1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The file to extract the confounds from
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
confoundFile = 'vbm8_ra8_run';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The file to run the connectivity on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
connectFile  = 'sw5mm_vbm8_ra8_run';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Image Type should be either 'nii' or 'img'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imagetype = 'nii';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Number of Functional scans per run
%%% (if you have more than 1 run, there should be more than 1 value here)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NumScan = [240]; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CONNECTIVITY OPTIONS
%%%	These options are only used for Connectivity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Mode to run som_batch_mc_central in
%%%        'test'       = test script but do not save parameters or run any
%%%                       SOM code
%%%        'parameters' = run script and save parameters for each subject
%%%                       but do not run any SOM code
%%%        'som'        = run SOM code on previously saved parameters
%%%        'full'       = generate parameters and immediately run SOM code
%%%
%%%        NOTE: If you choose mode 'som' then most variables except
%%%        SubjDir and OutputTemplate/OutputName will be ignored as they
%%%        will be loaded from the already existing parameter file for each
%%%        subject.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Mode = 'full';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Flag to for anatomic images.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AnatomyMaskPath = '[Exp]/Subjects/[Subject]/connect/func/coRegRARUN/VBM8/'

GrayUse  = false;
WhiteUse = true;
CSFUse   = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Where to output the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OutputTemplate  = '[Exp]/FirstLevel/[Subject]/[OutputName]/';
OutputName      = 'censortest';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path and name of explicit mask to use at first level.
%%% Leaving this blank ('') will use a subject-specific mask
%%% NOTE: Subject-specific masks are not recommended for grid usage below.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BrainMaskTemplate = '/Volumes/ALS/Software/SPM8/spm8_with_R4667/templates/symmetric_rr3mm_EPI_MASK_NOEYES.nii';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path Template for realignment parameters file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RealignmentParametersTemplate = '[Exp]/Subjects/[Subject]/connect/func/[Run]/mcflirt*a8*.dat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path Template for file containing timepoints to censor from the data
%%% This file should either be a simple text file containing a column of
%%% 1s and 0s, or a saved MATLAB .mat file with a cv variable containing a
%%% column of 1s and 0s
%%%
%%% Robert DOES NOT RECOMMEND CENSORING YOUR DATA.
%%%
%%%     This ConnTool Toolbox users an FFT filter with a little 
%%%     but of smoothing. If you want to censor you take the risk of
%%%     created artifactual correlations across the whole brain
%%%
%%%     See the following three papers:
%%%
%%% 	Power JD, Barnes KA, Snyder AZ, Schlaggar BL, Petersen SE. 
%%%     Spurious but Systematic Correlations in Functional Connectivity 
%%%     MRI Networks Arise From Subject Motion. NeuroImage 2012;59:2142–2154.
%%%
%%%	Carp J. Optimizing the Order of Operations for Movement Scrubbing: 
%%%     Comment on Power Et Al. NeuroImage 2012:1–3.
%%%
%%% 	Power JD, Barnes KA, Snyder AZ, Schlaggar BL, Petersen SE. 
%%%     Steps Toward Optimizing Motion Artifact Removal in Functional 
%%%     Connectivity MRI; a Reply to Carp. NeuroImage 2012:1–3.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CensorTemplate = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Constrain results to only regions in GreyMatterTemplate (1=yes, 0=no)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MaskGrey = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Value threshold to use for each mask.  If left as [] use default 0.75
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GreyThreshold  = [];
WhiteThreshold = [];
CSFThreshold   = [];
EPIThreshold   = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% the order to perform the regressions etc
%%%         D = detrend
%%%         G = global
%%%         W = white matter
%%%         C = csf
%%%         M = motion
%%%         B = bandpass
%%% 
%%%         Suggested order is "D[G]CWMB"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RegressOrder = 'DCWMB';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Use this many principle components for regression
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrincipalComponents = 5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Bandpass Filter Settings
%%%        LowFrequency - low frequency cutoff
%%%        HighFrequency - high frequency cutoff
%%%        Gentle - 0 = no rolling, 1 = rolling, 2 = extra rolling
%%%        Padding - number of timepoints to pad on beginning/end
%%%        BandpassFilter - 0 = Matlab filter, 1 = SOM_Filter_FFT
%%%        Fraction - fraction of variance for principle components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LowFrequency   = 0.01;
HighFrequency  = 0.1;
Gentle         = 1;
Padding        = 10;
BandpassFilter = 1;
Fraction       = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Type of input
%%%         coordinates - provide the center of each seed and a radius
%%%         files       - provide a list of ROI files
%%%         directory   - provide a directory containing ROI files and the
%%%                       script will load all images in that directory to 
%%%                       use as ROIs
%%%         grid        - make a grid based on provided spacing and masked
%%%                       by provided mask
%%%         gridplus    - make a grid based on provided spacing and masked
%%%                       by provided mask, as above.  Additionally, add
%%%                       the extra ROI points specified in ROIGridCenters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ROIInput = 'coordinates';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% If specifying ROI coordinates you need to provide a list of centers in 
%%% MNI coordinates (mm) and a radius in voxels.
%%% NOTE: ROISize will be used as the radius of a sphere at each point. If 
%%% you'd prefer to use the predefined 1,7,19, or 27 voxel sizes you will 
%%% need to specify the size as a cell (i.e. {19})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(fullfile('/Volumes/ALS/ALS2008/matlabScripts/fcMRI/fcMRI_Network','V_MNI_12mmgrid.mat'));

ROICenters = mni_coords;

%ROICenters = [
%    %0 -53 26; %pcc seed
%    9 9 -8; %VSi right
%    -9 9 -8; %VSi left
%    10 15 0; %VSs right
%    -10 15 0; %VSs left
%    13 15 9; %DC right
%    -13 15 9; %DC left
%    28 1 3; %DCP right
%    -28 1 3; %DCP left
%    25 8 6; %DRP right
%    -25 8 6; %DRP left
%    20 12 -3; %VRP right
%    -20 12 -3; %VRP left
%    ];
ROISize = {19};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% If specifying ROI images you need to provide an ROI folder as well as a
%%% cell array list of ROI images.  If specifying an ROI directory, you only
%%% need to specify an ROITemplate.  The script will then load all images
%%% in that directory to use as the ROIImages cell array.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ROITemplate = '[Exp]/ROIS';
ROIImages = {
    'image1.nii';
    'image2.nii';
    };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% If specifying ROI grid you need to provide a spacing and ROI size as
%%% well as an optional mask for grid point inclusion (a mask is strongly 
%%% encouraged as not using one will return coordinates from across the entire
%%% bounding box).
%%% NOTE: ROIGridSize will be used as the radius of a sphere at each grid
%%% point.  If you'd prefer to use the predefined 1,7,19, or 27 voxel sizes
%%% you will need to specify the size as a cell (i.e. {19})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ROIGridSpacing      = 12;
ROIGridSize         = {19};
ROIGridMaskTemplate = '/Volumes/ALS/Software/SPM8/spm8_with_R4667/templates/symmetric_rr3mm_EPI_MASK_NOEYES.nii';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ROIGridCenters is used in 'gridplus' mode to specify additional ROIs
%%% that you would like to include in addition to the regular grid.  They
%%% will be added to the end of the list of ROIs and will use ROIGridSize
%%% for sizing.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ROIGridCenters = [
    10 10 10;
    -10 10 10;
    -22 0 -22;
    22 0 -22;
    ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Type of output
%%%         images - output R and Z images of correlation with each seed
%%%         maps   - output R and P matrix of correlations between seeds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ROIOutput = 'maps';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% "maps" output mode only - save ROI time courses
%%% 1 - save ROI time courses to same location as R and P matrices
%%% 0 - do not save ROI time courses
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
saveroiTC = 0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Do not edit below this line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%DEVSTART
mcRoot = '/Volumes/ALS/Software/MethodsCore';
%DEVSTOP

%[DEVmcRootAssign]

addpath(fullfile(mcRoot,'matlabScripts'));
addpath(fullfile(mcRoot,'ConnTool'));
addpath(fullfile(mcRoot,'ConnTool/Code'));
addpath(fullfile(mcRoot,'SPM','SPM8','spm8_with_R4667'));

ConnTool_batch_mc_central
