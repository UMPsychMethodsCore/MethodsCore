function [jica] = jICA_mc_central(jica)
% This function will perform joint independent component analysis, including

% 1. Data cleaning via regression
% 2. Data reduction via PCA
% 3. ICA
% 4. Identification of phenotypically relevant components
% 5. Split results according to modalities

% Everything is acomplished via the struct jica. Here is the full form once completed

% n: number of subjects/observations
% r: number of "reduced subjects" after data reduction (model order specified in jICA.pca.dim)
% p: number of features/variables
% b: number of predictors
% o: number of components
% - jICA
%   - orig: n * p concatenated feature matrix
%   - clean
%     - data: n * p data matrix cleansed of nuisance covariates
%     - x: n * b design matrix for cleansing
%     - CovInt: vector of covariates of interest (add back in, intercept always included)
%   - pca
%     - dim: target dimensionality of data
%     - red: reduced data (r * p)
%     - white: whitening matrix (n * r)
%     - dewhite: dewhitening matrix (r * n)
%   - ica
%     - S: source maps 
%     - rawmix: raw mixing matrix (generally in reduced space)
%     - mix:  mixing matrix (unreduced if necessary)
%   - flip
%     - 0 for off,
%     - int:  index into clean.X for covariate of interest to flip components to fit (after intercept)
%     - after initial fit, multiply mixing matrix and S both by -1 for cases where beta is negative
%     - refit models, so that all betas will be positive, and source map is easier to interpret
%   - stat 
%     - fdr
%     - q
%     - h
%     - (other standard stat fields)
%       - p
%       - b
%       - x
%   - split
%     - splitpts: vector of start values for each modality (1 if only 1 modality)
%     - maps: struct array of size 1 * modality (from length of splitpts)
%       - raw: r * p  matrix of raw source maps
%       - z: r * p matrix of source maps, z scored by component
    
% The user must specify at least
% - jICA
%   - orig: n * p concatenated features matrix
%   - clean
%     - x: n * b design matrix for cleansing
%     - CovInt: vector of covariates of interest which will be added back in after cleansing
%     - Note: If clean does not exist, it will be created for you in such a way that cleansing has no effect
%   - pca
%     - dim: target dimensionality of data
%   - flip
%     - 0 turns of flipping
%     - ID the covariate to flip component expression, be sure to account for the intercept!
%   - split
%     - splitpts: vector of start values for each modality (1 if only 1 modality)
    
            
    jica = setdefaults(jica);
    
    jica = cleanse(jica);
    
    jica = reduce(jica);
    
    jica = ica(jica);
    
    jica = fit(jica);
    
    if numel(jica.split.splitpts) > 1
        jica = split(jica);
    end

end


function [jica] = setdefaults(jica)

    if ~isfield(jica,'clean')
        jica.clean.x = repmat(1,size(jica.orig,1),1);
        jica.clean.CovInt = 1;
    end

    if ~isfield(jica,'pca') || ~isfield(jica.pca,'dim')
        jica.pca.dim = 15;
    end
    
    if ~isfield(jica,'flip')
        jica.flip = 0;
    end
    
    if ~isfield(jica,'split') || ~isfield(jica.split,'splitpts')
        jica.split.splitpts = 1;
    end
end

function [jica] = cleanse(jica);
    
% add intercept if not already there
    if ~all(jica.clean.x(:,1)==1) 
        jica.clean.x = [repmat(1,size(jica.clean.x,1),1) jica.clean.x];
    end
    
    vals.res = 1;
    vals.x = 1;
    stat = mc_CovariateCorrectionFast(jica.orig,jica.clean.x,1,vals);
    
    clean_design = repmat(0,size(jica.clean.x)); % create cleaning matrix
    clean_design(:,1) = 1; % add intercept to cleaning matrix
    clean_design(:,jica.clean.CovInt) = stat.x(:,jica.clean.CovInt);
    
    jica.clean.data = clean_design * stat.b + stat.res;
end

function [jica] = reduce(jica)
    
    comp_est = jica.pca.dim - 1;

    [v d] = eig(cov(jica.clean.data')); % do eigenvector / eigenvalue decomposition of covariance matrix of transposed data

    eigval = flipud(diag(d));

    v = v(:,(end-comp_est):end); % grab the last 20 eigen vectors (just guessed at it here
    d = d((end-comp_est):end,(end-comp_est):end);

    jica.pca.white = sqrtm(d) \ v'; % Use gaussian elimination approach to solve the equations
    jica.pca.dewhite = v * sqrtm(d);
    jica.pca.red = (jica.clean.data' * jica.pca.white')';
end

function [jica] = ica(jica)
    
    [jica.ica.S jica.ica.rawmix w] = fastica(jica.pca.red);
    
    jica.ica.mix = jica.pca.dewhite * jica.ica.rawmix;
end

function [jica] = fit(jica)
    
    vals.p = 1;
    
    jica.stat = mc_CovariateCorrectionFast(jica.ica.mix, jica.clean.x, 1, vals);
    
    if jica.flip ~= 0 % sign flipping if necessary
        fxsign = sign(jica.stat.b(jica.flip,:)); % id sign of beta for fx of interest
        
        jica.ica.S = bsxfun(@times,jica.ica.S,fxsign'); % flip component maps as necessary
        
        jica.ica.mix = bsxfun(@times,jica.ica.mix,fxsign); % flip mixing matrix as necessary
        
        jica.stat = mc_CovariateCorrectionFast(jica.ica.mix,jica.clean.x,1,vals); % refit stats model with flipped mix
    end
    
    [jica.stat.fdr.h critp jica.stat.fdr.q] = fdr_bh(jica.stat.p,.05,'pdep','no',1);
    
end
    
function [jica] = split(jica)
    
    
    
    for i = 1:numel(jica.split.splitpts)
        
        start = jica.split.splitpts(i);

        if i < numel(jica.split.splitpts)
            stop = jica.split.splitpts(i+1) - 1;
        else
            stop = size(jica.ica.S,2);
        end
    
        jica.split.maps(i).raw = jica.ica.S(:,start:stop);
        jica.split.maps(i).z = zscore(jica.split.maps(i).raw')';
    end
    
end
    
