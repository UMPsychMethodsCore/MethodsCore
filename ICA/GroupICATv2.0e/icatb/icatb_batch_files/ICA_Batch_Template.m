%% master directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The folder that contains your subject folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/net/dysthymia/slab/users/guosj/ICA_test';

%% session number
% number of sessions per subject
nSess= 1;


%% session directory
%  if multiple sessions: specify each session directories
%  if single: leave this alone
RunDir = {
    'Tx1';
    'Tx2';
};

%% subject directory
SubjDir = {
    '5001';
    '5002';
    '5003';
    '5004';
    '5005';
    '5010';
    '5011';
    '5012';
    '5013';
    '5014';
    '5015';
    '5016';
    '5017';
    '5018';
    '5019';
    '5020';
    '5021';
    '5023';
    '5024';
    '5025';
    '5026';
    '5028';
    '5029';
    '5031';
    '5032';
    '5034';
    '5035';
    '5036';
    '5037';
    '5038';
    '5039';
    '5040';
    '5041';
    '5042';

};

%% input path pattern
InTemplate = '[Exp]/subject_MAS_resting/[Subj]/Tx1/swrarun*.nii';

%% Out path pattern
OutTemplate = '[Exp]/MSIT_Resting_Results_PBOonly_zscorefixed2';

%% network template
NWTemplate = '[Exp]/rspit_templates.zip_FILES/templates';

%% number of components for PCA data reduction 
% if doEstimation == 1: you don't need to specify numOfPC1 and numOfPC2
% if doEstimation == 0: you need to specify numOfPC1 and numOfPC2 by
% yourself. The default is 30 and 25.
doEstimation = 0;

numOfPC1 = 30;
numOfPC2 = 25;

%% output back projection or not
BackProj = 1;
    
%% template matching algorithm
% 1: use simple component map (intensity) and template map matching algorithm
% 2: use voxel time series and component time series z-score matching algorithm
TempMatchAlg = 2;


%% add path
%DEVSTART
mcRoot = '/net/dysthymia/slab/users/guosj/repos/MethodsCore2/';
%fullfile(fileparts(mfilename('fullpath')),'..','..','..','..');
% DEVSTOP

addpath(genpath(fullfile(mcRoot,'matlabScripts')))
addpath(fullfile(mcRoot,'spm8'))
addpath(genpath(fullfile(mcRoot,'ICA/GroupICATv2.0e/icatb')))


%% run ICA_Batch_Central      
OutPath.Template = OutTemplate;     OutPath.mode = 'makedir';
OutPath = mc_GenPath(OutPath);
cd (OutPath);
save UserSettings;
% ICA_Batch_Central;
icatb_batch_file_run('ICA_Batch_Central.m');