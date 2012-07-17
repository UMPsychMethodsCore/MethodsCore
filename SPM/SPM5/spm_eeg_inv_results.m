function [D] = spm_eeg_inv_results(D)
% contrast of evoked responses and power for an MEG-EEG model
% FORMAT [D] = spm_eeg_inv_results(D)
% Requires:
%
%     D.inv{i}.contrast.woi   - time (ms) window of interest
%     D.inv{i}.contrast.fboi  - frequency window of interest
%     D.inv{i}.contrast.type  - 'evoked' or 'induced'
%
% this routine will create a contrast for each trial type and will compute
% induced responses in terms of power (over trials) if requested; otherwise
% the power in D.inv{i}.contrast.GW corresponds to the evoked power
%__________________________________________________________________________
% Copyright (C) 2005 Wellcome Trust Centre for Neuroimaging
 
% Karl Friston
% $Id: spm_eeg_inv_results.m 1106 2008-01-17 16:57:56Z guillaume $
 
% SPM data structure
%==========================================================================
try
    model = D.inv{D.val};
catch
    model = D.inv{end};
end
 
% defaults
%--------------------------------------------------------------------------
try, woi  = model.contrast.woi;  catch, woi  = [80 120]; end
try, foi  = model.contrast.fboi; catch, foi  = [];        end
try, type = model.contrast.type; catch, type = 'evoked'; end
 
 
% Check contrast woi is within inversion woi
%--------------------------------------------------------------------------
if woi(1) < D.inv{D.val}.inverse.woi(1) | woi(2) > D.inv{D.val}.inverse.woi(2)
    error(sprintf('Contrast, %s, must be within inversion time-window, %s',mat2str(woi),mat2str(D.inv{D.val}.inverse.woi)))
end
if ~any(foi)
    foi = [];
end
 
fprintf('\ncomputing contrast - please wait\n')
 
% inversion parameters
%--------------------------------------------------------------------------
J    = model.inverse.J;                           % Trial average MAP estimate
T    = model.inverse.T;                           % temporal projector
U    = model.inverse.U;                           % spatial  projector
R    = model.inverse.R;                           % referencing matrix
Is   = model.inverse.Is;                          % Indices of ARD vertices
Ic   = model.inverse.Ic;                          % Indices of channels
It   = model.inverse.It;                          % Indices of time bins
pst  = model.inverse.pst;                         % peristimulus time (ms)
Nd   = model.inverse.Nd;                          % number of mesh dipoles
Nb   = size(T,1);                                 % number of time bins
Nc   = size(U,1);                                 % number of channels
 
try
    scale = model.inverse.scale;                 % Trial average MAP estimate
catch
    scale = 1;
end
 
% time-frequency contrast
%==========================================================================
 
% get [Gaussian] time window
%--------------------------------------------------------------------------
fwhm = max(diff(woi),8);
t    = exp(-4*log(2)*(pst(:) - mean(woi)).^2/(fwhm^2));
t    = t/sum(t);
 
 
% get frequency space and put PST subspace into contrast (W -> T*T'*W)
%--------------------------------------------------------------------------
if length(foi)
    wt = 2*pi*pst(:)/1000;
    W  = [];
    for f = foi(1):foi(end)
        W = [W sin(f*wt) cos(f*wt)];
    end
    W  = diag(t)*W;
    W  = spm_svd(W,1);
else
    W  = t(:);
end
TW     = T'*W;
TTW    = T*TW;
 
% MAP projector and conditional covariance
%==========================================================================
M     = model.inverse.M;
V     = model.inverse.qV;
qC    = model.inverse.qC*trace(TTW'*V*TTW);
qC    = max(qC,0);
MAP   = M*U'*R;
 
 
% cycle over trial types
%==========================================================================
try
    trial = model.inverse.trials;
catch
    trial = D.events.types;
end
for i = 1:length(J)
 
    % induced or evoked
    %----------------------------------------------------------------------
    switch(type)
 
        % energy of conditional mean
        %------------------------------------------------------------------
        case{'evoked'}
 
            JW{i} = J{i}*TW(:,1);
            GW{i} = sum((J{i}*TW).^2,2) + qC;
 
        % mean energy over trials
        %------------------------------------------------------------------
        case{'induced'}
 
            JW{i} = sparse(0);
            JWWJ  = sparse(0);
            if isfield(D.events,'reject')
                c = find(D.events.code == trial(i) & ~D.events.reject);
            else
                c = find(D.events.code == trial(i));
            end
 
            % conditional expectation of contrast (J*W) and its energy
            %------------------------------------------------------------------
            Nt    = length(c);
            for j = 1:Nt
                fprintf('evaluating trial %i, condition %i\n',j,i)
                Y     = D.data(Ic,It,c(j))*scale;
                MYW   = MAP*Y*TTW;
                JW{i} = JW{i} + MYW(:,1);
                JWWJ  = JWWJ  + sum(MYW.^2,2);
            end
 
            % conditional expectation of total energy (source space GW)
            %--------------------------------------------------------------
            JW{i} = JW{i}/Nt;
            GW{i} = JWWJ/Nt + qC;
    end
 
end
 
 
 
% Save results
%==========================================================================
model.contrast.woi  = woi;
model.contrast.fboi = foi;
 
model.contrast.W    = W;
model.contrast.JW   = JW;
model.contrast.GW   = GW;
 
D.inv{D.val}        = model;
 
 
% Display
%==========================================================================
spm_eeg_inv_results_display(D);
