function DCM = spm_dcm_csd(DCM)
% Estimate parameters of a DCM of (complex) cross-spectral density
% FORMAT DCM = spm_dcm_csd(DCM)
%
% DCM
%    name: name string
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
%   options.spatial      - 'ECD', 'LFP' or 'IMG'     (see spm_erp_L)
%   options.model        - 'ERP', 'SEP', 'CMC', 'LFP', 'NMM' or 'MFM'
%
% Esimates:
%--------------------------------------------------------------------------
% DCM.dtf                   - directed transfer functions (source space)
% DCM.ccf                   - cross covariance functions (source space)
% DCM.coh                   - cross coherence functions (source space)
% DCM.fsd                   - specific delay functions (source space)
% DCM.pst                   - peristimulus time
% DCM.Hz                    - frequency
%
% DCM.Ep                    - conditional expectation
% DCM.Cp                    - conditional covariance
% DCM.Pp                    - conditional probability
% DCM.Hc                    - conditional responses (y), channel space
% DCM.Rc                    - conditional residuals (y), channel space
% DCM.Hs                    - conditional responses (y), source space
% DCM.Ce                    - eML error covariance
% DCM.F                     - Laplace log evidence
% DCM.ID                    -  data ID
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging
 
% Karl Friston
% $Id: spm_dcm_csd.m 6481 2015-06-16 17:01:47Z karl $
 
 
% check options
%==========================================================================
drawnow
clear spm_erp_L
name = sprintf('DCM_%s',date);
DCM.options.analysis  = 'CSD';
 
% Filename and options
%--------------------------------------------------------------------------
try, DCM.name;                      catch, DCM.name = name;      end
try, model   = DCM.options.model;   catch, model    = 'NMM';     end
try, spatial = DCM.options.spatial; catch, spatial  = 'LFP';     end
try, Nm      = DCM.options.Nmodes;  catch, Nm       = 8;         end
try, DATA    = DCM.options.DATA;    catch, DATA     = 1;         end
 
% Spatial model
%==========================================================================
DCM.options.Nmodes = Nm;
DCM.M.dipfit.model = model;
DCM.M.dipfit.type  = spatial;

if DATA
    DCM  = spm_dcm_erp_data(DCM);                   % data
    DCM  = spm_dcm_erp_dipfit(DCM, 1);              % spatial model
end
Ns   = length(DCM.A{1});                            % number of sources


% Design model and exogenous inputs
%==========================================================================
if ~isfield(DCM,'xU'),   DCM.xU.X = sparse(1 ,0); end
if ~isfield(DCM.xU,'X'), DCM.xU.X = sparse(1 ,0); end
if ~isfield(DCM,'C'),    DCM.C    = sparse(Ns,0); end
if isempty(DCM.xU.X),    DCM.xU.X = sparse(1 ,0); end
if isempty(DCM.xU.X),    DCM.C    = sparse(Ns,0); end

% Neural mass model
%==========================================================================
 
% prior moments on parameters
%--------------------------------------------------------------------------
[pE,pC]  = spm_dcm_neural_priors(DCM.A,DCM.B,DCM.C,model);
  
% check to see if neuronal priors have already been specified
%--------------------------------------------------------------------------
try
    if spm_length(DCM.M.pE) == spm_length(pE);
        pE = DCM.M.pE;
        pC = DCM.M.pC;
        fprintf('Using existing priors\n')
    end
end
 
% augment with priors on spatial model
%--------------------------------------------------------------------------
[pE,pC]  = spm_L_priors(DCM.M.dipfit,pE,pC);
 
% augment with priors on endogenous inputs (neuronal) and noise
%--------------------------------------------------------------------------
[pE,pC]  = spm_ssr_priors(pE,pC);

try
    if spm_length(DCM.M.pE) == spm_length(pE);
        pE = DCM.M.pE;
        pC = DCM.M.pC;
        fprintf('Using existing priors\n')
    end
end
 
% initial states and equations of motion
%--------------------------------------------------------------------------
[x,f]    = spm_dcm_x_neural(pE,model);
 
% create DCM
%--------------------------------------------------------------------------
DCM.M.IS = 'spm_csd_mtf';
DCM.M.FS = 'spm_fs_csd';
DCM.M.g  = 'spm_gx_erp';
DCM.M.f  = f;
DCM.M.x  = x;
DCM.M.n  = length(spm_vec(x));
DCM.M.pE = pE;
DCM.M.pC = pC;
DCM.M.hE = 6;
DCM.M.hC = 1/64;
DCM.M.m  = Ns;

% specify M.u - endogenous input (fluctuations) and intial states
%--------------------------------------------------------------------------
DCM.M.u  = sparse(Ns,1);

%-Feature selection using principal components (U) of lead-field
%==========================================================================
 
% Spatial modes
%--------------------------------------------------------------------------
try
    DCM.M.U  = spm_dcm_eeg_channelmodes(DCM.M.dipfit,Nm);
end
 
% get data-features (in reduced eigenspace)
%==========================================================================
if DATA
    DCM  = spm_dcm_csd_data(DCM);
end
 
% scale data features (to a variance of about 8)
%--------------------------------------------------------------------------
ccf      = spm_csd2ccf(DCM.xY.y,DCM.xY.Hz);
scale    = max(spm_vec(ccf));
DCM.xY.y = spm_unvec(8*spm_vec(DCM.xY.y)/scale,DCM.xY.y);


% complete model specification and invert
%==========================================================================
Nm       = size(DCM.M.U,2);                    % number of spatial modes
DCM.M.l  = Nm;
DCM.M.Hz = DCM.xY.Hz;
DCM.M.dt = DCM.xY.dt;
 
% precision of noise: AR(1/2)
%--------------------------------------------------------------------------
y     = spm_fs_csd(DCM.xY.y,DCM.M);
for i = 1:length(y)
    n      = size(y{i},1);
    m      = size(y{i},2)*size(y{i},3);
    q      = spm_Q(1/2,n,1);
    Q{i,i} = kron(speye(m,m),q);
end
DCM.xY.Q  = spm_cat(Q);
DCM.xY.X0 = sparse(size(Q,1),0);


% Variational Laplace: model inversion
%==========================================================================
[Qp,Cp,Eh,F] = spm_nlsi_GN(DCM.M,DCM.xU,DCM.xY);


% Data ID
%--------------------------------------------------------------------------
try
    try
        ID = spm_data_id(feval(DCM.M.FS,DCM.xY.y,DCM.M));
    catch
        ID = spm_data_id(feval(DCM.M.FS,DCM.xY.y));
    end
catch
    ID = spm_data_id(DCM.xY.y);
end
 
 
% Bayesian inference {threshold = prior} NB Prior on A,B and C = exp(0) = 1
%==========================================================================
warning('off','SPM:negativeVariance');
dp  = spm_vec(Qp) - spm_vec(pE);
Pp  = spm_unvec(1 - spm_Ncdf(0,abs(dp),diag(Cp)),Qp);
warning('on', 'SPM:negativeVariance');
 
 
% predictions (csd) and error (sensor space)
%--------------------------------------------------------------------------
Hc  = spm_csd_mtf(Qp,DCM.M,DCM.xU);                      % prediction
Ec  = spm_unvec(spm_vec(DCM.xY.y) - spm_vec(Hc),Hc);     % prediction error
 
 
% predictions (source space - cf, a LFP from virtual electrode)
%--------------------------------------------------------------------------
M             = rmfield(DCM.M,'U'); 
M.dipfit.type = 'LFP';

M.U         = 1; 
M.l         = Ns;
qp          = Qp;
qp.L        = ones(1,Ns);             % set virtual electrode gain to unity
qp.b        = qp.b - 32;              % and suppress non-specific and
qp.c        = qp.c - 32;              % specific channel noise

[Hs Hz dtf] = spm_csd_mtf(qp,M,DCM.xU);
[ccf pst]   = spm_csd2ccf(Hs,DCM.M.Hz);
[coh fsd]   = spm_csd2coh(Hs,DCM.M.Hz);
DCM.dtf     = dtf;
DCM.ccf     = ccf;
DCM.coh     = coh;
DCM.fsd     = fsd;
DCM.pst     = pst;
DCM.Hz      = Hz;

 
% store estimates in DCM
%--------------------------------------------------------------------------
DCM.Ep = Qp;                   % conditional expectation
DCM.Cp = Cp;                   % conditional covariance
DCM.Pp = Pp;                   % conditional probability
DCM.Hc = Hc;                   % conditional responses (y), channel space
DCM.Rc = Ec;                   % conditional residuals (y), channel space
DCM.Hs = Hs;                   % conditional responses (y), source space
DCM.Ce = exp(-Eh);             % ReML error covariance
DCM.F  = F;                    % Laplace log evidence
DCM.ID = ID;                   % data ID
 
% and save
%--------------------------------------------------------------------------
DCM.options.Nmodes = Nm;
 
save(DCM.name, 'DCM', spm_get_defaults('mat.format'));
