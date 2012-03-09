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
%%  Path where your images are located
%%
%%  Variables you can use in your template are:
%%       Exp = path to your experiment directory
%%       iSubject = index for subject
%%       Subject = name of subject from SubjDir (using iSubject as index of row)
%%       iRun = index of run (listed in Column 3 of SubjDir)
%%       Run = name of run from RunDir (using iRun as index of row)
%%        * = wildcard (can only be placed in final part of template)
%% Examples:
%% ImageTemplate = '[Exp]/Subjects/[Subject]/func/run_0[iRun]/';
%% ImageTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ImageTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% A list of run folders where the script can find functional images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RunDir = {
	'run_01/';
	'run_02/';
};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The list of subjects to process
%%% The format is 'subjectfolder',subject number in masterfile,[runs to include]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjDir = {
 '5034/Tx2',50342,[1], 0, 0;
 '5035/Tx1',50351,[1 2], 0, 0;
 '5035/Tx2',50352,[1 2], 0, 0;
 '5036/Tx1',50361,[1], 0, 0;
 '5036/Tx2',50362,[1], 0, 0;
 '5037/Tx1',50371,[1], 0, 0;
 '5037/Tx2',50372,[1], 0, 0;
 '5038/Tx1',50381,[1], 0, 0;
 '5038/Tx2',50382,[1], 0, 0;
 '5039/Tx1',50391,[1], 0, 0;
 '5039/Tx2',50392,[1], 0, 0;
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
NumScan = [180 180]; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CONNECTIVITY OPTIONS
%%%	These options are only used for Connectivity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Paths to your anatomical images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GrayMatterTemplate = '[Exp]/Subjects/[Subject]/anatomy/';
WhiteMatterTemplate = '[Exp]/Subjects/[Subject]/anatomy/';
CSFTemplate = '[Exp]/Subjects/[Subject]/anatomy/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The voxel size to reslice your images to after normalization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vox_size = [3 3 3];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Where to output the data
%%% OutputDir is constructed by /Exp/OutputLevel1/subjDir/OutputLevel2/OutputLevel3/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OutputTemplate = '[Exp]/FirstLevel/[Subject]/[OutputName]/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path and name of explicit mask to use at first level.
%%% Leave this blank ('') to turn off explicit masking
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
explicitmask = '';
