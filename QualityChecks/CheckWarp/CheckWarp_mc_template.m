%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Experiment Directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Exp = '/net/data4/MAS/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% List the run directories that you want to process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RunDir = { 
  'run_01/';
  'run_02/';
  'run_03/';
  'run_04/';
  'run_05/';
  'run_06/';
         };    
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ImageTemplate: Path where images are located
%%
%%  Variables you can use in your template are:
%%       Exp      = path to your experiment directory
%%       iSubject = index for subject
%%       Subject  = name of subject from SubjDir (using iSubject as index of row)
%%       iRun     = index of run (listed in Column 3 of SubjDir)
%%       Run      = name of run from RunDir (using iRun as index of row)
%%        *       = wildcard (can only be placed in final part of template)
%% Examples:
%% ImageTemplate = '[Exp]/Subjects/[Subject]/func/[Run]/';
%% ImageTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ImageTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/';

WarpTemplate  = '/net/dysthymia/mangstad/spm8//templates/T1.nii';  %%% Use this if images are scalped and you want ADULT canonical

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set the file prefix for the file that you want displayed. In most cases this
%% will be 'swra' for files that have been warped and smoothed.
%%
%% The program will display the first five scans in the .nii file with this
%% file prefix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
FilePrefix = 'swra';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



SubjDir = {
'5024/Tx1',50241,[1 2];
'5025/Tx2',50252,[1 2];
'5026/Tx2',50262,[1 2];
'5028/Tx1',50281,[1 2];
'5029/Tx1',50291,[1 2];
'5031/Tx1',50311,[1 2];
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

%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..','..')
%DEVSTOP

%[DEVmcRootAssign]

addpath(fullfile(mcRoot,'matlabScripts'))
addpath(fullfile(mcRoot,'QualityChecks','CheckReg'))
addpath(fullfile(mcRoot,'QualityChecks','CheckWarp'))
addpath(fullfile(mcRoot,'SPM','SPM8','spm8_with_R4667'))
   
CheckWarp_mc_central
