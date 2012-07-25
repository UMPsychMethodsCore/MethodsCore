function [whitesig, dewhiteM, Lambda, V, whiteM] = icatb_calculate_pca(data, numpc, varargin)
%% Calculates principal components
%
% Inputs:
% 1. data - 2D array
% 2. numpc - number of principal components
%
% Outputs:
% 1. whitesig - Whitened signal
% 2. numpc - Number of principal components
%

%% Pre-processing options
removeMean = 1;

%% Loop over varargin
for i = 1:2:length(varargin)
    if strcmpi(varargin{i}, 'remove_mean')
        removeMean = varargin{i + 1};
    end
end
%% End of loop over varargin

if (removeMean == 1)
    data = icatb_remove_mean(data);
end

saveEig = 0;

% compute covariance matrix and the eigen values
[V, Lambda] = icatb_v_pca(data, 1, numpc, saveEig, 'untranspose', 'no');

% whiten matrix
[whitesig, whiteM, dewhiteM] = icatb_v_whiten(data, V, Lambda, 'untranspose');

clear data;

whitesig = whitesig';

