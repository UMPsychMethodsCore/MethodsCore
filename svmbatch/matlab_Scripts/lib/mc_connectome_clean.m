function [ data_clean, censor ] = mc_connectome_clean( data_in )
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
%   OUTPUT
%       data_clean  -   A censored version of data_in. Should have the same
%                       structure
%       censor      -   A sparse 1 * nFeat matrix, showing what was
%                       censored. 1 indicates positive censorship.

switch ndims(data_in)
    
    case 2 % 2D data_in
        censor_nan=sparse(any(isnan(data_in))); % ID any NaN's
        censor_inf=sparse(any(isinf(data_in))); % ID any Inf's
        censor_zed=sparse(any(data_in==0)); % ID any zero values
        
        censor=sparse(any([censor_nan; censor_inf; censor_zed])); % find union of DQ's
        
        data_clean(:,logical(censor))=0; % zero out all censored elements
        
    case 3  % 3D data_in
        censor_nan=sparse(any(any(isnan(data_in)),3)); % ID any NaN's
        censor_inf=sparse(any(any(isinf(data_in)),3)); % ID any Inf's
        censor_zed=sparse(any(any(data_in==0),3)); % ID any zero values
        
        censor=sparse(any([censor_nan; censor_inf; censor_zed])); % find union of DQ's
        
        data_clean(:,logical(censor),:)=0; % zero out all censored elements at all conditions
        
end

