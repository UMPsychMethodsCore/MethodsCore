function varargout = icatb_calculate_pca(data, numpc, varargin)
%% Do principal component analysis using eigen decomposition technique.
%
% Inputs:
% 1. data - 2D array (voxels x time)
% 2. numpc - number of principal components
% -- varargin parameters must be passed in pairs
% 1. 'remove_mean' - Removes mean from the data. Options are 1 and 0
% 2. 'whiten' - Whiten data matrix. Options are 1 and 0.
%
% Outputs:
% If no whitening is specified, only eigen vectors and values are returned.
% Otherwise order of outputs is as follows:
% 1. whitesig - Whitened signal
% 2. dewhiteM - Dewhitening matrix
% 3. Lambda - Eigen values as diagonal matrix
% 4. V - Eigen vectors
% 5. whiteM - Whitening matrix

%% Pre-processing options
removeMean = 1;
whitenMatrix = 1;

%% Loop over varargin
for i = 1:2:length(varargin)
    if strcmpi(varargin{i}, 'remove_mean')
        removeMean = varargin{i + 1};
    elseif strcmpi(varargin{i}, 'whiten')
        whitenMatrix = varargin{i + 1};
    end
end
%% End of loop over varargin

if (removeMean)
    data = icatb_remove_mean(data);
end

%% For large matrices, use selective eigen solver. Covariance matrix is computed along the least dimension of the matrix
[rows, cols] = size(data);

df = min([rows, cols]);

if (numpc > df)
    error(['Number of components (', num2str(numpc), ') selected is greater than the least dimension of the data (', num2str(df), ')']);
end

eig_solver = 'all';
if (df >= 500)
    eig_solver = 'selective';
end


if (rows >= cols)
    cov_m = icatb_cov(data, 0);
    [V, Lambda] = icatb_eig_symm(cov_m, size(cov_m, 1), 'num_eigs', numpc, 'verbose', 1, 'eig_solver', eig_solver);
else
    cov_m = (data*data'/(size(data, 1) - 1));
    [V, Lambda] = icatb_eig_symm(cov_m, size(cov_m, 1), 'num_eigs', numpc, 'verbose', 1, 'eig_solver', eig_solver);
    V = (pinv(V)*data)';
    V = V* diag(1./sqrt(sum(V.^2)));
end

clear cov_m;

%% Return eigen vectors and values when no whitening is specified
if (~whitenMatrix)
    varargout{1} = V;
    varargout{2} = Lambda;
    return;
end

%% Whiten matrix
[whitesig, whiteM, dewhiteM] = icatb_v_whiten(data, V, Lambda, 'untranspose');
clear data;
whitesig = whitesig';
varargout{1} = whitesig;
varargout{2} = dewhiteM;
varargout{3} = Lambda;
varargout{4} = V;
varargout{5} = whiteM;
