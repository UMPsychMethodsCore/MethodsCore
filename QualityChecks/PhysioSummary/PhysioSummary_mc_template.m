

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Experiment Directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Exp = '/net/data4/MAS/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% List all your run directories
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
%% PhysioPathTemplate: full path to physio parameter files
%%
%%  Variables you can use in your template are:
%%       Exp      = path to your experiment directory
%%       iSubject = index for subject
%%       Subject  = name of subject from SubjDir (using iSubject as index of row)
%%       iRun     = index of run (listed in Column 3 of SubjDir)
%%       Run      = name of run from RunDir (using iRun as index of row)
%%        *       = wildcard (can only be placed in final part of template)
%% Examples:
%% PhysioPathTemplate = '[Exp]/Subjects/[Subject]/Physio/run_0[iRun]_physio.mat';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PhysioPathTemplate = '[Exp]/Subjects/[Subject]/Physio/run_0[iRun]_physio.mat';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OuputPathTemplate: file path to output (leave out .csv)
%%
%%  Variables you can use in your template are:
%%       Exp        = path to your experiment directory
%% Examples:
%% PhysioPathTemplate = '[Exp]/Subjects/[Subject]/Physio/run_0[iRun]_physio.mat';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OutputPathTemplate = '[Exp]/Output/Physio/RestingPhysio_bothsessions_test';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The list of subjects 
%%% col 1 = subject id as string, col 2 = subject id as number, col 3 = [runs to include]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjDir = {
'5040/Tx2',50291,[1 2], 0, 0;
'5041/Tx2',50311,[1 2], 0, 0;
'5042/Tx2',50321,[1 3 5], 0, 0; 
};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path where your logfiles will be stored
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Opt.LogTemplate = '[Exp]/PhysioSummary/Logs';

global mcRoot   
%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..')
%DEVSTOP

%[DEVmcRootAssign]

addpath(fullfile(mcRoot,'matlabScripts'))
addpath(fullfile(mcRoot,'PhysioSummary'))
addpath(fullfile(mcRoot,'SPM','SPM8','spm8_with_R6313'))

PhysioSummary_central
