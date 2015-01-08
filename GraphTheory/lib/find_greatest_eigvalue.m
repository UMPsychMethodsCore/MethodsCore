function [ v,rho ] = find_greatest_eigvalue( mtrx,k )
% FIND_GREATEST_EIGVALUE
% Use Power Method to calculate the largest eigenvalue of a matrix
%
% INPUT
%            mtrx       ---     A nxn square matrix
%               k       ---     Iteration time
% OUTPUT
%            rho        ---     The largest eigenvalue of the input matrix
%              v        ---     The corresponding eigenvector (nx1). 
% Yu Fang 2014/03

if size(mtrx,1)~=size(mtrx,2)
    warning('Not square matrix, no eigenvalue calculated')
    return
end

if ~exist('k','var') || (k<=0)
    k=100;
else
    k = ceil(k);
end

n=length(mtrx);
v=ones(n,1);
for i=1:k
    v=mtrx*v;
    v=v/norm(v);
end
rho=v'*mtrx*v;

end

