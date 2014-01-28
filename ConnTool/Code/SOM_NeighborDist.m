% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2005
%
% Calculate the distance between elements off the grid
% given the lattice spacing.
%
% function results = SOM_NeighborDist(nGrid)
%

function results = SOM_NeighborDist(nGrid)

distMat = zeros(nGrid,nGrid,nGrid*nGrid);

xs = reshape((1:nGrid)'*ones(1,nGrid),[nGrid*nGrid 1]);
ys = reshape(ones(nGrid,1)*(1:nGrid),[nGrid*nGrid 1]);

for iGrid = 1:nGrid*nGrid
  distMat(:,:,iGrid) = reshape(sqrt((xs-xs(iGrid)).^2 + ...
                                    (ys-ys(iGrid)).^2),...
                               [nGrid nGrid]);
end

% Return the full 4-D matrix.

results = reshape(distMat,[nGrid nGrid nGrid nGrid]);;

return

%
% All done
%
