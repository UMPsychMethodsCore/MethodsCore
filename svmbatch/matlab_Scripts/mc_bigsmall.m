function [ vector keepID pruneID] = mc_bigsmall( vector, howmany, bigsmall )
% MC_BESTWORST_CENSOR Given an unsorted vector, this function will find the
% N biggest or smallest elements, and zero out the rest.
%   Input
%       vector      -   This should be an unsorted row vector
%       howmany     -   How many features of the vector you want retained
%       bigsmall    -   Put 1 if you want to retain the biggest features.
%                       Put 0 if you want to retain the smallest features.
%   Output
%       vector      -   This is the original vector, with all but the
%                       requested elements zeroed out.
%       keepID      -   These are the indices into the original vector of
%                       what was retained.
%       pruneID     -   These are the indices into the original vector of
%                       what was zeroed/censored.


[d pruneID] = sort(vector);


if bigsmall==0 
    keepID=pruneID(1:howmany);
    pruneID=pruneID((howmany+1):end);
elseif bigsmall==1
    keepID=pruneID((end-(howmany-1)):end);
    pruneID=pruneID(1:(end-howmany));
end

vector(pruneID) = 0;
