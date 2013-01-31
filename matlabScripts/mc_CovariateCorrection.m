function [ corrected, residuals, betas, intercepts, tvals, pvals ] = mc_CovariateCorrection( Y, X, raw)
%MC_COVARIATECORRECTION Correction for a series of covariates using
%multiple regression
% 
%   FORMAT [residuals] = mc_CovariateCorrection( Y, X)
%       Y   -   nExamples x nFeatures matrix of observations
%       X   -   nExamples x nPredictors design matrix
%       raw -   If set to 1, it will not mean center and it will not add an intercept term    
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

if(~exist(raw,'var') 
    raw=0
end

% Mean center all your covariates
if(raw~=1)
    X = mc_SweepMean(X);
end

% Prepend a constant to the predictor matrix
if(raw!=1)
    X = horzcat(ones(size(X,1),1),X);
end

betas =   pinv(X)*Y;

residuals = Y - X*betas;

intercepts = X(:,1)*betas(1,:);

corrected = intercepts + residuals;

C = pinv(X'*X);

for iC = 1 : size(X,2)
    tvals(iC,:) = betas (iC,:) ./ sqrt(C(iC,iC) * sum(residuals.^2,1)/(size(Y,1) - (size(betas,1))));
end

pvals = 2 * (1 - tcdf(abs(tvals),size(Y,1) - size(betas,1)));


end


