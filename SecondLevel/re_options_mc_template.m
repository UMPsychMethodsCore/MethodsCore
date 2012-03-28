% opt.masking.tm.tm_none = [];
% opt.masking.im = 1;
% opt.masking.em = '';
% 
% opt.globalc.g_omit = [];
% 
% opt.globalm.gmsca.gmsca_no = [];
% opt.globalm.glonorm = 1;
% 
% opt.other.jobfile = 'jobfile.csv';
% opt.other.scanfile = 'scanfile.csv';
% opt.other.ImColflag = 1; % 1 = images present, 0 = numbers
% 
% opt.other.MainDir = '/data/SIM/ANOVA/Flexible';
% opt.other.ModelDir = '';
% opt.other.ContrastPrefix = 'con';
% 
% opt.other.OutputDir = '/data/SIM/ANOVA/Flexible/SecondLevel';
% 
% %DEVSTART
% mcRoot = fullfile(fileparts(mfilename('fullpath')),'..');
% %DEVSTOP
% 
% %[DEVmcRootAssign]
% addpath(fullfile(mcRoot,'matlabScripts'))
% addpath(fullfile(mcRoot,'SecondLevel'))
% addpath(fullfile(mcRoot,'spm8'))
% 
% RandomEffects(opt);


%%%%%



%%%% addpath /net/dysthymia/spm5_64b
%%%% cd /net/data4/CCMB08/Scripts/SecondLevel/EmoReg
%%%% make the output directory, dude!!!
%%%% jobs = RandomEffects ('EmoReg_options')
%%%% spm_jobman('run',jobs);
%%%% addpath /net/dysthymia/spm8
%%%% addpath /net/dysthymia/matlabScripts

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Defaults %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opt.masking.tm.tm_none = [];
opt.masking.im = 1;
opt.masking.em = {''};
% opt.masking.em = {'/net/data4/OXT/Scripts/SecondLevel/mask.img'};


opt.globalc.g_omit = [];

opt.globalm.gmsca.gmsca_no = [];
opt.globalm.glonorm = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Model = 'Congruency';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%  Specify Models    %%% %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
switch Model 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   case {'Congruency'}     

opt.other.jobfile = '/net/data4/MAS/Scripts/SecondLevel/MSIT/MikeSecondLevel/MSIT_Jobfile_Congruency.csv';
opt.other.scanfile = '/net/data4/MAS/Scripts/SecondLevel/MSIT/MikeSecondLevel/MSIT_Scanfile.csv';
opt.other.ImColflag = 1; % 1 = images present, 0 = numbers

opt.other.MainDir = '/net/data4/MAS/FirstLevel';
opt.other.ModelDir = '';
opt.other.ContrastPrefix = 'con';

opt.other.OutputDir = '/net/data4/MAS/SecondLevel/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   case {'Congruency_X_Run'}     

opt.other.jobfile = '/net/data4/MAS/Scripts/SecondLevel/MSIT/MikeSecondLevel/MSIT_Jobfile_Congruency_X_Run.csv';
opt.other.scanfile = '/net/data4/MAS/Scripts/SecondLevel/MSIT/MikeSecondLevel/MSIT_Scanfile.csv';
opt.other.ImColflag = 1; % 1 = images present, 0 = numbers

opt.other.MainDir = '/net/data4/MAS/FirstLevel';
opt.other.ModelDir = '';
opt.other.ContrastPrefix = 'con';

opt.other.OutputDir = '/net/data4/MAS/SecondLevel/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   case {'Congruency_PairedCov'}     

opt.other.jobfile = '/net/data4/MAS/Scripts/SecondLevel/MSIT/MikeSecondLevel/MSIT_Jobfile_Congruency.csv';
opt.other.scanfile = '/net/data4/MAS/Scripts/SecondLevel/MSIT/MikeSecondLevel/MSIT_Scanfile.csv';
opt.other.ImColflag = 1; % 1 = images present, 0 = numbers

opt.other.MainDir = '/net/data4/MAS/FirstLevel';
opt.other.ModelDir = '';
opt.other.ContrastPrefix = 'don';

opt.other.OutputDir = '/net/data4/MAS/SecondLevel/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

end  %% switch on Model


%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..');
%DEVSTOP

%[DEVmcRootAssign]
addpath(fullfile(mcRoot,'matlabScripts'))
addpath(fullfile(mcRoot,'SecondLevel'))
addpath(fullfile(mcRoot,'spm8'))

RandomEffects(opt);
