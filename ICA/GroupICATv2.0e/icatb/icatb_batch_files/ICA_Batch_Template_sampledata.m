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
    'sub01_vis';
    'sub02_vis';
    'sub03_vis';

};

%% input path pattern
InTemplate = '[Exp]/datasample_visuomotor/[Subj]/nsrstim*';

%% Out path pattern
OutTemplate = '[Exp]/datasample_visuomotor_results2';

%% network template
NWTemplate = '[Exp]/rspit_templates.zip_FILES/templates';

%% number of components for PCA data reduction 
numOfPC1 = 30;
numOfPC2 = 25;

%% output back projection or not
BackProj = 1;
    

%% add path
%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..','..','..','..');
%DEVSTOP

addpath(genpath(fullfile(mcRoot,'matlabScripts')))
addpath(fullfile(mcRoot,'spm8'))
addpath(genpath(fullfile(mcRoot,'ICA/GroupICATv2.0e/icatb')))


%% run ICA_Batch_Central      
save UserSettings;
icatb_batch_file_run('ICA_Batch_Central_sampledata.m');