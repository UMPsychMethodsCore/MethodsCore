%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GENERAL OPTIONS
%%%	These options are shared among many of our scripts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The folder that contains your subject folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/home/slab/mnt/psyche/net/data4/GO2010/';

LogTemplate = '[Exp]/PROJECTS/MSIT/Logs/cPPI/';

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
ImageTemplate = '[Exp]/DataLinks/MSIT/[Subject]/[Run]/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% A list of run folders where the script can find functional images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RunDir = {
	'MSIT01';
    'MSIT02';
    'MSIT03';
    'MSIT04';
};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The list of subjects to process
%%% The format is 'subjectfolder',subject number in masterfile,[runs to include]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjDir = {
%'022',22,[1 2 3 4],0,0;
%'024',24,[1 2 3 4],0,0;
'046',46,[1 2 3 4],0,0;
%'066',66,[1 2 3 4],0,0;
%'074',74,[1 2 3 4],0,0;
'076',76,[1 2 3 4],0,0;
%'081',81,[1 2 3 4],0,0;
%'084',84,[1 2 3 4],0,0;
%'095',95,[1 2 3 4],0,0;
%'102',102,[1 2 3 4],0,0;
%'103',103,[1 2 3 4],0,0;
'107',107,[1 2 3 4],0,0;
%'110',110,[1 2 3 4],0,0;
%'111',111,[1 2 3 4],0,0;
%'124',124,[1 2 3 4],0,0;
%'133',133,[1 2 3 4],0,0;
%'137',137,[1 2 3 4],0,0;
%'138',138,[1 2 3 4],0,0;
%'142',142,[1 2 3 4],0,0;
%'143',143,[1 2 3 4],0,0;
'148',148,[1 2 3 4],0,0;
%'153',153,[1 2 3 4],0,0;
%'157',157,[1 2 3 4],0,0;
'158',158,[1 2 3 4],0,0;
%'160',160,[1 2 3 4],0,0;
'162',162,[1 2 3 4],0,0;
%'167',167,[1 2 3 4],0,0;
%'173',173,[1 2 3 4],0,0;
%'174',174,[1 2 3 4],0,0; 
'176',176,[1 2 3 4],0,0; 
%'191',191,[1 2 3 4],0,0; 
%'200',200,[1 2 3 4],0,0; 
'202',202,[1 2 3 4],0,0; 
'203',203,[1 2 3 4],0,0; 
'206',206,[1 2 3 4],0,0; 
%'207',207,[1 2 3 4],0,0; 
'218',218,[1 2 3 4],0,0; 
%'219',219,[1 2 3 4],0,0; 
'221',221,[1 2 3 4],0,0; 
%'227',227,[1 2 3 4],0,0; 
%'229',229,[1 2 3 4],0,0; 
%'233',233,[1 2 3 4],0,0; 
'235',235,[1 2 3 4],0,0; 
%'237',237,[1 2 3 4],0,0; 
%'245',245,[1 2 3 4],0,0; 
'251',251,[1 2 3 4],0,0; 
'256',256,[1 2 3 4],0,0; 
'268',268,[1 2 3 4],0,0; 
%'269',269,[1 2 3 4],0,0; 
%'293',293,[1 2 3 4],0,0; 
%'331',331,[1 2 3 4],0,0; 
%%'332',332,[1 2 3 4],0,0; %no spm.mat?
%%'344',344,[1 2 3 4],0,0; %no spm.mat?
          };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The TR your data was collected at
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TR = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Prefixes for slicetiming, realignment, normalization, and smoothing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stp = 'a';
rep = 'r';
nop = 'w';
smp = 's';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Preprocessing that has already been completed on images
%%% [slicetime realign normalize smooth]
%%% If you are only running First Level (i.e. Preprocessing is already done)
%%% setting these will add the appropriate prefix to the basefile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
alreadydone = [1 1 1 1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The  prefix of each functional file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basefile = 'run';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Image Type should be either 'nii' or 'img'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imagetype = 'nii';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Number of Functional scans per run
%%% (if you have more than 1 run, there should be more than 1 value here)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NumScan = [110 110 110 110]; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CONNECTONOMIC PPI OPTIONS
%%%	These options are only used for cPPI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Original First Level Model location
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SPMTemplate = '[Exp]/PROJECTS/MSIT/FirstLevel/[Subject]/MSIT/HRF/fixdur/Congruency_NORT/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Include Realignment Parameters in your PPI model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IncludeMotion = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Analyze data on a local drive on the machine you run the script on
%%% If your data is located on /net/data4 or similar network drive, using
%%% this option will speed up the processing speed immensely.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
UseSandbox = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The script will split the number of ROIs into this many seperate bins
%%% and run them simultaneously to speed up processing time.  Be careful
%%% with setting this too high as it could cause the computer running the
%%% script to become unresponsive or crash.  Please use the linux command
%%% top to investigate other processes running on the computer before
%%% starting your script.  In general you should not set this higher than
%%% 4.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NumProcesses = 16;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Mode to run som_batch_mc_central in
%%%        'test'       = test script but do not save parameters or run any
%%%                       SOM code
%%%        'parameters' = run script and save parameters for each subject
%%%                       but do not run any SOM code
%%%        'cppi'        = run SOM code on previously saved parameters
%%%        'full'       = generate parameters and immediately run SOM code
%%%
%%%        NOTE: If you choose mode 'cppi' then most variables except
%%%        SubjDir and OutputTemplate/OutputName will be ignored as they
%%%        will be loaded from the already existing parameter file for each
%%%        subject.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Mode = 'full';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Paths to your anatomical images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GreyMatterTemplate = '[Exp]/ROIS/rEPI_MASK_NOEYES_betaspace.img';
WhiteMatterTemplate = '[Exp]/ROIS/rEPI_MASK_NOEYES_betaspace.img';
CSFTemplate = '[Exp]/ROIS/rEPI_MASK_NOEYES_betaspace.img';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Where to output the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OutputTemplate = '[Exp]/PROJECTS/MSIT/FirstLevel/[Subject]/MSIT/HRF/fixdur/[OutputName]/';
OutputName = 'Congruency_NORT_cppi';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path and name of explicit mask to use at first level.
%%% Leaving this blank ('') will use a subject-specific mask
%%% NOTE: Subject-specific masks are not recommended for grid usage below.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BrainMaskTemplate = '[Exp]/ROIS/rEPI_MASK_NOEYES_betaspace.img';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path Template for realignment parameters file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RealignmentParametersTemplate = '[Exp]/DataLinks/MSIT/[Subject]/[Run]/rp*.txt';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Constrain results to only regions in GreyMatterTemplate (1=yes, 0=no)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MaskGrey = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Value threshold to use for each mask.  If left as [] use default 0.75
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GreyThreshold = [];
WhiteThreshold = [];
CSFThreshold = [];
EPIThreshold = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% the order to perform the regressions etc
%%%         D = detrend
%%%         G = global
%%%         W = white matter
%%%         C = csf
%%%         M = motion
%%%         B = bandpass
%%% 
%%%         Suggested order is "DCWM"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RegressOrder = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Use this many principle components for regression
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrincipalComponents = 5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Bandpass Filter Settings
%%%        LowFrequency - low frequency cutoff
%%%        HighFrequency - high frequency cutoff
%%%        Gentle - 0 = no rolling, 1 = rolling
%%%        Padding - number of timepoints to pad on beginning/end
%%%        BandpassFilter - 0 = Matlab filter, 1 = SOM_Filter_FFT
%%%        Fraction - fraction of variance for principle components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LowFrequency = 0.01;
HighFrequency = 0.1;
Gentle = 1;
Padding = 10;
BandpassFilter = 1;
Fraction = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Type of input
%%%         coordinates - provide the center of each seed and a radius
%%%         files       - provide a list of ROI files
%%%         grid        - make a grid based on provided spacing and masked
%%%                       by provided mask
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ROIInput = 'grid';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% If specifying ROI coordinates you need to provide a list of centers in 
%%% MNI coordinates (mm) and a radius in voxels.
%%% NOTE: ROISize will be used as the radius of a sphere at each point. If 
%%% you'd prefer to use the predefined 1,7,19, or 27 voxel sizes you will 
%%% need to specify the size as a cell (i.e. {19})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ROICenters = [
    18 -1 1; %VSi right
    -18 -1 1; %VSi left
    10 10 10;
    10 10 -10;
    10 -10 10;
    10 -10 -10;
%     -10 10 10;
%     -10 10 -10;
%     -10 -10 10;
%     -10 -10 -10;
%     5 5 5;
%     5 5 -5;
%     5 -5 5;
%     5 -5 -5;
%     -5 5 5;
%     -5 5 -5;
%     -5 -5 5;
%     -5 -5 -5;
    ];
ROISize = {1};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% If specifying ROI images you need to provide an ROI folder as well as a
%%% cell array list of ROI images.
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
ROIGridSpacing = 12;
ROIGridSize = {19};
ROIGridMaskTemplate = '[Exp]/ROIS/rEPI_MASK_NOEYES_betaspace.img';
















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Type of output
%%%         images - output R and Z images of correlation with each seed
%%%         maps   - output R and P matrix of correlations between seeds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ROIOutput = 'maps';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Do not edit below this line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'../../MethodsCore');
%DEVSTOP

%[DEVmcRootAssign]

addpath(fullfile(mcRoot,'matlabScripts'));
addpath(fullfile(mcRoot,'cPPI'));
addpath(fullfile(mcRoot,'som'));
addpath(fullfile(mcRoot,'SPM/SPM8/spm8_with_R4667'));

cppi_batch_mc_central