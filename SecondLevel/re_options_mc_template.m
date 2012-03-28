opt.masking.tm.tm_none = [];
opt.masking.im = 1;
opt.masking.em = '';

opt.globalc.g_omit = [];

opt.globalm.gmsca.gmsca_no = [];
opt.globalm.glonorm = 1;

opt.other.jobfile = 'jobfile.csv';
opt.other.scanfile = 'scanfile.csv';

opt.other.MainDir = '/data/SIM/ANOVA/Flexible';
opt.other.ModelDir = '';
opt.other.ContrastPrefix = 'con';

opt.other.OutputDir = '/data/SIM/ANOVA/Flexible/SecondLevel';

%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..');
%DEVSTOP

%[DEVmcRootAssign]
addpath(fullfile(mcRoot,'matlabScripts'))
addpath(fullfile(mcRoot,'SecondLevel'))
addpath(fullfile(mcRoot,'spm8'))

RandomEffects(opt);