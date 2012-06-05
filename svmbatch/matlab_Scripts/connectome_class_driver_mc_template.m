%% Template part

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GENERAL OPTIONS
%%%	These options are the same between Preprocessing and First level
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The folder that contains your subject folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/net/dysthymia/slab/users/guosj/repos/MethodsCore/svmbatch/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SVM mode. Can be either paired or unpaired
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

svmtype='paired';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pruning Method. For non-paired SVM, how would you like the select the
%%% most discriminant features. Presently supported options are...
%%%     'ttest'     -   two-sample t-test
%%%     'taub'      -   Kendall's tau-b coefficient of correlation with labels
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

ConnTemplate = '[Exp]/FirstLevel/[Subject]/[Run]/MSIT/HRF/FixDur/TBTGrid/TBTGrid_corr.mat';
% ConnTemplate = '[Exp]/FirstLevel/[Subject]/12mmGrid_19/12mmGrid_19_corr.mat';

ROITemplate = '[Exp]/FirstLevel/[Subject]/[Run]/MSIT/HRF/FixDur/TBTGrid/TBTGrid_parameters.mat';


% OututTemplate should point to a directory where results will be stored.
% For now these include a SVMResults object which will contain many of the
% intermediates

OutputTemplate = '[Exp]/SVM/Connectome/StudyName/' ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% How many features of each LOOCV iteration should be retained after
%%% pruning?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nFeatPrune = 100;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Of your consensus number of features, what proportion do you want to be
%%% graphically represented moving forward? If nFeatPlot > nFeatConsensus,
%%% nFeatConsensus will be used instead.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nFeatPlot = 30 ;

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
    'Tx1'
    'Tx2'
} ;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% For paired SVM, how would you like to do subtraction and recombine your results?
%%%% Specify a series of "contrast" vectors which will be numerically
%%%% indexed. This only matters for paired SVM approaches
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ContrastVec= [
%      .5 .5;
%      .2 .8;
     1 -1;
     ];

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

'5001',[1 2];

'5002',[1 2];

% '5003',[1 2];
% 
% '5004',[1 2];
% 
% '5005',[1 2];
% 
% '5010',[1 2];
% 
% '5012',[1 2];
% 
% '5014',[1 2];
% 
% '5015',[1 2];
% 
% '5016',[1 2];
% 
% '5017',[1 2];
% 
% '5018',[1 2];
% 
% '5019',[1 2];
% 
% '5020',[1 2];
% 
% '5021',[1 2];
% 
% '5023',[1 2];
% 
% '5024',[1 2];
% 
% '5025',[1 2];
% 
% '5026',[1 2];
% 
% '5028',[1 2];
% 
% '5029',[1 2];
% 
% '5031',[1 2];
% 
% '5032',[1 2];
% 
% '5034',[1 2];
% 
% '5035',[1 2];
% 
% '5036',[1 2];
% 
% '5037',[1 2];
% 
% '5038',[1 2];
% 
% '5039',[1 2];
% 
% '5040',[1 2];
% 
% '5041',[1 2];
% 
% '5042',[1 2];



 

       };

%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..','..');
%DEVSTOP

%[DEVmcRootAssign]

addpath(fullfile(mcRoot,'matlabScripts'))
addpath(fullfile(mcRoot,'FirstLevel'))
addpath(fullfile(mcRoot,'spm8'))
addpath(genpath(fullfile(mcRoot,'svmbatch')))

% Run the central script
connectome_class_driver_mc_central ;
