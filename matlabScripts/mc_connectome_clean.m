function [ data_clean, censor ] = mc_connectome_clean( data_in ,cleanzeros,badval)
%MC_CONNECTOME_CLEAN This routine will make sure all of your loaded featres
%are valid. This will work for both 3D (multi condition, paired data) or 2D
%(multiclass) connectome cases.
% 
% If it encounters an NaN, Inf, or 0 in any of your features, it will
% censor that feature for all conditions (if there are multiple), and for
% all subjects/examples.
% 
%   INPUT
%       data_in     -   Should either be a 2D or 3D object returned by call
%                       to mc_load_connectomes_{unpaired,paired},
%                       respectively
%
%       cleanzeros  -   Set me to true if you want me to treat zeros as "bad" data.
%                       If set to true, I will return 0's in place of bad data.
%                       If set to false, I will return NaNs in place of bad data
%                       Defaults to true
%
%       badval      -   What should I replace "bad" values with? Default is 0.
%                       If cleanzeros is false, this will default to NaN.
%                       Probably a good idea to manually set this, though
% 
%   OUTPUT
%       data_clean  -   A censored version of data_in. Should have the same
%                       structure
%       censor      -   A sparse 1 * nFeat matrix, showing what was
%                       censored. 1 indicates positive censorship.

%% Parse optional arguments

if ~exist('cleanzeros','var')
    cleanzeros=true;
end

if ~exist('badval','var') % if badval is undefined, set default
                          % depending on clean zeros
    if ~cleanzeros % if cleanzeros set to false, set badval to NaN
        badval = NaN;
    elseif cleanzeros % if cleanzeros set to true, set badval to 0
        badval=0;
    end
end

%% Do work

switch ndims(data_in)
    
    case 2 % 2D data_in
        censor_nan=sparse(any(isnan(data_in))); % ID any NaN's
        censor_inf=sparse(any(isinf(data_in))); % ID any Inf's
        censor_zed=sparse(any(data_in==0)); % ID any zero values
        if exist('cleanzeros','var') && ~cleanzeros
            censor=sparse(any([censor_nan; censor_inf])); % find union of DQ's
        else
            censor=sparse(any([censor_nan; censor_inf; censor_zed])); % find union of DQ's            
        end
        
        data_clean=data_in;

        data_clean(:,logical(censor)) = badval;


    case 3  % 3D data_in
        censor_nan=sparse(any(any(isnan(data_in)),3)); % ID any NaN's
        censor_inf=sparse(any(any(isinf(data_in)),3)); % ID any Inf's
        censor_zed=sparse(any(any(data_in==0),3)); % ID any zero values

        if exist('cleanzeros','var') && ~cleanzeros
            censor=sparse(any([censor_nan; censor_inf])); % find union of DQ's
        else
            censor=sparse(any([censor_nan; censor_inf; censor_zed])); % find union of DQ's
        end
        
        data_clean=data_in;
        data_clean(:,logical(censor),:)=badval; % replace bad data 

end

