%% Template part

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GENERAL OPTIONS
%%%	These options are the same between Preprocessing and First level
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The folder that contains your subject folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/net/data4/DEA_Resting/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Paired mode. Set this to 1 if your data is organized in sequential
%%% pairs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pairedSVM=1;

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

ConnTemplate = '[Exp]/FirstLevel/[Subject]/[Run]/Grid/Grid_corr.mat';
% ConnTemplate = '[Exp]/FirstLevel/[Subject]/12mmGrid_19/12mmGrid_19_corr.mat';

ROITemplate = '[Exp]/FirstLevel/[Subject]/[Run]/Grid/Grid_parameters.mat';


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
%%%% How would you like to do subtraction and recombine your results?
%%%% Specify a series of "contrast" vectors which will be numerically
%%%% indexed. This only matters for paired SVM approaches
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ContrastVec= [
     1 0 -1 ; 
     1 -1 0 ;
     1 -.5 -.5 ;
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

%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..','..');
%DEVSTOP

%[DEVmcRootAssign]

addpath(fullfile(mcRoot,'matlabScripts'))
addpath(fullfile(mcRoot,'FirstLevel'))
addpath(fullfile(mcRoot,'spm8'))
addpath(genpath(fullfile(mcRoot,'svmbatch')))

% Run the central script
% connectome_class_driver_mc_central ;
