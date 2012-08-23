%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%~~~~~~~~~~~~~~~~~~~~~~~~~~   Basic   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The folder that contains your subject folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/net/data4/MAS/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path where your logfiles will be stored
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LogTemplate = '[Exp]/Logs';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Analyze data on a local drive on the machine you run the script on
%%% If your data is located on /net/data4 or a similar network drive, using
%%% this option will greatly reduce the required processing time.
%%% IMPORTANT NOTE: Due to the method of sandboxing, using this WILL
%%% OVERWRITE existing results without prompting you, so please be sure
%%% your paths are all correct before running.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
UseSandbox = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Path where your images are located
%%%
%%%  Variables you can use in your template are:
%%%       Exp      = path to your experiment directory
%%%       iSubject = index for subject
%%%       Subject  = name of subject from SubjDir (using iSubject as index of row)
%%%       Run      = name of run from RunDir (using iRun as index of row)
%%%        *       = wildcard (can only be placed in final part of template)
%%% Examples:
%%% ImageTemplate = '[Exp]/Subjects/[Subject]/func/run_0[iRun]/';
%%% ImageTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ImageTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% A list of run folders where the script can find the images to use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RunDir = {
	'run_05/';
	'run_06/';
};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The list of subjects to process
%%% The format is 'subjectfolder',subject number in masterfile,[runs to include]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjDir = {
  '5002/Tx1',50021,[1 2]; %225 240
%  '5028/Tx1',50281,[2];
%  '5029/Tx1',50291,[1 2];
% '5031/Tx1',50311,[1 2];
% '5032/Tx1',50321,[1 2];
% '5034/Tx2',50342,[1 2];
% '5035/Tx2',50352,[1 2];
% '5036/Tx2',50362,[1 2];
% '5037/Tx2',50372,[1 2];
% '5038/Tx2',50382,[1 2];
% '5039/Tx1',50391,[1 2];
% '5040/Tx1',50401,[1 2];
% '5041/Tx2',50412,[1 2];
% '5042/Tx2',50422,[1 2];
};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The  prefix of each functional file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basefile = 'run';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Image Type should be either 'nii' or 'img'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imagetype = 'nii';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Location of master data CSV file
%%%
%%%  Variables you can use in your template are:
%%%       Exp            = path to your experiment directory
%%%       MasterDataName = master data file name
%%%        *             = wildcard (can only be placed in final part of template)
%%% Examples:
%%% MasterTemplate='[Exp]/Scripts/MasterData/[MasterDataName].csv';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MasterTemplate ='[Exp]/Scripts/MasterData/[MasterDataName].csv';
MasterDataName ='MSIT_Master';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Number of rows and columns to skip when reading the MasterData csv file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MasterDataSkipRows = 2;
MasterDataSkipCols = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Column number in the MasterData file where subject numbers are located
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjColumn = [5];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Column number in the MasterData file where run numbers are located
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RunColumn = [1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Column number(s) in the MasterData file where conditions numbers are located
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CondColumn = [60];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Column number in the MasterData file where your Onset times are located
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TimColumn = [58];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Column number in the MasterData file where your Durations are located
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DurColumn = [73];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% User Specified Regressors (affects only regressor CSV file)
%%% 0 = no regressors
%%% 1 = get regressors from file 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RegOp = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Location of the regressor CSV file
%%%  RegFile is created by /Exp/RegLevel1/RegLevel2.csv
%%%
%%%  Variables you can use in your template are:
%%%       Exp         = path to your experiment directory
%%%       RegDataName = regressor CSV file name
%%%        *          = wildcard (can only be placed in final part of template)
%%% Examples:
%%% RegTemplate='[Exp]/MasterData/[RegDataName].csv';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RegTemplate = '[Exp]/MasterData/[RegDataName].csv';
RegDataName = 'MAS_motionregressors';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Number of rows and columns to skip when reading the regressor csv file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RegDataSkipRows = 1;
RegDataSkipCols = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% List of regressor names, and column numbers for values from the regressor file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RegList = { 
    'x',5;
    'y',6;
    'z',7;
    'r',8;
    'p',9;
    'y',10;
};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Column number in the Regressor file where your subject numbers are located
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RegSubjColumn = [2];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Column number in the Regressor file where you run numbers are located
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RegRunColumn = [3];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Location motion regressor files generated during realignment stage in
%%%  preprocessing.  If these regressors are included in the motion
%%%  regressor csv file, leave MotRegTemplate as an empty string.
%%%
%%%  Variables you can use in your template are:
%%%       Exp         = path to your experiment directory
%%%       MotRegName  = motion parameter name
%%%        *          = wildcard (can only be placed in final part of template)
%%% Examples:
%%% RegTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/MotRegName.csv';
%%% RegTemplate = '';  % In this case, one will not be used
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MotRegTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/[MotRegName]';
MotRegTemplate = '';
MotRegName     = 'rp*.txt';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Cell array specifying the motion regressor names and column numbers for
%%% the motion regressor files in MotRegTemplate.  If left empty, the
%%% motion regressor files are assumed to have six motion parameters which
%%% are {'x','y','z','r','p','y'}.
%%%
%%% Example: MotRegList = {
%%%                         'x',1;
%%%                         'r',4;
%%%                       };
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MotRegList = { 
};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Path for output images
%%%
%%%  Variables you can use in your template are:
%%%       Exp        = path to your experiment directory
%%%       Subject    = name of subject from SubjDir (using iSubject as index of row)
%%%       Run        = name of run from RunDir (using iRun as index of row)
%%%        *         = wildcard (can only be placed in final part of template)
%%%       OutputName = output directory
%%% Examples:
%%% OutputTemplate = '[Exp]/Subjects/[Subject]/func/run_0[iRun]/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OutputTemplate = '[Exp]/FirstLevel/[Subject]/[OutputName]/';
OutputName     = 'SandboxTest';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The TR your data was collected at
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TR = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ref point for data out of 16, use same fraction as ref slice for slice timing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fMRI_T0 = 8;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% List of conditions in your model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ConditionName = {
    'Congruent';
    'Incongruent';
    'Error';
    'NonResp';


};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% List of contrasts to add to the estimated model
%%% Format is 'Name of contrast' [Cond1 Param1...N]...[CondN Param1...N] [Reg1...RegN]
%%% You need to properly balance/weight your contrasts below as if it was just one run/session
%%% The script will handle balancing it across runs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ContrastList = {    
%     'C'     [1  0] [0  0] [0 0] [0 0];
%     'CR'    [0  1] [0  0] [0 0] [0 0];
%     'I'     [0  0] [1  0] [0 0] [0 0];
%     'IR'    [0  0] [0  1] [0 0] [0 0];            
%     'C-I'   [1  0] [-1 0] [0 0] [0 0];            
%     'C-I R' [0  1] [0 -1] [0 0] [0 0];     
%     'I-C'   [-1 0] [1 0] [0 0] [0 0];            
%     'I-C R' [0 -1] [0 1] [0 0] [0 0];              
%     'AllTrials' [.5 0] [.5 0] [0 0] [0 0];
%     'AllTrials R' [0 .5] [0 .5] [0 0] [0 0];            
'C'     1    0    0    0 [0 0 0 0 0 0];            
'C'     1    0    0    0 [0 0 0 0 0 0];            
'C'     1    0    0    0 [0 0 0 0 0 0];            
'C'     1    0    0    0 [0 0 0 0 0 0];
'I'     0    1    0    0 [0 0 0 0 0 0];
'I'     0    1    0    0 [0 0 0 0 0 0];
'I'     0    1    0    0 [0 0 0 0 0 0];
% 'I'     0    1    0    0 [0 0 0 0 0 0];
% 'E'     0    0    1    0 [0 0 0 0 0 0];
% 'E'     0    0    1    0 [0 0 0 0 0 0];
% 'E'     0    0    1    0 [0 0 0 0 0 0];
% 'E'     0    0    1    0 [0 0 0 0 0 0];
% 'O'     0    0    0    1 [0 0 0 0 0 0];
% 'O'     0    0    0    1 [0 0 0 0 0 0];
% 'O'     0    0    0    1 [0 0 0 0 0 0];
% 'O'     0    0    0    1 [0 0 0 0 0 0];
% 'C-I'   1   -1    0    0 [0 0 0 0 0 0];
% 'C-I'   1   -1    0    0 [0 0 0 0 0 0];
% 'C-I'   1   -1    0    0 [0 0 0 0 0 0];
% 'C-I'   1   -1    0    0 [0 0 0 0 0 0];
% 'C-E'  1/2  1/2  -1    0 [0 0 0 0 0 0];
% 'C-E'  1/2  1/2  -1    0 [0 0 0 0 0 0];
% 'C-E'  1/2  1/2  -1    0 [0 0 0 0 0 0];
% 'C-E'  1/2  1/2  -1    0 [0 0 0 0 0 0];
% 'O-A' -1/3 -1/3 -1/3   1 [0 0 0 0 0 0];
% 'O-A' -1/3 -1/3 -1/3   1 [0 0 0 0 0 0];
% 'O-A' -1/3 -1/3 -1/3   1 [0 0 0 0 0 0];
% 'O-A' -1/3 -1/3 -1/3   1 [0 0 0 0 0 0];
% 'O-A' -1/3 -1/3 -1/3   1 [0 0 0 0 0 0];
};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CondModifier - Remove the last n conditions from the model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CondModifier = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% If you are including any Parametric regressors in your model
%%% syntax: 'Parameter Name', column for values, condition column with which
%%% it is associated (if the design has more than one condition column)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ParList = { ...
%        'RT',61,1;
};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Number of conditions in each column 
%%% (if you have multiple condition columns, this should also have multiple values)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NumCondPerCondCol = [4];

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~ Advanced ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Run mode
%%% 1 = regular
%%% 2 = Contrast add on
%%% 3 = test without running anything
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Mode = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This sets whether the models are the same for everyone or subject-specific
%%%   0 - each person has different models, grab data from section of MasterData based on subject index
%%%   1 - each person has identical models, grab all from first block of MasterData
%%%   NOTE: Regressors still use subject index so are not identical across subjects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IdenticalModels = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Total number of trials in your experiment for a subject (only used if IdenticalModels = 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TotalTrials = 9;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Number of Functional scans per run
%%% This should be a vector of size 1xNumRun
%%% This value is only used to trim the end of runs when there are
%%% undesired scans there.  If you want to use all the scans in each run
%%% then this should be left blank ([]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NumScan = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Use AR(1) auto-regression correction or not
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
usear1 = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%ScaleOp - 'Scaling' = do proportonal scaling
%%%          'none' = do standard grand mean scaling
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ScaleOp = 'none';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path and name of explicit mask to use at first level.
%%% Leave this blank ('') to turn off explicit masking
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
explicitmask = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Run-specific contrasts (NumContrasts rows each of NumRuns elements)
%%% This allows you to set up a list of weights for each run for each
%%% contrast. This combines with the ContrastList above. Leaving a
%%% particular row empty ([]) is equivalent to setting the contrast weights
%%% as 1 for each run (i.e. no change from the standard contrast method).
%%% Example:
%%% If you have 4 runs and want to compare a condition in run 1 against a
%%% condition in run 4 you would set the contrast weight for that contrast
%%% as [1 0 0 -1].  If you want to only look at the contrast averaged
%%% across runs 1 and 2 you would set the weights as [1 1 0 0]. If you just
%%% want the standard contrast (the average across all runs) you can set it
%%% either to [] or [1 1 1 1].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ContrastRunWeights = {
    [];
    [1 0];
    [0 1];
    [1 -1];
    
    [1 1];
    [1 0];
    [0 1];
    [1 -1];
    
    [1 1];
    [1 0];
    [0 1];
    [1 -1];
    
    [1 1];
    [1 0];
    [0 1];
    [1 -1];
    
    [1 1];
    [1 0];
    [0 1];
    [1 -1];
    
    [1 1];
    [1 0];
    [0 1];
    [1 -1];
    
    [1 1];
    [1 0];
    [0 1];
    [1 -1];
    };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Set the contrast start point
%%% 1 = Overwrite Previous Contrasts
%%% 2 = Append new contrasts to previous ones 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
StartOp=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CondThreshold
%%% 0 = only remove empty conditions
%%% 1 = remove singleton conditions (useful b/c SPM won't estimate a beta for
%%% parameters that modulate a singleton condition)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CondThreshold = 0;

global mcRoot;
%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..');
%DEVSTOP

%[DEVmcRootAssign]

addpath(fullfile(mcRoot,'matlabScripts'))
addpath(fullfile(mcRoot,'FirstLevel'))
addpath(fullfile(mcRoot,'SPM','SPM8','spm8Legacy'))

FirstLevel_mc_central
