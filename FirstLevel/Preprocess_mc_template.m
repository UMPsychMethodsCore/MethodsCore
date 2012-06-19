%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GENERAL OPTIONS
%%%	These options are the same between Preprocessing and First level
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The folder that contains your subject folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/net/data4/MAS/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path where your logfiles will be stored
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LogTemplate = '[Exp]/Logs';


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
%%% A list of run folders where the script can find the images to use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RunDir = {
	'run_01/';
%	'run_06/';
};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The list of subjects to process
%%% The format is 'subjectfolder',subject number in masterfile,[runs to include]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjDir = {
%  '5001/Tx2',50012,[1 2],[215 235], 0;
%  '5002/Tx2',50022,[1 2],[225 240], 0;
%  '5003/Tx1',50031,[1 2], [225 240], {'run_04/';'run_05/'};
% 
% '5004/Tx1',50041,[1 2], 0, 0;
% '5005/Tx1',50051,[1 2], 0, 0;
% '5008/Tx1',50081,[1 2], 0, 0;
% '5010/Tx1',50101,[1 2], 0, 0;
% % '5011/Tx1',50111,[1 2], 0, 0; %This subject has too many error trials
% '5012/Tx1',50121,[1 2], 0, 0; 
% '5013/Tx2',50132,[1 2], 0, 0;
% '5014/Tx2',50142,[1 2], 0, 0;
% '5015/Tx2',50152,[1 2], 0, 0;
% '5016/Tx1',50161,[1 2], 0, 0;
% '5017/Tx1',50171,[1 2], 0, 0;
% '5018/Tx2',50182,[1 2], 0, 0;
% '5019/Tx1',50191,[1 2], 0, 0;
% '5020/Tx2',50202,[1 2], 0, 0;
% '5021/Tx1',50211,[1 2], 0, 0;
% '5023/Tx2',50232,[1 2], 0, 0;
% '5024/Tx1',50241,[1 2], 0, 0;
% '5025/Tx2',50252,[1 2], 0, 0;
% '5026/Tx2',50262,[1 2], 0, 0;
% '5028/Tx1',50281,[1 2], 0, 0;
% '5029/Tx1',50291,[1 2], 0, 0;
% '5031/Tx1',50311,[1 2], 0, 0;
% '5032/Tx1',50321,[1 2], 0, 0;

% '5034/Tx1',50341,[1], 0, 0;
 '5034/Tx2',50342,[1], 0, 0;
% '5035/Tx1',50351,[1 2], 0, 0;
% '5035/Tx2',50352,[1 2], 0, 0;
 '5036/Tx1',50361,[1], 0, 0;
 '5036/Tx2',50362,[1], 0, 0;
 '5037/Tx1',50371,[1], 0, 0;
 '5037/Tx2',50372,[1], 0, 0;
 '5038/Tx1',50381,[1], 0, 0;
 '5038/Tx2',50382,[1], 0, 0;
 '5039/Tx1',50391,[1], 0, 0;
 '5039/Tx2',50392,[1], 0, 0;
% '5040/Tx1',50401,[1 2], 0, 0;
% % '5040/Tx2',50402,[1 2], 0, 0;
% % '5041/Tx1',50411,[1 2], 0, 0;
% '5041/Tx2',50412,[1 2], 0, 0;
% % '5042/Tx1',50421,[1 2], 0, 0;
% '5042/Tx2',50422,[1 2], 0, 0;

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
alreadydone = [0 0 0 0];

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
%%% PREPROCESSING OPTIONS
%%%	These options are only used for Preprocessing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Paths to your anatomical images
%%
%%  Variables you can use in your templates are:
%%       Exp = path to your experiment directory
%%       iSubject = index for subject
%%       Subject = name of subject from SubjDir (using iSubject as index of row)
%%        * = wildcard (can only be placed in final part of template)
%% Examples:
%% OverlayTemplate = '[Exp]/Subjects/[Subject]/anatomy/Overlay*'
%% HiresTemplate = '[Exp]/Subjects/[Subject]/anatomy/SPGR.nii';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

OverlayTemplate = '[Exp]/Subjects/[Subject]/anatomy/OVERLAY.nii';

HiresTemplate =    '[Exp]/Subjects/[Subject]/anatomy/HIRESSAG.nii';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The normalization method
%%%      func = normalization of functional images to functional template
%%%      anat = normalization of anatomical images to anatomical template
%%%      seg  = normalization by segmentation of anatomical image
%%%      note: seg will use VMB8 with DARTEL warping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
normmethod = 'func';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The template to normalize the functional images to 
%%% NOTE: only applies to func or anat methods, not seg
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

WarpTemplate = '/net/dysthymia/mangstad/spm8//templates/T1.nii';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The number of slices in your functional images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_slices = 43; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The order of your slice collection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slice_order = [1:1:num_slices];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The voxel size to reslice your images to after normalization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vox_size = [3 3 3];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The size of the kernel to smooth your data with
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
kernel = 8;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Set to 1 to do each step or 0 to skip
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
doslicetiming = 1;
dorealign = 1;
docoreg = 1;
donormalize = 1;
dosmooth = 1;

global mcRoot;
%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..');
%DEVSTOP

%[DEVmcRootAssign]

addpath(fullfile(mcRoot,'matlabScripts'))
addpath(fullfile(mcRoot,'FirstLevel'))
addpath(fullfile(mcRoot,'spm8'))



Processing = [1 0];
PreprocessFirstLevel_central