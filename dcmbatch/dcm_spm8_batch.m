% This SPM8 batch script analyses the Attention to Visual Motion fMRI
% dataset available from the SPM site using DCM:
% http://www.fil.ion.ucl.ac.uk/spm/data/attention/
% as described in the SPM manual:
% http://www.fil.ion.ucl.ac.uk/spm/doc/manual.pdf

% Copyright (C) 2010 Wellcome Trust Centre for Neuroimaging

% Guillaume Flandin
% $Id: dcm_spm8_batch.m 21 2010-02-09 15:43:40Z guillaume $


% Directory containing the attention data
%--------------------------------------------------------------------------
% data_path = 'C:\data\path-to-data';
data_path = spm_select(1,'dir','Select the attention data directory');

% Initialise SPM
%--------------------------------------------------------------------------
spm('Defaults','fMRI');
spm_jobman('initcfg');
%spm_get_defaults('cmdline',1);

% CHANGE WORKING DIRECTORY
%--------------------------------------------------------------------------
clear matlabbatch
matlabbatch{1}.cfg_basicio.cfg_cd.dir = cellstr(data_path);
spm_jobman('run',matlabbatch);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GLM SPECIFICATION, ESTIMATION & INFERENCE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
factors = load(fullfile(data_path,'factors.mat'));

% OUTPUT DIRECTORY
%--------------------------------------------------------------------------
clear matlabbatch
matlabbatch{1}.cfg_basicio.cfg_mkdir.parent = cellstr(data_path);
matlabbatch{1}.cfg_basicio.cfg_mkdir.name = 'GLM';
spm_jobman('run',matlabbatch);

% MODEL SPECIFICATION
%--------------------------------------------------------------------------
clear matlabbatch

matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(fullfile(data_path,'GLM'));
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT    = 3.22;
f = spm_select('FPList', fullfile(data_path,'functional'), '^snf.*\.img$');
matlabbatch{1}.spm.stats.fmri_spec.sess.scans            = cellstr(f);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name     = 'Photic';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset    = [factors.att factors.natt factors.stat];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = 10;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name     = 'Motion';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset    = [factors.att factors.natt];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = 10;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).name     = 'Attention';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).onset    = [factors.att];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).duration = 10;

% MODEL ESTIMATION
%--------------------------------------------------------------------------
matlabbatch{2}.spm.stats.fmri_est.spmmat = cellstr(fullfile(data_path,'GLM','SPM.mat'));

% INFERENCE
%--------------------------------------------------------------------------
matlabbatch{3}.spm.stats.con.spmmat = cellstr(fullfile(data_path,'GLM','SPM.mat'));
matlabbatch{3}.spm.stats.con.consess{1}.fcon.name   = 'Effects of interest';
matlabbatch{3}.spm.stats.con.consess{1}.fcon.convec = {eye(3)};
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name   = 'Photic';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = [1 0 0];
matlabbatch{3}.spm.stats.con.consess{3}.tcon.name   = 'Motion';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.convec = [0 1 0];
matlabbatch{3}.spm.stats.con.consess{4}.tcon.name   = 'Attention';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.convec = [0 0 1];

spm_jobman('run',matlabbatch);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VOLUMES OF INTEREST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% EXTRACTING TIME SERIES: V5
%--------------------------------------------------------------------------
clear matlabbatch
matlabbatch{1}.spm.util.voi.spmmat = cellstr(fullfile(data_path,'GLM','SPM.mat'));
matlabbatch{1}.spm.util.voi.adjust = 1;  % "effects of interest" F-contrast
matlabbatch{1}.spm.util.voi.session = 1; % session 1
matlabbatch{1}.spm.util.voi.name = 'V5';
matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {''}; % using SPM.mat above
matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = 3;  % "Motion" T-contrast
matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'FWE';
matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = 0.05;
matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{1}.spm.util.voi.roi{1}.spm.mask.contrast = 4; % "Attention" T-contrast
matlabbatch{1}.spm.util.voi.roi{1}.spm.mask.thresh = 0.05;
matlabbatch{1}.spm.util.voi.roi{1}.spm.mask.mtype = 0; % inclusive
matlabbatch{1}.spm.util.voi.roi{2}.sphere.centre = [0 0 0]; % arbitrary
matlabbatch{1}.spm.util.voi.roi{2}.sphere.radius = 8;
matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.global.spm = 1; % global max
matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.global.mask = ''; % none
matlabbatch{1}.spm.util.voi.expression = 'i1 & i2';
spm_jobman('run',matlabbatch);

% EXTRACTING TIME SERIES: V1
%--------------------------------------------------------------------------
clear matlabbatch
matlabbatch{1}.spm.util.voi.spmmat = cellstr(fullfile(data_path,'GLM','SPM.mat'));
matlabbatch{1}.spm.util.voi.adjust = 1;  % "effects of interest" F-contrast
matlabbatch{1}.spm.util.voi.session = 1; % session 1
matlabbatch{1}.spm.util.voi.name = 'V1';
matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {''}; % using SPM.mat above
matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = 2;  % "Photic" T-contrast
matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'FWE';
matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = 0.05;
matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{1}.spm.util.voi.roi{2}.sphere.centre = [0 0 0]; % arbitrary
matlabbatch{1}.spm.util.voi.roi{2}.sphere.radius = 8;
matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.global.spm = 1; % global max
matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.global.mask = ''; % none
matlabbatch{1}.spm.util.voi.expression = 'i1 & i2'; % intersection
spm_jobman('run',matlabbatch);

% EXTRACTING TIME SERIES: SPC
%--------------------------------------------------------------------------
clear matlabbatch
matlabbatch{1}.spm.util.voi.spmmat = cellstr(fullfile(data_path,'GLM','SPM.mat'));
matlabbatch{1}.spm.util.voi.adjust = 1;  % "effects of interest" F-contrast
matlabbatch{1}.spm.util.voi.session = 1; % session 1
matlabbatch{1}.spm.util.voi.name = 'SPC';
matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {''}; % using SPM.mat above
matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = 4;  % "Attention" T-contrast
matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = 0.001;
matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{1}.spm.util.voi.roi{2}.sphere.centre = [-27 -84 36];
matlabbatch{1}.spm.util.voi.roi{2}.sphere.radius = 8;
matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.local.spm = 1; % nearest local max
matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.local.mask = ''; % none
matlabbatch{1}.spm.util.voi.expression = 'i1 & i2';
spm_jobman('run',matlabbatch);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DYNAMIC CAUSAL MODELLING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear DCM

% SPECIFICATION DCM "attentional modulation of backward connection"
%--------------------------------------------------------------------------
load(fullfile(data_path,'GLM','SPM.mat'));

load(fullfile(data_path,'GLM','VOI_V1_1.mat'),'xY');
DCM.xY(1) = xY;
load(fullfile(data_path,'GLM','VOI_V5_1.mat'),'xY');
DCM.xY(2) = xY;
load(fullfile(data_path,'GLM','VOI_SPC_1.mat'),'xY');
DCM.xY(3) = xY;

DCM.n = length(DCM.xY);      % number of regions
DCM.v = length(DCM.xY(1).u); % number of time points

DCM.Y.dt  = SPM.xY.RT;
DCM.Y.X0  = DCM.xY(1).X0;
for i = 1:DCM.n
    DCM.Y.y(:,i)  = DCM.xY(i).u;
    DCM.Y.name{i} = DCM.xY(i).name;
end

DCM.Y.Q    = spm_Ce(ones(1,DCM.n)*DCM.v);

DCM.U.dt   =  SPM.Sess.U(1).dt;
DCM.U.name = [SPM.Sess.U.name];
DCM.U.u    = [SPM.Sess.U(1).u(33:end,1) ...
              SPM.Sess.U(2).u(33:end,1) ...
              SPM.Sess.U(3).u(33:end,1)];

DCM.delays = repmat(SPM.xY.RT,3,1);
DCM.TE     = 0.04;

DCM.options.nonlinear  = 0;
DCM.options.two_state  = 0;
DCM.options.stochastic = 0;
DCM.options.nograph    = 1;

DCM.a = [1 1 0; 1 1 1; 0 1 1];
DCM.b = zeros(3,3,3);  DCM.b(2,1,2) = 1;  DCM.b(2,3,3) = 1;
DCM.c = [1 0 0; 0 0 0; 0 0 0];
DCM.d = zeros(3,3,0);

save(fullfile(data_path,'GLM','DCM_mod_bwd.mat'),'DCM');

% SPECIFICATION DCM "attentional modulation of forward connection"
%--------------------------------------------------------------------------
DCM.b = zeros(3,3,3);  DCM.b(2,1,2) = 1;  DCM.b(2,1,3) = 1;

save(fullfile(data_path,'GLM','DCM_mod_fwd.mat'),'DCM');

% ESTIMATION
%--------------------------------------------------------------------------
DCM_bwd = spm_dcm_estimate(fullfile(data_path,'GLM','DCM_mod_bwd.mat'));
DCM_fwd = spm_dcm_estimate(fullfile(data_path,'GLM','DCM_mod_fwd.mat'));

% BAYESIAN MODEL COMPARISON
%--------------------------------------------------------------------------
fprintf('Model evidence: %f (bwd) vs %f (fwd)\n',DCM_bwd.F,DCM_fwd.F);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FINISH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
