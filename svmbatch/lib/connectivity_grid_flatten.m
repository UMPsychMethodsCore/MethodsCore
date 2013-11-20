function [ output_args ] = connectivity_grid_flatten( conmat , cleanconMat)
%CONNECTIVITY_GRID_FLATTEN Summary of this function goes here
%   [ output_args ] = connectivity_grid_flatten( conmat , filename,
%   exampletype)
%       mode    -   1: write out a file, with bad elements censored
%                   2: return a matrix with bad elements zeroed


flatmat = flatten_diagonal (conmat);
cleanconMat_flat = flatten_diagonal (cleanconMat);

flatmat(~logical(cleanconMat_flat))=0;
output_args=flatmat;



    function [flatmat] = flatten_diagonal (inmat)
        conmat_protected = inmat; 
        conmat_protected(conmat_protected==0) = Inf;
        flatmat_full = reshape(triu(conmat_protected,1),1,size(conmat_protected(:),1));
        flatmat = flatmat_full(flatmat_full~=0);
        flatmat(isinf(flatmat)) = 0;
    end

end