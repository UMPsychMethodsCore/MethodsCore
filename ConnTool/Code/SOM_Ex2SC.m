% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2007
%
% A routine to remap the indices of the voxel solutions from
% the exemplars in the full SOM to the exemplars of the 
% super clustered SOM
%
% IDX = SOM_Ex2SC(SOMResults.IDX,SCResults.IDX)
%
% Input  :
%
%   SOMResults.IDX   - the indices pointing to the exemplars
%   SCResults.IDX    - indices of exemplars to super-cluster
%                      exemplars.
%
% Output :
%
%   IDX              - pointers to super-cluster exemplars for
%                      for each voxel.
%
%
% You would use this for datamining based on ROI's. Operationally,
% you would troll the data space looking for the super-cluster
% that occupied your ROI, then you would display that super-cluster
% exemplar cost-function, or rho-value or z-map.
%
%   See SOM_CostFunction
%       SOM_Pearson
%	SOM_Rho2Z
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function IDX = SOM_Ex2SC(IDX1,IDX2)

IDX = [];

%
% Make sure things are in range.
%

nExemplars = size(IDX2);

maxIDX = max(IDX1);

if maxIDX > nExemplars
  fprintf('The exemplar indices are bigger than the number of exemplars in the super-clusters.\n');
  return
end

%
% Now do the remapping.
%

IDX = 0*IDX1;

for ii = 1:length(IDX2)
  IDX(find(IDX1==ii)) = IDX2(ii);
end

return

%
% All done.
%