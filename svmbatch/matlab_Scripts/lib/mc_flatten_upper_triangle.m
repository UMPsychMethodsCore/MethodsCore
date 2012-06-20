function [ flatmat ] = mc_flatten_upper_triangle( squaremat , censor)
% Flatten Upper Trianngle - A function to extract, as a vector, the upper
% triangular elements of a square matrix. At present, if any elements in
% the upper triangle are inf, this will lead to an error.

% Check if any elements are inf.

if any(isnan(squaremat(:)))
    % raise error message and abort. Add this functionality once mc_error
    % is written.
end

% Protect any zero-valued elements by changing to inf.

squaremat_protected = squaremat;
squaremat_protected(squaremat_protected==0) = Inf;

% Zero out all elements except upper triangle, then reshape to flat vector
flatmat_full = reshape(triu(squaremat_protected,1),1,size(squaremat_protected(:),1));

% Drop all zero elements
flatmat = flatmat_full(flatmat_full~=0);

% Restore any zeros in original square matrix
flatmat(isinf(flatmat)) = 0;

end