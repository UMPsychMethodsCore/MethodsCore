%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GENERAL OPTIONS
%%%	These options are shared among many of our scripts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The path to SPM on your system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spmpath = '/net/dysthymia/spm8';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The folder that contains your subject folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/net/data4/MAS/';

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

    % '5034/Tx2',50342,[1];
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
%%% CONNECTIVITY OPTIONS
%%%	These options are only used for Connectivity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Paths to your anatomical images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GreyMatterTemplate = '[Exp]/Subjects/[Subject]/anatomy/rgrey.img';
WhiteMatterTemplate = '[Exp]/Subjects/[Subject]/anatomy/rwhite.img';
CSFTemplate = '[Exp]/Subjects/[Subject]/anatomy/rcsf.img';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The voxel size to reslice your images to after normalization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vox_size = [3 3 3];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Where to output the data
%%% OutputDir is constructed by /Exp/OutputLevel1/subjDir/OutputLevel2/OutputLevel3/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OutputTemplate = '[Exp]/FirstLevel/[Subject]/[OutputName]/';
OutputName = 'TEST';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path and name of explicit mask to use at first level.
%%% Leave this blank ('') to turn off explicit masking
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BrainMaskTemplate = '';

RealignmentParametersTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/rp_arun_*';



MaskGrey = 0;
GreyThreshold = 0.75;
RegressWhite = 1;
RegressCSF = 1;
MaskBrain = 1;
RegressMotion = 1;
PrincipalComponents = 5;
RegressGlobal = 0;
ProcessOrder = 'DCWMB';

DoBandpassFilter = 1;
DoLinearDetrend = 1;
LowFrequency = 0.01;
HighFrequency = 0.1;
Gentle = 1;
Padding = 10;

BandpassFilter = 1;
Fraction = 1;

ROISize = 2;

addpath /net/dysthymia/mangstad/repos/MethodsCore/matlabScripts
addpath /net/dysthymia/mangstad/repos/MethodsCore/som
addpath /net/dysthymia/spm8
Subject = SubjDir{1,1};
Run = RunDir{1};
Pswra = 'swra';
som_batch_mc_central