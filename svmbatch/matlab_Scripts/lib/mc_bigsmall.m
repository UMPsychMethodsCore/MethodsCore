function [ vector keepID pruneID] = mc_bigsmall( vector, howmany, bigsmall )
% MC_BESTWORST_CENSOR Given an unsorted vector, this function will find the
% N biggest or smallest elements, and zero out the rest.
%   Input
%       vector      -   This should be an unsorted row vector
%       howmany     -   How many features of the vector you want retained
%       bigsmall    -   0 - Retain the smallest features
%                       1 - Retain the biggest features
%                       2 - Retain the smallest abs-valued features.
%                       3 - Retain the largest abs-valued features
%                   IMPORT NOTE - If you set bigsmall to 2 or 3, sorting
%                   will happen on the absolute-valued features, but the
%                   vector that is returned will have its original sign. It
%                   does this by first storing the sign of the input
%                   vector, calling abs on it, doing the sort, and then
%                   reapplying the stored sign.
%   Output
%       vector      -   This is the original vector, with all but the
%                       requested elements zeroed out.
%       keepID      -   These are the indices into the original vector of
%                       what was retained.
%       pruneID     -   These are the indices into the original vector of
%                       what was zeroed/censored.

if bigsmall==2 || bigsmall==3
    vectorsign=sign(vector);
    vector=abs(vector);
    if bigsmall==2, bigsmall=0; end
    if bigsmall==3, bigsmall=1; end
end

[d pruneID] = sort(vector);



if bigsmall==0 
    keepID=pruneID(1:howmany);
    pruneID=pruneID((howmany+1):end);
elseif bigsmall==1
    keepID=pruneID((end-(howmany-1)):end);
    pruneID=pruneID(1:(end-howmany));
end

vector(pruneID) = 0;

if exist('vectorsign','var')
    vector = vector .* vectorsign;
end