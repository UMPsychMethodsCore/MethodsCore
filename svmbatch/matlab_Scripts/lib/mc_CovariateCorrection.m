function [ residuals, betas ] = mc_CovariateCorrection( Y, X )
%MC_COVARIATECORRECTION Correction for a series of covariates using
%multiple regression
% 
%   FORMAT [residuals] = mc_CovariateCorrection( Y, X)
%       Y   -   nFeatures x nExamples matrix of observations
%       X   -   nExamples x nPredictors design matrix
% 
% This program will assume the same design matrix for all of your features,
% thus enabling much more rapid computation of the residuals.


% Prepend a constant to the predictor matrix
X = horzcat(ones(size(X,1),1),X);

betas = pinv((X'*X))*X'*Y;

residuals = Y - X*betas;



 


end


