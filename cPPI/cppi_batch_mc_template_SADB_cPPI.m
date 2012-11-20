%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GENERAL OPTIONS
%%%	These options are shared among many of our scripts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The folder that contains your subject folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/data/SADB_cPPI';

LogTemplate = '[Exp]/Logs/cPPI/';

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
ImageTemplate = '[Exp]/Subjects/[Subject]/func/[Run]/';

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
%'C003_scan1',1,[1],[0];
'C003_scan2',2,[1],[0];
'CC004_scan1',3,[1],[0];
'CC004_scan2',4,[1],[0];
'C005_scan1',5,[1],[0];
'CC005_scan1',6,[1],[0];
'C005_scan2',7,[1],[0];
'CC005_scan2',8,[1],[0];
'C006_scan1',9,[1],[0];
'C006_scan2',10,[1],[0];
'C007_scan1',11,[1],[0];
'CC007_scan1',12,[1],[0];
'CC007_scan2',13,[1],[0];
'C008_scan1',14,[1],[0];
'C008_scan2',15,[1],[0];
'CC009_scan1',16,[1],[0];
'CC009_scan2',17,[1],[0];
'C010_scan1',18,[1],[0];
'C010_scan2',19,[1],[0];
'CC011_scan1',20,[1],[0];
'CC011_scan2',21,[1],[0];
'C012_scan1',22,[1],[0];
'CC013_scan1',23,[1],[0];
'CC013_scan2',24,[1],[0];
'CC014_scan1',25,[1],[0];
'CC014_scan2',26,[1],[0];
'C016_scan1',27,[1],[0];
'CC016_scan1',28,[1],[0];
'C017_scan1',29,[1],[0];
'C019_scan1',30,[1],[0];
'C019_scan2',31,[1],[0];
'C020_scan1',32,[1],[0];
'C020_scan2',33,[1],[0];
'CC022_scan1',34,[1],[0];
'C024_scan1',35,[1],[0];
'C024_scan2',36,[1],[0];
'C025_scan1',37,[1],[0];
'CC025_scan1',38,[1],[0];
'CC025_scan2',39,[1],[0];
'C026_scan1',40,[1],[0];
'C027_scan1',41,[1],[0];
'C029_scan1',42,[1],[0];
'CC029_scan1',43,[1],[0];
'CC029_scan2',44,[1],[0];
'C030_scan1',45,[1],[0];
'C031_scan1',46,[1],[0];
'C031_scan2',47,[1],[0];
'C032_scan1',48,[1],[0];
'C032_scan2',49,[1],[0];
'C033_scan1',50,[1],[0];
'C033_scan2',51,[1],[0];
'C034_scan1',52,[1],[0];
'C034_scan2',53,[1],[0];
'C039_scan1',54,[1],[0];
'C044_scan1',55,[1],[0];
'C044_scan2',56,[1],[0];
'C049_scan1',57,[1],[0];
'C054_scan1',58,[1],[0];
'C055_scan1',59,[1],[0];
'C056_scan1',60,[1],[0];
'C057_scan1',61,[1],[0];
'C058_scan1',62,[1],[0];
'C059_scan1',63,[1],[0];
'CAAD062_scan1',64,[1],[0];
'CAAD062_scan2',65,[1],[0];
'CAAD086_scan1',66,[1],[0];
'CAAD089_scan1',67,[1],[0];
'CAHC010_scan1',68,[1],[0];
'CAHC010_scan2',69,[1],[0];
'CAHC012_scan1',70,[1],[0];
'CAHC014_scan1',71,[1],[0];
'CAHC014_scan2',72,[1],[0];
'CAHC023_scan1',73,[1],[0];
'CAHC026_scan1',74,[1],[0];
'CAHC026_scan2',75,[1],[0];
'CAHC027_scan1',76,[1],[0];
'CAHC027_scan2',77,[1],[0];
'CAHC031_scan1',78,[1],[0];
'CAHC031_scan2',79,[1],[0];
'CAHC034_scan1',80,[1],[0];
'CAHC035_scan1',81,[1],[0];
'H_SADA001_scan1',82,[1],[0];
'H_SADA004_scan1',83,[1],[0];
'H_SADB001_scan1',84,[1],[0];
'H_SADB002_scan1',85,[1],[0];
'H_SADB002_scan2',86,[1],[0];
'H_SADB003_scan1',87,[1],[0];
'H_SADB003_scan2',88,[1],[0];
'H_SADB004_scan1',89,[1],[0];
'H_SADB005_scan1',90,[1],[0];
'H_SADB012_scan1',91,[1],[0];
'H_SADB012_scan2',92,[1],[0];
'H_SADB018_scan1',93,[1],[0];
'H_SADB018_scan2',94,[1],[0];
'H_SADB020_scan1',95,[1],[0];
'H_SADB021_scan1',96,[1],[0];
'H_SADB021_scan2',97,[1],[0];
'H_SADB030_scan1',98,[1],[0];
'H_SADB030_scan2',99,[1],[0];
'H_SADB031_scan1',100,[1],[0];
'H_SADB033_scan1',101,[1],[0];
'H_SADB033_scan2',102,[1],[0];
'P_SADB006_scan1',103,[1],[0];
'P_SADB007_scan1',104,[1],[0];
'P_SADB007_scan2',105,[1],[0];
'P_SADB008_scan1',106,[1],[0];
'P_SADB008_scan2',107,[1],[0];
'P_SADB010_scan1',108,[1],[0];
'P_SADB010_scan2',109,[1],[0];
'P_SADB011_scan1',110,[1],[0];
'P_SADB013_scan1',111,[1],[0];
'P_SADB013_scan2',112,[1],[0];
'P_SADB014_scan1',113,[1],[0];
'P_SADB014_scan2',114,[1],[0];
'P_SADB015_scan1',115,[1],[0];
'P_SADB015_scan2',116,[1],[0];
'P_SADB016_scan1',117,[1],[0];
'P_SADB016_scan2',118,[1],[0];
'P_SADB017_scan1',119,[1],[0];
'P_SADB022_scan1',120,[1],[0];
'P_SADB022_scan2',121,[1],[0];
'P_SADB023_scan1',122,[1],[0];
'P_SADB023_scan2',123,[1],[0];
'P_SADB024_scan1',124,[1],[0];
'P_SADB025_scan1',125,[1],[0];
'P_SADB025_scan2',126,[1],[0];
'P_SADB026_scan1',127,[1],[0];
'P_SADB026_scan2',128,[1],[0];
'P_SADB027_scan1',129,[1],[0];
'P_SADB027_scan2',130,[1],[0];
'P_SADB028_scan1',131,[1],[0];
'P_SADB029_scan1',132,[1],[0];
'P_SADB029_scan2',133,[1],[0];
'P_SADB032_scan1',134,[1],[0];
'P_SADB032_scan2',135,[1],[0];
'S002_scan1',136,[1],[0];
'S002_scan2',137,[1],[0];
'S004_scan1',138,[1],[0];
'S004_scan2',139,[1],[0];
'S005_scan1',140,[1],[0];
'S005_scan2',141,[1],[0];
'S006_scan1',142,[1],[0];
'S006_scan2',143,[1],[0];
'S007_scan1',144,[1],[0];
'S007_scan2',145,[1],[0];
'S009_scan1',146,[1],[0];
'S009_scan2',147,[1],[0];
'S010_scan1',148,[1],[0];
'S014_scan1',149,[1],[0];
'S014_scan2',150,[1],[0];
'S015_scan1',151,[1],[0];
'S015_scan2',152,[1],[0];
'S020_scan1',153,[1],[0];
'S020_scan2',154,[1],[0];
'S025_scan1',155,[1],[0];
'S025_scan2',156,[1],[0];
'S026_scan1',157,[1],[0];
'S026_scan2',158,[1],[0];
'S027_scan1',159,[1],[0];
'S027_scan2',160,[1],[0];
'S031_scan1',161,[1],[0];
'S032_scan1',162,[1],[0];
'S033_scan1',163,[1],[0];
'S033_scan2',164,[1],[0];
'S034_scan1',165,[1],[0];
'S034_scan2',166,[1],[0];
'S035_scan1',167,[1],[0];
'S035_scan2',168,[1],[0];
'S037_scan1',169,[1],[0];
'S037_scan2',170,[1],[0];
'S038_scan1',171,[1],[0];
'S038_scan2',172,[1],[0];
'S039_scan1',173,[1],[0];
'S040_scan1',174,[1],[0];
'S041_scan1',175,[1],[0];
'S041_scan2',176,[1],[0];
'S042_scan1',177,[1],[0];
'S042_scan2',178,[1],[0];
'S043_scan1',179,[1],[0];
'S043_scan2',180,[1],[0];
'S044_scan1',181,[1],[0];
'S044_scan2',182,[1],[0];
'S046_scan1',183,[1],[0];
'S046_scan2',184,[1],[0];
'S048_scan1',185,[1],[0];
'S048_scan2',186,[1],[0];
'S050_scan1',187,[1],[0];
'S050_scan2',188,[1],[0];
'S051_scan1',189,[1],[0];
'S051_scan2',190,[1],[0];
'S062_scan1',191,[1],[0];
'S062_scan2',192,[1],[0];
'S063_scan1',193,[1],[0];
'S064_scan1',194,[1],[0];
'S065_scan1',195,[1],[0];
'S065_scan2',196,[1],[0];
'S072_scan1',197,[1],[0];
'S090_scan1',198,[1],[0];
'S090_scan2',199,[1],[0];
'S091_scan1',200,[1],[0];
'S091_scan2',201,[1],[0];
'S092_scan1',202,[1],[0];
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
nop = 'w2mm_';
smp = 's6mm_';

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
NumScan = [180]; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CONNECTONOMIC PPI OPTIONS
%%%	These options are only used for cPPI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Original First Level Model location
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SPMTemplate = '[Exp]/FirstLevel/[Subject]/HARIRI/';

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
NumProcesses = 12;

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
GreyMatterTemplate = '[Exp]/ROIs/rEPI_MASK_NOEYES_betaspace.img';
WhiteMatterTemplate = '[Exp]/ROIs/rEPI_MASK_NOEYES_betaspace.img';
CSFTemplate = '[Exp]/ROIs/rEPI_MASK_NOEYES_betaspace.img';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Where to output the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OutputTemplate = '[Exp]/FirstLevel/[Subject]/[OutputName]/';
OutputName = 'HARIRI_cppi';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path and name of explicit mask to use at first level.
%%% Leaving this blank ('') will use a subject-specific mask
%%% NOTE: Subject-specific masks are not recommended for grid usage below.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BrainMaskTemplate = '[Exp]/ROIs/rEPI_MASK_NOEYES_betaspace.img';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path Template for realignment parameters file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RealignmentParametersTemplate = '[Exp]/Subjects/[Subject]/func/[Run]/mcflirt*.dat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Constrain results to only regions in GreyMatterTemplate (1=yes, 0=no)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MaskGrey = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Value threshold to use for each mask.  If left as [] use default 0.75
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GreyThreshold = [0];
WhiteThreshold = [0];
CSFThreshold = [0];
EPIThreshold = [0];

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
ROIGridMaskTemplate = '[Exp]/ROIs/rEPI_MASK_NOEYES_betaspace.img';
















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
mcRoot = fullfile(fileparts(mfilename('fullpath')),'../../MethodsCoreDev');
%DEVSTOP

%[DEVmcRootAssign]

addpath(fullfile(mcRoot,'matlabScripts'));
addpath(fullfile(mcRoot,'cPPI'));
addpath(fullfile(mcRoot,'som'));
addpath(fullfile(mcRoot,'SPM/SPM8/spm8_with_R4667'));

cppi_batch_mc_central