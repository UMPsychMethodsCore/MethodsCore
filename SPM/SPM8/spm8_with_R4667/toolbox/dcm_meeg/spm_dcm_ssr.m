function DCM = spm_dcm_ssr(DCM)
% Estimate parameters of a DCM of cross-spectral density
% FORMAT DCM = spm_dcm_ssr(DCM)
%
% DCM
%    name: name string
%       M:  Forward model
%              M.dipfit - lead-field specification
%       xY: data   [1x1 struct]
%       xU: design [1x1 struct]
%
%   Sname: cell of source name strings
%       A: {[nr x nr double]  [nr x nr double]  [nr x nr double]}
%       B: {[nr x nr double], ...}   Connection constraints
%       C: [nr x 1 double]
%
%   options.Nmodes       - number of spatial modes
%   options.Tdcm         - [start end] time window in ms
%   options.Fdcm         - [start end] Frequency window in Hz
%   options.D            - time bin decimation       (usually 1 or 2)
%   options.type         - 'ECD', �LFP� or �IMG�     (see spm_erp_L)
%   options.model        - 'ECD', �SEP�, 'NMM' or �MFM�
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Karl Friston
% $Id: spm_dcm_ssr.m 3497 2009-10-21 21:54:28Z vladimir $


% check options
%==========================================================================
drawnow
clear spm_erp_L
name = sprintf('DCM_%s',date);

% Filename and options
%--------------------------------------------------------------------------
try, DCM.name;                   catch, DCM.name           = name;      end
try, DCM.name;                   catch, DCM.name           = 'DCM_SSR'; end
try, model = DCM.options.model;  catch, model              = 'NMM';     end
try, Nm    = DCM.options.Nmodes; catch, DCM.options.Nmodes = 8; Nm = 8; end

% Spatial model
%==========================================================================
DCM  = spm_dcm_erp_dipfit(DCM, 1);
Ns   = size(DCM.C,1);                                   % number of sources
Nc   = DCM.M.dipfit.Nc;
DCM  = spm_dcm_erp_data(DCM);
DCM.M.dipfit.model = model;


% Neural mass model
%==========================================================================

% prior moments on parameters
%--------------------------------------------------------------------------
[pE,pC]  = spm_dcm_neural_priors(DCM.A,DCM.B,DCM.C,model);

try
    pE   = DCM.M.pE;
    fprintf('Using existing priors\n')
end

% augment with priors on spatial model
%--------------------------------------------------------------------------
[pE,pC]  = spm_L_priors(DCM.M.dipfit,pE,pC);

% augment with priors on endogenous inputs (neuronal) and noise
%--------------------------------------------------------------------------
[pE,pC]  = spm_ssr_priors(pE,pC);

% intial states and equations of motion
%--------------------------------------------------------------------------
[x,f]    = spm_dcm_x_neural(pE,model);

% create DCM
%--------------------------------------------------------------------------
DCM.M.IS = 'spm_lfp_mtf';
DCM.M.FS = 'spm_lfp_sqrt';
DCM.M.g  = 'spm_gx_erp';
DCM.M.f  = f;
DCM.M.x  = x;
DCM.M.n  = length(spm_vec(x));
DCM.M.pE = pE;
DCM.M.pC = pC;
DCM.M.m  = Ns;

%-Feature selection using principal components (U) of lead-field
%==========================================================================

% Spatial modes
%--------------------------------------------------------------------------
if Nc < Nm
    U     = speye(Nc,Nc);
    DCM.M.U = U;
else
    dGdg  = spm_diff('spm_lx_erp',pE,DCM.M,1);
    L     = spm_cat(dGdg);
    U     = spm_svd(L*L',exp(-8));
    try
        U = U(:,1:Nm);
    end
    DCM.M.U = U;
end

% get data-features (in reduced eigen-space)
%--------------------------------------------------------------------------
DCM      = spm_dcm_ssr_data(DCM);


% complete model specification and invert
%==========================================================================
Nm       = size(DCM.M.U,2);               % number of spatial modes
Nt       = size(DCM.xY.y,1);              % number of trials
Nf       = size(DCM.xY.y{1},1);           % number of frequency bins
DCM.M.l  = Nm;
DCM.M.Hz = DCM.xY.Hz;

% precision of noise: AR(1/2)
%--------------------------------------------------------------------------
DCM.xY.Q  = spm_Q(1/2,Nf,1);
DCM.xY.X0 = sparse(Nf,0);

% EM: inversion
%--------------------------------------------------------------------------
[Qp,Cp,Ce,F] = spm_nlsi_GN(DCM.M,DCM.xU,DCM.xY);

% Data ID
%==========================================================================
if isfield(DCM.M,'FS')
    try
        ID  = spm_data_id(feval(DCM.M.FS,DCM.xY.y,DCM.M));
    catch
        ID  = spm_data_id(feval(DCM.M.FS,DCM.xY.y));
    end
else
    ID  = spm_data_id(DCM.xY.y);
end


% Bayesian inference {threshold = prior} NB Prior on A,B  and C = exp(0) = 1
%==========================================================================
warning('off','SPM:negativeVariance');
dp  = spm_vec(Qp) - spm_vec(pE);
Pp  = spm_unvec(1 - spm_Ncdf(0,abs(dp),diag(Cp)),Qp);
warning('on', 'SPM:negativeVariance');


% predictions and error (source space)
%--------------------------------------------------------------------------
Hc  = feval(DCM.M.IS,Qp,DCM.M,DCM.xU);                   % prediction
Ec  = spm_unvec(spm_vec(DCM.xY.y) - spm_vec(Hc),Hc);     % prediction error


% store estimates in DCM
%--------------------------------------------------------------------------
DCM.Ep = Qp;                   % conditional expectation
DCM.Cp = Cp;                   % conditional covariance
DCM.Pp = Pp;                   % conditional probability
DCM.Hc = Hc;                   % conditional responses (y), channel space
DCM.Rc = Ec;                   % conditional residuals (y), channel space
DCM.Ce = Ce;                   % ReML error covariance
DCM.F  = F;                    % Laplace log evidence
DCM.ID = ID;                   % data ID

% and save
%--------------------------------------------------------------------------
DCM.options.Nmodes = Nm;

if spm_matlab_version_chk('7.1') >= 0
    save(DCM.name, '-V6', 'DCM');
else
    save(DCM.name, 'DCM');
end
assignin('base','DCM',DCM)
return
