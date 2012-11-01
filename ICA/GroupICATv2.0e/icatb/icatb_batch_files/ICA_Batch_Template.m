%% master directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The folder that contains your subject folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/net/data4/MAS_ICA_data';

%% session number
% number of sessions per subject
nSess= 2;


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
%     '5003';
%     '5004';
%     '5005';
%     '5010';
% %     '5011';
%     '5012';
% %     '5013';
%     '5014';
%     '5015';
%     '5016';
%     '5017';
%     '5018';
%     '5019';
%     '5020';
%     '5021';
%     '5023';
%     '5024';
%     '5025';
%     '5026';
%     '5028';
%     '5029';
%     '5031';
%     '5032';
%     '5034';
%     '5035';
%     '5036';
%     '5037';
%     '5038';
%     '5039';
%     '5040';
%     '5041';
%     '5042';

};

%% input path pattern
InTemplate = '[Exp]/subject_MAS_resting/[Subj]/[Run]/swrarestrun*.nii';

%% network template
NWTemplate = '[Exp]/rspit_templates.zip_FILES/templates';

%% Out path pattern
OutTemplate = '[Exp]/Out_TemplateMatchingAlg3_1sess';

%% Enter Name (Prefix) Of Output Files
prefix = 'driving';

%% number of components for PCA data reduction 
% if doEstimation == 1: you don't need to specify numOfPC1 and numOfPC2
% if doEstimation == 0: you need to specify numOfPC1 and numOfPC2 by
% yourself. The default is 30 and 25.
doEstimation = 1;

numOfPC1 = 15;
numOfPC2 = 10;

%% 'Which ICA Algorithm Do You Want To Use';
% see icatb_icaAlgorithm for details or type icatb_icaAlgorithm at the
% command prompt.
% Note: Use only one subject and one session for Semi-blind ICA. Also specify atmost two reference function names

% 1 means infomax, 2 means fastICA, etc.
algoType = 1;

%% Do ICASSO?
% Options are 1 and 2.
% 1 - don't do ICASSO
% 2 - do ICASSO
% if doICASSO is choosed, fill in numofICASSO; otherwise leave if with any
% number
%   -if using Infomax, numofICASSO recommended to be 20
%   -if fastICA, numofICASSO recommended to be 100
doICASSO = 2;
numofICASSO = 20;


%% output back projection or not
BackProj = 1;
    
%% whether do template matching
% if do template matching, set to 1;
% otherwise, set to 0
doTemplateMatching = 1;

%% template matching algorithm
% 1: use simple component map (intensity) and template map matching algorithm
% 2: use voxel time series and component time series z-score matching algorithm
% 3: template matching by GIFT(spatial/temperal sorting)
TempMatchAlg = 3;

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
icatb_batch_file_run('ICA_Batch_Central.m');