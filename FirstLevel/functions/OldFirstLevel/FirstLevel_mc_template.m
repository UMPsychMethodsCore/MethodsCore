%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%~~~~~~~~~~~~~~~~~~~~~~~~~~   Basic   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
clear;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The folder that contains your subject folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/net/data4/MAS/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path where your logfiles will be stored
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LogTemplate = '[Exp]/Logs';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Image and subject information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
%%% The  prefix of each functional file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basefile = 'swra_MSITrun';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Image Type should be either 'nii' or 'img'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imagetype = 'nii';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The TR your data was collected at
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TR = 2;

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
      '5001/Tx1',50011,[1 2];
      '5028/Tx1',50281,[2];
      '5029/Tx1',50291,[1 2];
};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% MasterData File and Condition information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Location of masterdata CSV file
%%%
%%%  Variables you can use in your template are:
%%%       Exp            = path to your experiment directory
%%%       MasterDataName = master data file name
%%%        *             = wildcard (can only be placed in final part of template)
%%% Examples:
%%% MasterTemplate='[Exp]/Scripts/MasterData/[MasterDataName].csv';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MasterTemplate ='[Exp]/Scripts/MasterData/[MasterDataName].csv';
MasterDataName ='MSIT_Master_methodscore';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Number of rows and columns to skip when reading the MasterData csv file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MasterDataSkipRows = 2;
MasterDataSkipCols = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Column number in the MasterData file where subject numbers are located
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjColumn = [1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Column number in the MasterData file where run numbers are located
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RunColumn = [2];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Column number(s) in the MasterData file where conditions numbers are located
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CondColumn = [5];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Column number in the MasterData file where your Onset times are located
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TimColumn = [4];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Column number in the MasterData file where your Durations are located
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DurColumn = [6];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% List of conditions in your model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ConditionName = {
    'Congruent';
    'Incongruent';
};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% If you are including any Parametric regressors in your model
%%% syntax: 'Parameter Name', column number in MasterData file that contains
%%% the parameter value. If using multiple condition columns above, you must
%%% provide a third entry that indicates with which condition column the 
%%% parametric regressor is associated.
%%% NOTE: If you want to include parametric regressors for a condition, the 
%%% values of your regressor MUST change over trials.  SPM can not include
%%% a constant parametric regressor and it will cause problems with contrasts.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ParList = { ...
};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% User specified regressor information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% User Specified Regressors 
%%% The value in the first column controls the master file method (see
%%% advanced section).
%%% The value in the second column controls the subject-specific regressor 
%%% file method (see RegFileTemplates below).
%%% 0 = don't use method
%%% 1 = use method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RegOp = [0 1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Location of user specified regressor files. To use these make sure 
%%%  column 2 of RegOp is set to 1 above.
%%%
%%%  Variables you can use in your template are:
%%%       Exp         = path to your experiment directory
%%%       Subject     = folder name of current subject
%%%       Run         = folder name of current run
%%%        *          = wildcard (can only be placed in final part of template)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RegFileTemplates = {
    '[Exp]/Subjects/[Subject]/func/[Run]/mcflirt*.dat',Inf;
    '[Exp]/Subjects/[Subject]/func/[Run]/fdOutliers.csv',Inf;
    '[Exp]/Subjects/[Subject]/func/[Run]/frameOutliers.csv',Inf;
};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Indices from RegFileTemplates for which regressor files should have
%%% automatic first derivatives calculated and also included
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RegDerivatives = [1];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Contrast information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% List of contrasts to add to the estimated model
%%% Format is 'Name of contrast' [Cond1 Param1...N]...[CondN Param1...N] [Reg1...RegN]
%%% You need to properly balance/weight your contrasts below as if it was just one run/session
%%% The script will handle balancing it across runs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ContrastList = {    
    'C'            1  0   [0 0 0 0 0 0];
    'I'            0  1   [0 0 0 0 0 0];         
    'C-I'          1 -1   [0 0 0 0 0 0];             
    'I-C'         -1  1   [0 0 0 0 0 0];                   
    'AllTrials'   .5 .5   [0 0 0 0 0 0];

};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Output path information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
OutputName     = 'MSITtest1';








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
%%% Analyze data on a local drive on the machine you run the script on
%%% If your data is located on /net/data4 or a similar network drive, using
%%% this option will greatly reduce the required processing time.
%%% IMPORTANT NOTE: Due to the method of sandboxing, using this WILL
%%% OVERWRITE existing results without prompting you, so please be sure
%%% your paths are all correct before running.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
UseSandbox = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ref point for data out of 16, use same fraction as ref slice for slice timing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fMRI_T0 = 8;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CondModifier - Remove the last n conditions from the model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CondModifier = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CondThreshold
%%% 0 = only remove empty conditions
%%% 1 = remove singleton conditions (useful b/c SPM won't estimate a beta for
%%% parameters that modulate a singleton condition)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CondThreshold = 0;

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
%%% Set the contrast start point
%%% 1 = Overwrite Previous Contrasts
%%% 2 = Append new contrasts to previous ones 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
StartOp=1;

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
    };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Location of the regressor CSV file for Masterfile method of regressor
%%%  loading
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
%%%Column number in the Regressor file where your subject numbers are located
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RegSubjColumn = [2];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Column number in the Regressor file where you run numbers are located
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RegRunColumn = [3];

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
%%% SPM Default Values for First Level analysis
%%% this is set up as a cell array where each row corresponds to a default
%%% value in SPM.  The first element is a string with the name of the
%%% default field (without defaults. at the beginning).  You can view
%%% spm_defaults.m for a list of possible fields to set.  The second
%%% element is the value you want to set for that default.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The main default that impacts first level analysis is the implicit 
%%% masking threshold. The default is 0.8 which means that voxels that have
%%% a value of less than 80% of the grand mean will be masked out of the
%%% analysis.  This default value can be problematic in some susceptibility
%%% prone areas like OFC.  A more liberal value like 0.5 can help to keep
%%% these regions in the analysis.  If you set this value very low, you'll
%%% want to use an explicit mask to exclude non-brain regions from
%%% analysis.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spmdefaults = {
    'mask.thresh'   0.8;
};


global mcRoot;
%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..');
%DEVSTOP

%[DEVmcRootAssign]

addpath(fullfile(mcRoot,'matlabScripts'))
addpath(fullfile(mcRoot,'FirstLevel/functions/OldFirstLevel'))
addpath(fullfile(mcRoot,'SPM','SPM8','spm8_with_R6313'))

OldFirstLevel_mc_central
