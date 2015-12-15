function [ out ] = mc_twinstack (in)
%MC_TWINSTACK Take a 2D matrix and make it 3D with twin structure
%
% If you have loaded a file using mc_load_connectomes_paired with
% matrixtype = 'nodiag', you will have a 2D matrix. Here, rows will
% index subjects, and columns will index features. However, in this
% case each of the rows holds the full representation of a flattened
% 2D matrix. Moreover, there's an embedded paired structure
% present. For all of the features that were not on the diagonal of
% the original 2D matrices, they have a corresponding twin. For
% example, the point (1,3) will correspond to the point at (3,1). This
% function will restructure this data into a 3D array. In this new
% array, rows will still index subjects, and columns will index
% features. However, there will be fewer columns, as the third
% dimension will now index twin pairings. The first level in the third
% dimension will have upper diagonal elements, and the second level
% will hold the corresponding values from the lower diagonal
% elements. Elements that were on the diagonal will be dropped. This
% kind of matrix representation is useful for all sort of competitive
% twin approaches

nrow = size(in,1);
ncol = size(in,2);

for iR = 1:nrow
    up(iR,:) = mc_flatten_upper_triangle(reshape(in(iR,:),sqrt(ncol),sqrt(ncol)));
    dn(iR,:) = mc_flatten_upper_triangle(reshape(in(iR,:),sqrt(ncol),sqrt(ncol))');
    
end

out(:,:,1) = up;
out(:,:,2) = dn;
