%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GENERAL OPTIONS
%%%	These options are shared among many of our scripts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The folder that contains your Subjects folders
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
%%% The format is 'subjectfolder',[runs to include]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjDir = {
    '111129eb',[1];
    '111109ma',[1];
    };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The TR your data was collected at
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TR = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The file to extract the CSF and WM confounds from
%%%
%%% It usually the run file that is in MNI space but prior
%%% to smoothing. The idea is that you don't want gray
%%% smoothed into the CSF or WM regions.
%%%
%%% This can be the same file as the 'connectFile', but not ideal.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
confoundFile = 'w3mm_vbm8_ra8_run';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The file to run the connectivity on
%%%
%%% This will be the smoothed and warped to MNI file.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
connectFile  = 's5mm_w3mm_vbm8_ra8_run';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Image Type should be either 'nii' or 'img'
%%%
%%% Where possible please use "nii" files types. Eventually img/hdr 
%%% will be depricated.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imagetype = 'nii';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Number of Functional scans per run
%%% (if you have more than 1 run, there should be more than 1 value here)
%%%
%%% If you have subjects with varying number of time points you can pick
%%% the smallest, that will edit them down so they all have the
%%% same effective statistical power.
%%%
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
%%%  Pointers to for anatomic images.
%%%
%%%     AnatomyMaskPath --- this should point to the VBM8 processed data
%%%
%%%     GreyFile  --- name of a grey matter image from VBM8 -- Just leave
%%%                  blank, in general don't use this option.
%%%
%%%     WhiteFile --- name of the WM image produced by VBM8
%%%
%%%     CSFFile   --- name of the CSV image produced by VBM8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AnatomyMaskPath = '[Exp]/Subjects/[Subject]/connect/func/coRegRARUN/VBM8/';

GreyFile  = [];
WhiteFile = 'WM_ero*.nii';
CSFFile   = 'CSF_ero*.nii';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Where to output the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OutputTemplate  = '[Exp]/FirstLevel/[Subject]/[OutputName]/';
OutputName      = 'ConnToolTest';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path and name of explicit mask to use at subject level.
%%% Leaving this blank ('') will use a subject-specific mask
%%%
%%% NOTE: Subject-specific masks are NOT recommended at all.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BrainMaskTemplate = ...
    '[mcRoot]/ConnTool/Templates/symmetric_3mm_EPI_MASK_NOEYES.nii';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path Template for realignment parameters file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RealignmentParametersTemplate = ...
    '[Exp]/Subjects/[Subject]/connect/func/[Run]/mcflirt*a8*.dat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path Template for file containing timepoints to censor from the data
%%% This file should either be a simple text file containing a column of
%%% 1s and 0s, or a saved MATLAB .mat file with a cv variable containing a
%%% column of 1s and 0s
%%%
%%% Robert DOES NOT RECOMMEND CENSORING YOUR DATA AFTER FFT. YOU SHOULD
%%%        CLEAN YOUR DATA PRIOR TO USINg WITH THIS TOOLBOX.
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
%%%         Suggested order is "DM[G]CWB"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RegressOrder = 'DMCWB';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The code users COMPCOR.
%%% Use this many principle components for regression
%%% for the CSF and WM
%%%
%%% Behzadi Y, Restom K, Liau J, Liu TT.
%%% A Component Based Noise Correction Method (CompCor) for BOLD and
%%% Perfusion Based fMRI. NeuroImage 2007;37:90–101.
%%%
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
%%%
%%%         coordload   - load corridnate from the specified file
%%%
%%%         files       - provide a list of ROI files
%%%
%%%         directory   - provide a directory containing ROI files and the
%%%                       script will load all images in that directory to
%%%                       use as ROIs
%%%
%%%         grid        - make a grid based on provided spacing and masked
%%%                       by provided mask
%%%
%%%         gridplus    - make a grid based on provided spacing and masked
%%%                       by provided mask, as above.  Additionally, add
%%%                       the extra ROI points specified in ROIGridCenters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ROIInput = 'coordload';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% 'coordinates' method
%%%
%%% If specifying ROI coordinates you need to provide a list of centers in
%%% MNI coordinates (mm) and a radius in voxels.
%%% NOTE: ROISize will be used as the radius of a sphere at each point. If
%%% you'd prefer to use the predefined 1,7,19, or 27 voxel sizes you will
%%% need to specify the size as a cell (i.e. {19})
%%%
%%% See the MethodsCore/ConnTool/Documentation for more help on ROI size.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ROICenters = [0 -5 10];
ROISize    = {19};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% 'coordload' method
%%%
%%% You can load a file into the array ROICenters.
%%%
%%% If a ".csv" file you would do:
%%%
%%%    ROICenters = load('myROIs.csv');
%%%
%%% If a '.mat" file you need to load the file and the assign the variable.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ROIFile = '[mcRoot]/ConnTool/Templates/V_MNI_12mmgrid.mat';
ROISize = {19};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% 'files' and 'directory' methods
%%%
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
%%%
%%% 'grid' and 'gridplus' methods
%%%
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
ROIGridMaskTemplate = ...
    '[mcRoot]/ConnTool/Templates/symmetric_3mm_EPI_MASK_NOEYES.nii';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% 'gridplus' extra
%%%
%%% ROIGridCenters is used in 'gridplus' mode to specify additional ROIs
%%% that you would like to include in addition to the regular grid.  They
%%% will be added to the end of the list of ROIs and will use ROIGridSize
%%% for sizing.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ROIGridCenters = [
     10 10  10;
    -10 10  10;
    -22  0 -22;
     22  0 -22;
    ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Type of output
%%%         images - output R and Z images of correlation with each seed
%%%         maps   - output R and P matrix of correlations between seeds
%%%
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OutputType     = 'maps';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Options for 'maps'
%%%
%%%         correlation type can be 'full' or 'partial'
%%%
%%%         You can also save the power spectrum of the ROIS when running
%%%         in 'maps' mode. This will only save the power spectrum of
%%%         single run.
%%%            1 - save power spectrum
%%%            0 - do not save power spectrum
%%%
%%%         save ROI time courses
%%%            1 - save ROI time courses to same location as R and P matrices
%%%            0 - do not save ROI time courses
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OutputCorrType = 'full';
OutputPower    = 0;
saveroiTC      = 0;

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
