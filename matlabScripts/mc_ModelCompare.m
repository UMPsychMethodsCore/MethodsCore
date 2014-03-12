function [ stat ] = mc_ModelCompare(Y,fdesign,rdesign,raw,thresh)
% This script will compute F statistics based on a comparison of two models.

% Y - nExample-se x nFeatures matrix of observations
% f.design - Full Design matrix (nExamples x nPredictors )

f.design = fdesign;
r.design = rdesign;

f.nvar = size(f.design,2);
r.nvar = size(r.design,2);
n = size(Y,1);

vals.res=1;

f.stat = mc_CovariateCorrectionFast(Y,f.design,raw,vals);
r.stat = mc_CovariateCorrectionFast(Y,r.design,raw,vals);

f.stat.sse  = sum(f.stat.res.^2,1);
r.stat.sse  = sum(r.stat.res.^2,1);

fstats =  ( (r.stat.sse - f.stat.sse) ./ (f.nvar - r.nvar) ) ... % numerator
           ./...
           ( f.stat.sse ./ (n - r.nvar) ); % denominator


df1 = f.nvar - r.nvar;
df2 = n - size(f.design,2);

if exist('thresh','var')
    fcrit = finv(1-thresh,df1,df2);
    stat.fsig = fstats > fcrit;
else
    stat.fpval = 1 - fcdf(fstats,df1,df2);
end
