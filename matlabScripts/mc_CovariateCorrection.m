function [ corrected, residuals, betas, intercepts, tvals, pvals, predicted ] = mc_CovariateCorrection( Y, X, raw, tvalcalc)
%MC_COVARIATECORRECTION Correction for a series of covariates using
%multiple regression
% 
%   FORMAT [residuals] = mc_CovariateCorrection( Y, X, raw, tvalcalc)
%       Y   -   nExamples x nFeatures matrix of observations
%       X   -   nExamples x nPredictors design matrix
%       raw -   Use this to disable some of the automatic features of mc_CovariateCorrection
%                       0 - Automatically mean center X column-wise and then add intercept
%                       1 - Automatically mean center X, do not add intercept
%                               NOTE - This will mean center columns 2:end, and leave alone column 1 assuming it is intercept    
%                       2 - Automatically add intercept, do not mean center
%                       3 - Do not add intercept or mean center    
%       tvalcalc - which p value and t value you are intersted in    
% 
%   RESULTS
%       corrected   -   nExample x nFeatures matrix of corrected
%                       observations. Calculated as intercepts + residuals
%       residuals   -   nExamples x nFeatures matrix of residuals from
%                       regression
%       betas       -   nPredictors x nFeatures matrix of beta values from
%                       regression
%       intercepts  -   nExamples x nFeatures matrix of intercept values
%                       from regression
%       tvals       -   T values corresponding to each beta
%       pvals       -   P Values corresponding to each beta    
%       predicted   -   Predicted values based on model    
% 
% 
% This program will assume the same design matrix for all of your features,
% thus enabling much more rapid computation of the residuals.
% 
% We will also mean center all of your covariates so that your intercepts
% are interpretable as the original means.
% 
% NOTE  -   This script will prepend a column of ones to your X matrix to
% model an intercept, so you do not need to include it.

if(~exist('raw','var') )
    raw=0;
end

% Mean center all your covariates
if(raw==0) % if in full helper mode
    X = mc_SweepMean(X); % mean center the whole design matrix
elseif (raw==1) % 
    X(:,2:end) = mc_SweepMean(X(:,2:end)); % mean center, but leave first column (intercept)
end

% Prepend a constant to the predictor matrix
if(raw==0 | raw==2)
    X = horzcat(ones(size(X,1),1),X);
end

nFeat = size(Y,2);
nSub = size(Y,1);
nPred = size(X,2);


stat.betas =   pinv(X)*Y;

stat.residuals = Y - X*stat.betas;

stat.intercepts = X(:,1)*stat.betas(1,:);

stat.corrected = stat.intercepts + stat.residuals;

% X'*X is the covariance matrix of X. The inverse is valuable for denominator or SE(beta hat)
C = pinv(X'*X);

xvar_inv = diag(C);
xvar_inv = repmat(xvar_inv,1,nFeat);


sse = sum(stat.residuals.^2,1) ./ (nSub - nPred);
sse = repmat(sse,nPred,1);

bSE = sqrt(xvar_inv .* sse);

stat.tvals = stat.betas ./ bSE;
stat.pvals = 2 * (1 - tcdf(abs(stat.tvals),size(Y,1) - size(stat.betas,1)));


stat.predicted = X * stat.betas;

end


