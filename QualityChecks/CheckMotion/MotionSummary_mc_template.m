%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% If you have any questions read the pdf documentation or contact
%%% MethodsCore at methodscore@umich.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Experiment Directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/net/data4/MAS/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The list of subjects 
%%% col 1 = subject id as string, col 2 = subject id as number, col 3 = runs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjDir = {
'5001/Tx1/',1,[1 2 3];
'5002/Tx1/',1,[1 2 3];
};

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
% Path where the motion correction parameter files are located
%
% Variables you can use in your template are:
%       Exp = path to your experiment directory
%       iSubject = index for subject
%       Subject = name of subject from SubjDir (using iSubject as index of row)
%       iRun = index of run (listed in Column 3 of SubjDir)
%       Run = name of run from RunDir (using iRun as index of row)
%        * = wildcard (can only be placed in final part of template)
% Examples:
% MotionPathTemplate = '[Exp]/Subjects/[Subject]/func/run_0[iRun]/realign.dat';
% MotionPathTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/rp_arun_*.txt'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MotionPathTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/rp_arun_*.txt';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Name and path for your output file (leave off the .csv)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OutputPathTemplate = '[Exp]/MotionSummary/RestingState_c';

OutputCensorVector = '[Exp]/MotionSummary/RestingState_c/CensorVector_[Subject]';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Lever arm (typically between 50-100mm)
%%% The lever arm is used to calculate a Eudclidean displacement metric for
%%% both the rotational and translational motion parameters.  It defines
%%% the distance from fulcrum of head to furthest edge.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LeverArm = 50;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FD Lever arm (typically between 50-100mm) for FD calculation
%%% The FD lever arm is used to calculate the framewise displacement
%%% metric.  It is approximately the mean distance from the cerebral cortex
%%% to the center of the head.  See Power et al 2011.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FDLeverArm = 50;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FDcritera is a threshold value.  A censor vector is created for each
%%% frame that exceeds the FDcriteria.  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FDcriteria = 0.2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% How do you want to report the results 
%%% OutputMode
%%%                  1   ----  report results for each run
%%%                  2   ----  report average results over runs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OutputMode = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Other frames to exclude.
%%% FramesBefore is the number of frames before a censored frame to create
%%% sensor vectors as well.  FramesAfter is the number of frames after a
%%% censored frame to create sensor vectors as well.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FramesBefore = 1;
FramesAfter = 2;

global mcRoot;
%DEVSTART
mcRoot = '~/users/yfang/MethodsCore';
%DEVSTOP

%[DEVmcRootAssign]
addpath(fullfile(mcRoot,'matlabScripts'))
addpath(fullfile(mcRoot,'QualityChecks','CheckMotion'))
addpath(fullfile(mcRoot,'SPM','SPM8','spm8_with_R4667'))
   
MotionSummary_mc_central
