%% master directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The folder that contains your subject folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/net/data4/MAS_ICA_data';

%% session number
% number of sessions per subject
nSess= 1;


%% session directory
%  if multiple sessions: specify each session directories
%  if single: leave this alone
RunDir = {
    'Tx1';
%     'Tx2';
};

%% subject directory
SubjDir = {
'sub01_vis';
'sub02_vis';
'sub03_vis';

};

%% input path pattern
InTemplate = '[Exp]/datasample_visuomotor/[Subj]/*.nii';

%% Out path pattern
OutTemplate = '[Exp]/Out_TemplateMatchingAlg2_sampledata_randperm2_10comp';

%% network template
NWTemplate = '[Exp]/rspit_templates.zip_FILES/templates';

%% number of components for PCA data reduction 
% if doEstimation == 1: you don't need to specify numOfPC1 and numOfPC2
% if doEstimation == 0: you need to specify numOfPC1 and numOfPC2 by
% yourself. The default is 30 and 25.
doEstimation = 0;

numOfPC1 = 15;
numOfPC2 = 10;

%% output back projection or not
BackProj = 1;
    
%% template matching algorithm
% 1: use simple component map (intensity) and template map matching algorithm
% 2: use voxel time series and component time series z-score matching algorithm
TempMatchAlg = 2;


%% add path
%DEVSTART
mcRoot = '/home/slab/users/guosj/repos/MethodsCore2/';
%fullfile(fileparts(mfilename('fullpath')),'..','..','..','..');
% DEVSTOP

addpath(genpath(fullfile(mcRoot,'matlabScripts')))
addpath(fullfile(mcRoot,'SPM','SPM8'))
addpath(genpath(fullfile(mcRoot,'ICA/GroupICATv2.0e/icatb')))


%% run ICA_Batch_Central      
OutPath.Template = OutTemplate;     OutPath.mode = 'makedir';
OutPath = mc_GenPath(OutPath);
cd (OutPath);
save UserSettings;
% ICA_Batch_Central;
icatb_batch_file_run('ICA_Batch_Central.m');