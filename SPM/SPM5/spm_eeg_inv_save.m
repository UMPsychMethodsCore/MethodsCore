function spm_eeg_inv_save(D)
% saves EEG/MEG D.mat data structure in fullfile(D.path,D.fname)
% FORMAT spm_eeg_inv_save(S)
%
% D  - D.mat data structure
%__________________________________________________________________________
%
% Ensures matlab version backwards compatibility
%__________________________________________________________________________
% Copyright (C) 2005 Wellcome Trust Centre for Neuroimaging

% Karl Friston
% $Id: spm_eeg_inv_save.m 1079 2008-01-11 11:05:48Z guillaume $

% save D
%--------------------------------------------------------------------------
if spm_matlab_version_chk('7.1') >= 0
    save(fullfile(D.path, D.fname), '-V6', 'D');
else
    save(fullfile(D.path, D.fname), 'D');
end

