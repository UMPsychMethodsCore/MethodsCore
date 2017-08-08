%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% If you have any questions read the pdf documentation or contact
%%% MethodsCore at methodscore@umich.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Experiment Directory. This can be used later as a template value.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/net/data4/MAS/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The list of subjects 
%%% col 1 = subject id as string, col 2 = subject id as number, col 3 = run vector
%%%
%%% If using realignment parameters from SPM, the first run listed in the
%%% run vector (column 3 argument) is assumed to be the first run selected
%%% for realignment during preprocessing. This is important for 
%%% calculating between run motion. If the runs do not match, the
%%% motion summary plots for a subject will not make sense.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjDir = {
'5001/Tx1/',[1 2 3];
'5002/Tx1/',[1 2 3];
};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% List all your run directories. Column 3 from the SubjDir variable
%%% uses those numbers for each subject to select runs names from the
%%% RunDir variable. These are then substituted into the [Run] template.
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
%       Subject = name of subject from SubjDir (using iSubject as index of row)
%       Run = name of run from RunDir (using iRun as index of row)
%        * = wildcard (can only be placed in final part of template)
% Examples:
% MotionPathTemplate = '[Exp]/Subjects/[Subject]/func/run_0[iRun]/realign.dat';
% MotionPathTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/rp_arun_*.txt'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MotionPathTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/rp_a_spm8_run_*.txt';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Name and path for the output CSV files (leave off the .csv)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OutputPathTemplate = '[Exp]/MotionSummary/RestingState_c';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Name and path for the output censor vectors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OutputCensorVector = '/oracle7/Researchers/heffjos/tmp/CensorVector_[Subject]';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% OutputPlotPath - Path to save motion plots. Each subject is printed
%%%                    its own motion summary plot.
%%% OutputPlotFile - File name for motion summary plot. The plot will
%%%                    be saved as a pdf. No file extension is needed in the
%%%                    variable value.
%%%
%%% Leave OuptutPlotPath as empty string ('') if no plots are desired.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OutputPlotPath = '[Exp]/Subjects/[Subject]/TASK/func/';
OutputPlotFile = 'MotionSummary';

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
%%% frame that exceeds the FDcriteria. It has units of mm.
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
%%% Path where your logfiles will be stored
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LogTemplate = '[Exp]/Logs';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Other frames to exclude.
%%% FramesBefore is the number of frames before a censored frame to create
%%% sensor vectors as well.  FramesAfter is the number of frames after a
%%% censored frame to create sensor vectors as well.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FramesBefore = 0;
FramesAfter = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% RealignType states what program (FSL or SPM) was used to realign the
%%% functional images. This is important, because SPM and FSL write the
%%% motion parameters in different orders. Also functional images realigned
%%% in SPM require the motion between runs to be recalculated. Typically,
%%% SPM motion parameter files match the regular expression rp_*.txt.
%%% realignfMRI from spm8Batch uses mcflirt from FSL to realign functional
%%% images. They typically match the regular expression mcflirt*.dat.
%%%
%%% 1 = SPM motion parameters
%%% 2 = FSL motion parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RealignType = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PreRealignTemplate is the template to the functional file input into
%%% the realignment step. Typically, realignment occurs after slice time 
%%% correction, so the prefix is most likely the slice-timed corrected 
%%% functional images. This variable is only used if RealignType = 1 for
%%% SPM realigned functional files and OutputPlotPath is not set to the empty
%%% string. These files are need to calculate the motion between runs. 
%%% The associated *.mat files must exist to calculate motion between runs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PreRealignTemplate = '[Exp]/[Subject]/func/TASK/[Run]/a_spm8_run*.nii';

global mcRoot;
%DEVSTART
mcRoot = '/oracle7/Researchers/heffjos/MethodsCore';
%DEVSTOP

%[DEVmcRootAssign]
addpath(fullfile(mcRoot,'matlabScripts'))
addpath(fullfile(mcRoot,'QualityChecks','CheckMotion'))
%addpath(fullfile(mcRoot,'SPM','SPM8','spm8_with_R4667'))
addpath(fullfile(mcRoot,'SPM','SPM12','spm12_with_R6906'));
   
MotionSummary_mc_central
