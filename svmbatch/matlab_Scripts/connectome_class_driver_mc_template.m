%% Template part

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GENERAL OPTIONS
%%%	These options are the same between Preprocessing and First level
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The folder that contains your subject folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/net/data4/DEA_Resting/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SVM mode. Can be either paired or unpaired
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

svmtype='paired';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Portion of the matrix to use for features
%%%     'upper'     - upper section (above the diagonal)
%%%     'nodiag'    - both upper and lower section but exclude diagonal
%%%     'full'      - use the full matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
matrixtype = 'nodiag';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pruning Method. For non-paired SVM, how would you like the select the
%%% most discriminant features. Presently supported options are...
%%%     unpaired data
%%%         'ttest'     -   two-sample t-test
%%%         'taub'      -   Kendall's tau-b coefficient of correlation with labels
%%%     paired data
%%%         't-test'    -   paired t-test
%%%         'fractfit'  -   fractional fitness
%%%     Regression SVM
%%%         'PearsonR'  -   Use p-values resulting from Pearson R's between data and labels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pruneMethod = 'ttest';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Path where your images are located
%
%  Variables you can use in your template are:
%       Exp = path to your experiment directory
%       iSubject = index for subject
%       Subject = name of subject from SubjDir (using iSubject as index of row)
%       iRun = index of run (listed in Column 3 of SubjDir)
%       Run = name of run from RunDir (using iRun as index of row)
%        * = wildcard (can only be placed in final part of template)
% Examples:
% ImageTemplate = '[Exp]/Subjects/[Subject]/func/run_0[iRun]/';
% ImageTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ConnTemplate = '[Exp]/FirstLevel/[Subject]/[Run]/Grid/Grid_corr.mat';
% ConnTemplate = '[Exp]/FirstLevel/[Subject]/12mmGrid_19/12mmGrid_19_corr.mat';

ROITemplate = '[Exp]/FirstLevel/[Subject]/[Run]/Grid/Grid_parameters.mat';

% OututTemplate should point to a directory where results will be stored.
% For now these include a SVMResults object which will contain many of the
% intermediates

OutputTemplate = '[Exp]/SVM/Connectome/Test/' ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% How many features of each LOOCV iteration should be retained after
%%% pruning? Set to 0 to disable feature pruning
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nFeatPrune = 50;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Of your consensus number of features, what proportion do you want to be
%%% graphically represented moving forward? If nFeatPlot > nFeatConsensus,
%%% nFeatConsensus will be used instead.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nFeatPlot = 25 ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Would you like the program to also write out node and edge files for
%%% visualization with BrainNet Viewer? If so, set Vizi to 1.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Vizi = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Do you have multiple runs (or something run-like to iterave over?) If
%%%% so, specify it here.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RunDir= {
    'rest_1'
    'rest_2'
    'rest_3'
} ;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% For paired SVM, how would you like to do subtraction and recombine your results?
%%%% Specify a series of "contrast" vectors which will be numerically
%%%% indexed. This only matters for paired SVM approaches. You can also
%%%% supply a list of names to use for these contrasts. These will be used
%%%% to name results files (e.g. the .mat file, .nodes, .edges, etc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ContrastVec= [
     1 0 -1 ; % PBO - High
     1 -1 0 ; % PBO - Low
     0 1 -1 ; % PBO - Mid
     ];

ContrastNames = {
    'PbO vs High'
    'PbO vs Low'
    'Low vs High'
    };
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The list of subjects to process
%%% The format is 'subjectfolder',
%%%
%%% For unpaired SVM, next is an example label, should be +1 or -1
%%%
%%% For paired SVM, next is a mapping of conditions to runs. Include a
%%% 0 if a given condition is not present. E.g. [3 1 0] would indicate that
%%% condition one is present in Run 3, condition two is present in run 1,
%%% and condition three is missing. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjDir = {

'081119mk',[2 1 3];
'090108ad',[1 3 2];
'090113pw',[3 2 0];
'090123eh',[3 2 1];
'090224tn',[1 3 2];
'090602pr',[1 2 3];
'090612sb',[2 3 1];
'090701op',[3 2 1];
'090814ad',[2 1 3];
'090908lm',[0 2 1];
'091109ed',[2 1 3];
'100317bc',[1 2 3];
'100408tg',[2 1 3];
'100414ss',[2 3 1];
'100504kc',[3 1 2];
'100505ma',[3 2 1];
'100506kh',[3 2 1];



 

       };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% If you want to do nuisance correction, set DoNuisanceCorrection to 1
%%%
%%% Provide your info on Nuisance Regressors here. This will be a 3D array.
%%% Rows index examples (subjects), columns index nuisance regressors, and
%%% depth indexes conditions. So if you have 32 subjects, with 3 nuisance
%%% regressors, measured across 4 conditions, you will have a 32 * 3 * 4
%%% array. If a subject is missing a run from a particular condition, leave
%%% the all the values for that subject set to 0; they will not be used
%%% anyway.
%%%
%%% For unpaired data, make sure your rows line up with your SubjDir, but
%%% you should only have one level in the third dimension.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

DoNuisanceCorrection=0;

NuisanceRegressors(:,:,1)=[
    1, 2, 1;
    0, 1, 4;
    ];

NuisanceRegressors(:,:,2)=[
    5, 1, 6;
    2, 6, 2;
    ];

% SVM Library
% 1 - svmlight (Default)
% 2 - LIBSVM (NEW! Supports regression using advancedkernel flags)
svmlib=1;
   


% Enable Advanced Kernel Functions
% NOTE - This will disable visualization
%   0   -   Disable (behavior as usual). Rest of script does not apply.
%   1   -   Enable kernel selection and parameter search.
% NOTES
%   1. This will disable visualization
%   2. Training models will no longer be stored in order to cut down on
%   memory
%   3. You MUST specify a kernel AND either gridstruct or searchgrid
advancedkernel = 0;
   

% Choose your kernel
%   0   -   Linear
%   1   -   Polynomial
%   2   -   Radial Basis Function 
%   3   -   Sigmoid tanh

kernel = 0;

% Do you want to manually specify the searchgrid, or let the script find
% all combinations of your tuning parameters for you?
%   0   -   Manually specify searchgrid
%   1   -   Semi-automatic build of searchgrid
% Define your search area. 
kernelsearchmode = 1;

% If you set kernelsearchmode to 1, define your gridstruct here
% See mc_svm_define_searchgrid help for details. Use this to enable
% regression mode.

gridstruct(1).arg=' -c ';
gridstruct(1).value=logspace(1,10,10);
gridstruct(2).arg=' -r ';
gridstruct(2).value=logspace(1,5,5);

% If you set kernelsearchmode to 0, manually define your searchgrid here.
% See mc_svm_gridsearch help for details

searchgrid =   ...
{   ' -d ', 1, 1, 2, 2;
    ' -r ', 0, 1, 0, 1;};




%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..','..');
%DEVSTOP

%[DEVmcRootAssign]

addpath(genpath(fullfile(mcRoot,'matlabScripts')))
addpath(fullfile(mcRoot,'FirstLevel'))
addpath(fullfile(mcRoot,'spm8'))
addpath(genpath(fullfile(mcRoot,'svmbatch')))

% Run the central script
connectome_class_driver_mc_central ;
