% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2005
% Ann Arbor MI.
%
% function results = SOM_ModBasis(pertVect,theSOM,indices,weights)
%
% pertVect       = perturbing vector;
% nullSOM        = a zeroed SOM (just need it for the size).
% SOMNeighborMap = array of indices of iSOM and distance.
% iteration      = current iteration of the map.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_ModBasis(pertVect,results,SOMNeightborMap)
if length(pertVect) ~= size(results,1)
    fprintf('Dimensions don''t match for SOM_ModBasis\n');
    return
end

wts = reshape(SOMNeightborMap,[1 numel(SOMNeightborMap)]);
results = pertVect*wts;
return

%
% All done.
%

