%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GENERAL OPTIONS
%%%	These options are shared among many of our scripts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The version of SPM to use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spmversion = 'spm8';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The folder that contains your subject folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/net/data4/MAS/';
%Exp = '/dysthymia/sandbox/MAS/';

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
ImageTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% A list of run folders where the script can find functional images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RunDir = {
	'run_01/';
};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The list of subjects to process
%%% The format is 'subjectfolder',subject number in masterfile,[runs to include]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjDir = {
  
%     '5034/Tx2',50342,[1];  
'5001/Tx1',50011,[1];
'5002/Tx1',50021,[1];
'5003/Tx1',50031,[1];
'5004/Tx1',50041,[1];
'5005/Tx1',50051,[1];
'5010/Tx1',50101,[1];
'5012/Tx1',50121,[1];
'5014/Tx1',50141,[1];
'5015/Tx1',50151,[1];
'5016/Tx1',50161,[1];
'5017/Tx1',50171,[1];
'5018/Tx1',50181,[1];
'5019/Tx1',50191,[1];
'5020/Tx1',50201,[1];
'5021/Tx1',50211,[1];
'5023/Tx1',50231,[1];
'5024/Tx1',50241,[1];
'5025/Tx1',50251,[1];
'5026/Tx1',50261,[1];
'5028/Tx1',50281,[1];
'5029/Tx1',50291,[1];
'5031/Tx1',50311,[1];
'5032/Tx1',50321,[1];
'5034/Tx1',50341,[1];
'5035/Tx1',50351,[1];
'5036/Tx1',50361,[1];
'5037/Tx1',50371,[1];
'5038/Tx1',50381,[1];
'5039/Tx1',50391,[1];
'5040/Tx1',50401,[1];
'5041/Tx1',50411,[1];
'5042/Tx1',50421,[1];

'5001/Tx2',50012,[1];
'5002/Tx2',50022,[1];
'5003/Tx2',50032,[1];
'5004/Tx2',50042,[1];
'5005/Tx2',50052,[1];
'5010/Tx2',50102,[1];
'5012/Tx2',50122,[1];
'5014/Tx2',50142,[1];
'5015/Tx2',50152,[1];
'5016/Tx2',50162,[1];
'5017/Tx2',50172,[1];
'5018/Tx2',50182,[1];
'5019/Tx2',50192,[1];
'5020/Tx2',50202,[1];
'5021/Tx2',50212,[1];
'5023/Tx2',50232,[1];
'5024/Tx2',50242,[1];
'5025/Tx2',50252,[1];
'5026/Tx2',50262,[1];
'5028/Tx2',50282,[1];
'5029/Tx2',50292,[1];
'5031/Tx2',50312,[1];
'5032/Tx2',50322,[1];
'5034/Tx2',50342,[1];
'5035/Tx2',50352,[1];
'5036/Tx2',50362,[1];
'5037/Tx2',50372,[1];
'5038/Tx2',50382,[1];
'5039/Tx2',50392,[1];
'5040/Tx2',50402,[1];
'5041/Tx2',50412,[1];
'5042/Tx2',50422,[1];

          };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The TR your data was collected at
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TR = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Prefixes for slicetiming, realignment, normalization, and smoothing (spm8 only)
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
basefile = 'restrun';

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
%%% The filename to use for saving/loading parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ParameterFilename = '12mmGrid_parameters';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Paths to your anatomical images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GreyMatterTemplate = '[Exp]/Subjects/[Subject]/anatomy/rgrey.img';
WhiteMatterTemplate = '[Exp]/Subjects/[Subject]/anatomy/wm_mask.nii';
CSFTemplate = '[Exp]/Subjects/[Subject]/anatomy/csf_mask.nii';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Where to output the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OutputTemplate = '[Exp]/FirstLevel/[Subject]/[OutputName]/';
OutputName = '12mmGrid';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path and name of explicit mask to use at first level.
%%% Leave this blank ('') to turn off explicit masking
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BrainMaskTemplate = '[Exp]/ROIS/rEPI_MASK_NOEYES.img';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path Template for realignment parameters file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RealignmentParametersTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/rp_arestrun_*';

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
%%% If specifying ROI coordinates you need to provide a list of centers and
%%% a radius both in mm.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ROICenters = [
    0 -53 26;
    ];
ROISize = 4;

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
%%% If specifying ROI gri you need to provide a spacing as well as a
%%% mask for point inclusion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ROIGridSpacing = 12;
ROIGridRadius = 4;
ROIGridMaskTemplate = '[Exp]/ROIS/ravg_gm_mask.nii';

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
addpath(fullfile(mcRoot,'som'));
addpath(fullfile(mcRoot,spmversion));

som_batch_mc_central