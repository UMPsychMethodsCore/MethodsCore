function [ discrimpower ] = mc_prune_discrim_power( discrimpower, tiebreaker)
%USAGE:
%[discrimpower] = mc_prune_discrim_power(discrimpower,[tiebreaker])
%   This function is used to ensure that only the stronger edge direction
%   of any pair of nodes is kept to prevent duplicate edges from both being
%   selected as features.  It assumes the data comes from a square matrix
%   that has been reshaped into a single row vector.
%
%   INPUT
%       discrimpower    -   1 x nFeatures matrix of discrim power
%       tiebreaker      -   optional string (defaults to 'rand')
%           'upper'     -   always keep the top value (above the diagonal)
%           'lower'     -   always keep the bottom value
%           'rand'      -   random select top or bottom value
%
%   OUTPUT
%       discrimpower    -   1 * nFeatures matrix of discrim power with the
%                           less disriminating of each pair zeroed out
%
% NOTE - Discrim power is always expressed in terms of greater value =
% greater discrim power. For results that return p-values, we will take the
% complement, so a p of .05 will become .95.
%

if (~exist('tiebreaker','var') | isempty(tiebreaker))
    tiebreaker = 'rand';
end

nROIs = sqrt(size(discrimpower,2));

discrim_square = reshape(discrimpower,nROIs,nROIs);

discrim_upper = triu(discrim_square,1);
discrim_lower = triu(discrim_square',1);

discrim_upper(discrim_upper==0) = Inf;
discrim_lower(discrim_lower==0) = Inf;

diff = discrim_upper - discrim_lower;

mask_upper = zeros(size(discrim_upper));
mask_lower = zeros(size(discrim_lower));

%loop over 0 entries in diff and apply 

switch(tiebreaker)
    case 'rand'
        diff(diff==0) = diff(diff==0) + (rand(size(find(diff==0),1),1)*2-1);
    case 'upper'
        diff(diff==0) = 1;
    case 'lower'
        diff(diff==0) = -1;
    otherwise
        mc_Error('Unrecognized option for input variable tiebreaker.');
end

mask_upper(diff>0) = 1;
mask_lower(diff<0) = 1;

discrim_upper = discrim_upper .* mask_upper;
discrim_lower = discrim_lower .* mask_lower;

discrim_square = triu(tril(discrim_square));
discrim_square = discrim_square + triu(discrim_upper,1);
discrim_square = discrim_square + tril(discrim_lower',-1);

discrimpower = reshape(discrim_square,1,prod(size(discrim_square)));


