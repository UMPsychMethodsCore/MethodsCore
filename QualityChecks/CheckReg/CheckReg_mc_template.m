%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Experiment Directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/net/data4/MAS/';  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The list of subjects 
%%% col 1 = subject id as string, col 2 = subject id as number, col 3 = runs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjDir = {
'5032/Tx1',50321,[1 2];
'5034/Tx2',50232,[1 2];
'5035/Tx2',50241,[1 2];
'5036/Tx2',50252,[1 2];
'5037/Tx2',50262,[1 2];
'5038/Tx2',50281,[1 2];
'5040/Tx1',50291,[1 2];
'5041/Tx2',50311,[1 2];
'5042/Tx2',50321,[1 2];   
}; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% List the run directories that you want to process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RunDir = { 
'run_01/';
'run_02/'
'run_03/'
'run_04/'
'run_05/'
'run_06/'
};  
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OverlayTemplate: Path to overlay template
%% HiResTemplate  : Path to hires template
%% ImageTemplate  : Path to image locations
%%
%%  Variables you can use in your template are:
%%       Exp      = path to your experiment directory
%%       iSubject = index for subject
%%       Subject  = name of subject from SubjDir (using iSubject as index of row)
%%       iRun     = index of run (listed in Column 3 of SubjDir)
%%       Run      = name of run from RunDir (using iRun as index of row)
%%        *       = wildcard (can only be placed in final part of template)
%% Examples:
%% OverlayTemplate = '[Exp]/Subjects/[Subject]/anatomy/OVERLAY.nii';
%% HiResTemplate   = '[Exp]/Subjects/[Subject]/anatomy/HIRESSAG.nii'
%% ImageTemplate   = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

OverlayTemplate = '[Exp]/Subjects/[Subject]/anatomy/OVERLAY.nii';

HiResTemplate = '[Exp]/Subjects/[Subject]/anatomy/HIRESSAG.nii';

ImageTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set the file prefix for the file that you want displayed. In most cases this
%% will be 'ra' for file that has gone through realignment.
%%
%% The program will display the first three scans in the .nii file with this
%% file prefix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FilePrefix = 'ra';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path where your logfiles will be stored
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LogTemplate = '[Exp]/CheckReg/Logs';

global mcRoot
%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..','..')
%DEVSTOP

%[DEVmcRootAssign]

addpath(fullfile(mcRoot,'matlabScripts'))
addpath(fullfile(mcRoot,'QualityChecks','CheckReg'))
%addpath(fullfile(mcRoot,'SPM','SPM8','spm8_with_R4667'))
addpath(fullfile(mcRoot,'SPM','SPM12','spm12_with_R6906'));

CheckReg_mc_central
