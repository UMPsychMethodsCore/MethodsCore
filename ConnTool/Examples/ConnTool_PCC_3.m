%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GENERAL OPTIONS
%%%	These options are shared among many of our scripts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The folder that contains your Subjects folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/Volumes/ALS/ALS2008/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The list of subjects to process
%%% The format is 'subjectfolder',[runs to include]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjDir = {
    '111129eb',[1];
    '111109ma',[1];
    };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Specify a subject of the above by indicating which rows 
%%% of subjects to include in the current job. 
%%% One number per subject you want. If you leave this empty all
%%% subjects will be processed.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjectDirBatch = [1 2];

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
%%% The file to extract the CSF and WM confounds from
%%%
%%% It usually the run file that is in MNI space but prior
%%% to smoothing. The idea is that you don't want gray
%%% smoothed into the CSF or WM regions.
%%%
%%% This can be the same file as the 'connectFile', but not ideal.
%%%
%%% The code implements COMPCOR based on the paper of:
%%%
%%% Behzadi Y, Restom K, Liau J, Liu TT. A Component Based Noise 
%%% Correction Method (CompCor) for BOLD and Perfusion Based fMRI. 
%%% NeuroImage 2007;37:90?101.
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
%%% Where possible please use "nii" files types. 
%%%
%%% NOTE: Eventually img/hdr support will be depricated.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imagetype = 'nii';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The TR your data was collected at
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TR = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Number of Functional scans to use per run
%%% (if you have more than 1 run, there should be more than 1 value here)
%%%
%%% e.g. if you have three runs it should be:
%%%
%%%     NumScan = [240 240 240];
%%%
%%% If you have subjects with varying number of time points you can pick
%%% the smallest, that will trim them down so they all have the
%%% same effective statistical power.
%%%
%%% 
%%% If you are unsure you may enter a super big number and all points 
%%% will be taken.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NumScan = [9999 9999];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CONNECTIVITY OPTIONS
%%%	These options are only used for Connectivity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Mode to run ConnTool_batch_mc_central in
%%%        'test'       = test script but do not save parameters or run any
%%%                       ConnTool code
%%%        'parameters' = run script and save parameters for each subject
%%%                       but do not run any ConnTool code
%%%        'presave'    = run ConnTool code on previously saved parameters
%%%        'full'       = generate parameters and immediately run ConnTool code
%%%
%%%        NOTE: If you choose mode 'presave' then most variables except
%%%        SubjDir and OutputTemplate/OutputName will be ignored as they
%%%        will be loaded from the already existing parameter file for each
%%%        subject.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Mode = 'full';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Pointers to for anatomic images.
%%%
%%%     AnatomyMaskPath --- this should point to the VBM8 processed data
%%%
%%%     GreyFile  --- name of a grey matter image from VBM8 -- Just leave
%%%                   blank, in general don't use this option.
%%%
%%%     WhiteFile --- name of the WM image produced by VBM8
%%%                   Typically this starts with "WM_ero"
%%%
%%%     CSFFile   --- name of the CSV image produced by VBM8
%%%                   Typically this starts with "CSF_ero"
%%%
%%% NOTE : Wildcard "*" can be used in the definition of the file names.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AnatomyMaskPath = '[Exp]/Subjects/[Subject]/connect/func/coRegRARUN/VBM8/';

GreyFile  = [];
WhiteFile = 'WM_ero*.nii';
CSFFile   = 'CSF_ero*.nii';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path Template for realignment parameters file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RealignmentParametersTemplate = ...
    '[Exp]/Subjects/[Subject]/connect/func/[Run]/mcflirt*a8*.dat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path Template for pre-filter replacement of spikes.
%%%
%%% This file does NOT have to be present for each subject. If the file 
%%% is missing then it's assumed that the correction is not to be done.
%%%
%%% This file should either be a simple text file containing a column-wise
%%% vector of 1s and 0s, or a saved MATLAB .mat file with a 
%%% cv variable containing a column of 1s and 0s
%%%
%%%     'moving#'    - local timecourse mean
%%%                    where # is a real number indicating the window
%%%                    e.g. 
%%%                        DespikeReplacementOption='moving7';
%%%     'loess#'     - robust loess regression smoothing interpolation
%%%                    where # is a real number indicating the window
%%%                    e.g. 
%%%                        DespikeReplacementOption='loess0.15';
%%%     'rloess#'    - robust loess regression smoothing interpolation
%%%                    where # is a real number indicating the window
%%%                    e.g. 
%%%                        DespikeReplacementOption='rloess0.15';
%%%     'sgolay#'    - robust loess regression smoothing interpolation
%%%                    where # is a real number indicating the window
%%%                    e.g. 
%%%                        DespikeReplacementOption='sgolay7';
%%%     'lowess#'    - robust loess regression smoothing interpolation
%%%                    where # is a real number indicating the window
%%%                    e.g. 
%%%                        DespikeReplacementOption='lowess.15';
%%%     'rlowess#'   - robust loess regression smoothing interpolation
%%%                    where # is a real number indicating the window
%%%                    e.g. 
%%%                        DespikeReplacementOption='rlowess0.15';
%%%
%%%
%%% After the data are smoothed, the missing point is then calculated with 
%%% an interpolation(interp1) using pchip (cubic).
%%%
%%% This is following:
%%%
%%%     Satterthwaite TD, Elliott MA, Gerraty RT, Ruparel K, Loughead J, 
%%%     Calkins ME, Eickhoff SB, Hakonarson H, Gur RC, Gur RE, Wolf DH. 
%%%     An Improved Framework for Confound Regression and Filtering for 
%%%     Control of Motion Artifact in the Preprocessing of Resting-State 
%%%     Functional Connectivity Data. 
%%%     NeuroImage 2013;64:240?256.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DespikeParametersTemplate = ...
    '[Exp]/Subjects/[Subject]/connect/func/[Run]/prefilter_despike.dat';
DespikeReplacementOption  = 'sgolay7';
DespikeReplacementInterp  = 'pchip';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path Template for post-filter censoring of spikes.
%%%
%%% This file does NOT have to be present for each subject. If the file 
%%% is missing then it's assumed that the correction is not to be done.
%%%
%%% This file should either be a simple text file containing a column of
%%% 1s and 0s, or a saved MATLAB .mat file with a cv variable containing a
%%% column of 1s and 0s
%%%
%%%     This ConnTool Toolbox users an FFT filter with a little
%%%     bit of smoothing. If you want to censor your data your should
%%%     see the following papers.
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
%%%     Satterthwaite TD, Elliott MA, Gerraty RT, Ruparel K, Loughead J, 
%%%     Calkins ME, Eickhoff SB, Hakonarson H, Gur RC, Gur RE, Wolf DH. 
%%%     An Improved Framework for Confound Regression and Filtering for 
%%%     Control of Motion Artifact in the Preprocessing of Resting-State 
%%%     Functional Connectivity Data. 
%%%     NeuroImage 2013;64:240?256.
%%%
%%%     Fair, D. et al. Distinct Neural Signatures Detected for ADHD 
%%%     Subtypes After Controlling for Micro-Movements in Resting State 
%%%     Functional Connectivity MRI Data. 2013:1?31.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CensorParametersTemplate = ...
    '[Exp]/Subjects/[Subject]/connect/func/[Run]/postfilter_censor.dat';

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
%%% Constrain calculations to only regions in GreyMatterTemplate (1=yes, 0=no)
%%% 
%%% Use of this will result in a varying ROI size by subject.
%%%
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
%%%
%%% DETREND Polynomial order
%%%
%%%    A number, 0-mean
%%%              1-linear
%%%              2-quadratic, starting to get the idea?
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DetrendOrder  = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The code users COMPCOR.
%%% Use this many principle components for regression
%%% for the CSF and WM
%%%
%%% PCA COMPCOR Parameter
%%%        Fraction - fraction of variance for principle components
%%%
%%% Behzadi Y, Restom K, Liau J, Liu TT.
%%% A Component Based Noise Correction Method (CompCor) for BOLD and
%%% Perfusion Based fMRI. NeuroImage 2007;37:90–101.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrincipalComponents = 5;
Fraction            = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Bandpass Filter Settings
%%%        LowFrequency - low frequency cutoff
%%%        HighFrequency - high frequency cutoff
%%%        Gentle - 0 = no rolling, 1 = rolling, 2 = extra rolling
%%%        Padding - number of timepoints to pad on beginning/end
%%%        BandpassFilter - 0 = Matlab filter, 1 = SOM_Filter_FFT
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LowFrequency   = 0.01;
HighFrequency  = 0.1;
Gentle         = 1;
Padding        = 10;
BandpassFilter = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% the order to perform the regressions etc
%%%         D = detrend      - Nth order detrend
%%%         S = despike      - by replacement
%%%         M = motion       - by regression, includes dM/dt
%%%         G = global       - Controversial, you should know the lit.
%%%         W = white matter - by PCA
%%%         C = csf          - by PCA
%%%         B = bandpass     - by method selected.
%%%         E = edit         - by removal
%%%
%%%         Suggested order is "DSM[G]CWB"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RegressOrder = 'DSMCWEB';

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
ROIInput = 'coordinates';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% 'coordinates' method
%%%
%%% If specifying ROI coordinates you need to provide a list of centers in
%%% MNI coordinates (mm) and a radius in voxels.
%%%
%%% NOTE: ROISize will be used as the radius (in voxels, can be fracional
%%% of a sphere at each point.
%%% If you'd prefer to use the predefined 1,7,19, or 27 voxel sizes you will
%%% need to specify the size as a cell (i.e. {19})
%%%
%%% See the MethodsCore/ConnTool/Documentation for more help on ROI size.
%%%
%%% You can load a file into the array ROICenters.
%%%
%%% If a ".csv" file you would do:
%%%
%%%    ROICenters = load('myROIs.csv');
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ROICenters = [0 -48 26];
ROISize    = {19};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% 'coordload' method
%%%
%%% If a '.mat" file you need make sure it contains a single array
%%% with each row being an ROI and columns are x,y,z, in MNI mm.
%%%
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
%%%
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
%%%
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
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ROIGridCenters = [
     10 10  10;
    -10 10  10;
    -22  0 -22;
     22  0 -22;
    ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Where to output the data and what to call it.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OutputTemplate  = '[Exp]/FirstLevel/[Subject]/[OutputName]/';
OutputName      = 'ConnToolTest5';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Type of output
%%%         images - output R and Z images of correlation with each seed
%%%         maps   - output R,P, and Z matrices of correlations between seeds
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OutputType     = 'images';

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

% You can save the time course of a single voxel at each step of the 
% processing to get a sense of what happens. 
% Leave empty if you don't want it.

voxelIDX       = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Do not edit below this line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%DEVSTART
mcRoot = '/Users/rcwelsh/src/git/MethodsCore';
%DEVSTOP

%[DEVmcRootAssign]

addpath(fullfile(mcRoot,'matlabScripts'));
addpath(fullfile(mcRoot,'ConnTool'));
addpath(fullfile(mcRoot,'ConnTool/Code'));
addpath(fullfile(mcRoot,'ConnTool/matlab'),'-END');
addpath(fullfile(mcRoot,'SPM','SPM8','spm8_with_R4667'));

ConnToolCallingScriptName = which(mfilename);

ConnTool_batch_mc_central
