function [ corrected, residuals, betas, intercepts ] = mc_CovariateCorrection( Y, X )
%MC_COVARIATECORRECTION Correction for a series of covariates using
%multiple regression
% 
%   FORMAT [residuals] = mc_CovariateCorrection( Y, X)
%       Y   -   nExamples x nFeatures matrix of observations
%       X   -   nExamples x nPredictors design matrix
% 
% This program will assume the same design matrix for all of your features,
% thus enabling much more rapid computation of the residuals.
% 
% We will also mean center all of your covariates so that your intercepts
% are interpretable as the original means.
% 
% NOTE  -   This script will prepend a column of ones to your X matrix to
% model an intercept, so you do not need to include it.


% Mean center all your covariates
X = mc_SweepMean(X);

% Prepend a constant to the predictor matrix
X = horzcat(ones(size(X,1),1),X);

betas =   pinv(X)*Y;

residuals = Y - X*betas;

intercepts = X(:,1)*betas(1,:);

corrected = intercepts + residuals;

 


end


