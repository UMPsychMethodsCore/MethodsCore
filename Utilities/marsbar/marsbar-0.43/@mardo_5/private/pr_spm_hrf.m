function [hrf,p] = pr_spm_hrf(RT,P);
% returns a hemodynamic response function
% FORMAT [hrf,p] = pr_spm_hrf(RT,[p]);
% RT   - scan repeat time
% p    - parameters of the response function (two gamma functions)
%
%							defaults
%							(seconds)
%	p(1) - delay of response (relative to onset)	   6
%	p(2) - delay of undershoot (relative to onset)    16
%	p(3) - dispersion of response			   1
%	p(4) - dispersion of undershoot			   1
%	p(5) - ratio of response to undershoot		   6
%	p(6) - onset (seconds)				   0
%	p(7) - length of kernel (seconds)		  32
%
% hrf  - hemodynamic response function
% p    - parameters of the response function
%_______________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Karl Friston
% $Id: spm_hrf.m 387 2005-12-17 18:31:23Z klaas $


% global parameter
%-----------------------------------------------------------------------
global defaults
try
	fMRI_T = defaults.stats.fmri.t;
catch
	fMRI_T = 16;
end;

% default parameters
%-----------------------------------------------------------------------
p     = [6 16 1 1 6 0 32];
if nargin > 1
      p(1:length(P)) = P;
end

% modelled hemodynamic response function - {mixture of Gammas}
%-----------------------------------------------------------------------
dt    = RT/fMRI_T;
u     = [0:(p(7)/dt)] - p(6)/dt;
hrf   = pr_spm_gpdf(u,p(1)/p(3),dt/p(3)) - pr_spm_gpdf(u,p(2)/p(4),dt/p(4))/p(5);
hrf   = hrf([0:(p(7)/RT)]*fMRI_T + 1);
hrf   = hrf'/sum(hrf);
