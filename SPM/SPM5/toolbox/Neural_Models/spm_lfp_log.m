function [y] = spm_lfp_log(y,M)
% Feature selection for lfp and mtf (spectral) neural mass models
% FORMAT [y] = spm_lfp_log(y,M)
% 
% Y -> log(y) (including cells)
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging
 
% Karl Friston
% $Id: spm_lfp_log.m 1070 2008-01-07 19:03:15Z guillaume $

% log transform
%--------------------------------------------------------------------------
y = spm_unvec(log(spm_vec(y)),y);