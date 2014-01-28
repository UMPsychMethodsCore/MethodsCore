% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2006
%
%
% function results = SOM_GridSC(SOMSCResults)
%
% Input:
%
%      SOMSCResults - results structure returned by SOM_SuperClsuterEasy
%
% Output:
%
%      results      - a matrix showing the supercluster membership for the
%                     SOM.
%
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - -


function results = SOM_GridSC(SOMSCResults)

results = [];

nGrid = floor(sqrt(length(SOMSCResults.IDX)));

if nGrid ~= sqrt(length(SOMSCResults.IDX))
    fprintf('Something wrong with nGrid.\n');
    return
end

results = zeros(nGrid,nGrid);

for iIDX = 1:max(SOMSCResults.IDX)
    results(find(SOMSCResults.IDX == iIDX)) = iIDX;
end

return

% 
% All done
%
