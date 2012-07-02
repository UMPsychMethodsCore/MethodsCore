% Basic Options

opt.other.InputImgExt = '.img';
opt.other.jobfile     = 'jobfile.csv';
opt.other.scanfile    = 'scanfile.csv';

opt.other.MainDir        = '/data/SIM/ANOVA/Flexible';
opt.other.ModelDir       = '';
opt.other.ContrastPrefix = 'con';

opt.other.OutputDir = '/data/SIM/ANOVA/Flexible/SecondLevel';

% Advanced Options

opt.other.ImColFlag   = 1;

opt.masking.tm.tm_none = [];
opt.masking.im         = 1;
opt.masking.em         = '';

opt.globalc.g_omit = [];

opt.globalm.gmsca.gmsca_no = [];
opt.globalm.glonorm        = 1;


%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..');
%DEVSTOP

%[DEVmcRootAssign]

addpath(fullfile(mcRoot,'matlabScripts'))
addpath(fullfile(mcRoot,'FirstLevel'))
addpath(fullfile(mcRoot,'spm8'))

jobs = RandomEffects(opt);