function [ stat ] = mc_CovariateCorrectionFast( Y, X, raw, vals)
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
%       vals-   OPTIONAL - Use this to indicate which statistical output you want. In many cases,
%                       disabling some values can significantly increase the speed and decrease
%                       the memory overhead of this function. Submit this a struct, and set
%                       appropriately named fields to TRUE. Here are the fields it understands
%                               t       -       Return t values (will turn on res)
%                               p       -       Return p values (will turn on t)
%                               int     -       Return intercepts
%                               pred    -       Return predicted values
%                               res     -       Return residuals (will turn on pred)
%                               cor     -       Return corrected values (will turn on int and res)
%                               x       -       Return the design matrix X (after centering, etc)    
%                               f       -       Perform an f-test on reduced models. See below for details    
%                       If you set the value to true, you will get a corresponding field in the stat output. For example...
%                               vals.t = true;
%                               vals.pred = true;
%                       will yield t and pred fields of the stat output
%                       NOTE - You will always get a b field of betas in your results    
%
%
%                       F Tests
%                               set f.test = 1;    
%                               set f.submodel = [x y z]; to the indices of the items
%                                       you want to drop in your "reduced" model    
% 
%   RESULTS
%       A single struct will be returned. It can have the following fields
%               b       -       nPredicted x nFeatures matrix of betas values from regression
%               t       -       t values corresponding to each b
%               p       -       p values corresponding to each t
%               int     -       nExamples x nFeatures matrix of intercept values from regression
%               pred    -       nExamples x nFeatures matrix of predicted values from regression
%               res     -       nExamples x nFeatures matrix of residuals from regression
%               cor     -       nExamples x nFeatures matrix of corrected observations. Calculated as int + res

% 
% 
% This program will assume the same design matrix for all of your features,
% thus enabling much more rapid computation of the residuals.



    if(~exist('raw','var') )
        raw=0;
    end
    
    if exist('vals','var')
        vals = vals_parser(vals); % set any upstream options
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


    stat.b =   pinv(X)*Y;

    if exist('vals','var') && isfield(vals,'pred') && vals.pred % calc predicted values
        stat.pred = X * stat.b;
    end

    if exist('vals','var') && isfield(vals,'res') && vals.res % calc residuals
        stat.res = Y - stat.pred;
    end

    if exist('vals','var') && isfield(vals,'int') && vals.int % calc intercepts
        stat.int = X(:,1)*stat.b(1,:);
    end

    if exist('vals','var') && isfield(vals,'cor') && vals.cor % calc corrected values
        stat.cor = stat.int + stat.res;
    end

    if exist('vals','var') && isfield(vals,'t') && vals.t
        C = pinv(X'*X); % X'*X is the covariance matrix of X. The inverse is valuable for denominator or SE(beta hat)

        xvar_inv = diag(C);
        xvar_inv = repmat(xvar_inv,1,nFeat);


        sse = sum(stat.res.^2,1) ./ (nSub - nPred);
        sse = repmat(sse,nPred,1);

        bSE = sqrt(xvar_inv .* sse);

        stat.t = stat.b ./ bSE;
        stat.t = mc_connectome_clean(stat.t,0,0); % set bad features to all 0's
    end

    if exist('vals','var') && isfield(vals,'p') && vals.p % calc p values
        stat.p = 2 * (1 - tcdf(abs(stat.t),size(Y,1) - size(stat.b,1)));
        stat.p = mc_connectome_clean(stat.p,0,1); % clean out all of the bad values and set to 1 (no sig)
    end
    
    if exist('vals','var') && isfield(vals,'x') && vals.x % return design matrix
        stat.x = X;
    end
    
    if exist('vals','var') && isfield(vals,'f') && vals.f.test == 1;
        stat = CalcFStat(Y,X,raw,vals,stat);

    end
end

    function [ vals ] = vals_parser(vals) % turn on upstream vals
    % requests
        if isfield(vals,'f') && vals.f.test;
            vals.res = 1;
        end
        if isfield(vals,'p') && vals.p % if p values are requested, turn on t
            vals.t = true;
        end
        
        if isfield(vals,'t') && vals.t % if t values are requested, turn on res
            vals.res = true;
        end

        if isfield(vals,'cor') && vals.cor % if cor requested, turn on int and res
            vals.int = true;
            vals.res = true;
        end
        
        if isfield(vals,'res') && vals.res % if residuals requested, turn on pred
            vals.pred = true;
        end
    end

    function [stat] = CalcFStat(Y,X,raw,vals,stat);
    % calculate an F statistic for a nested model following this
    % F =  [ (RSS_r - RSS_f) / (p_f - p_r) ] / [ (RSS_f) / (n - p_f) ] ;
    %where

    % RSS_f  = residual sum of squares from full model
    % RSS_r  = residual sum of squares from reduced model
    % p_f    = number of predictors for full model
    % p_r    = number of predictors for reduced model
    % n      = number of subjects

    % calculate the reduced model statistics
        stat_f = stat;

    % build reduced design matrix
        X_r = X;
        X_r(:,vals.f.submodel) = [];

        vals_r = rmfield(vals,'f'); % prevent it from getting too recursive    

        stat_r = mc_CovariateCorrectionFast(Y,X_r,raw,vals_r); % fit the reduced model

        RSS_f = sum(stat_f.res.^2);
        RSS_r = sum(stat_r.res.^2);

        p_f = size(X,2);
        p_r = size(X_r,2);

        n = size(X,1);

        Fval = ( (RSS_r - RSS_f) ./ (p_f - p_r) )  ./ ( (RSS_f) ./ (n - p_f) );

        F_df = [p_f - p_r; n - p_f];
        
        stat.f.fval = Fval;
        stat.f.df = F_df;

    end
