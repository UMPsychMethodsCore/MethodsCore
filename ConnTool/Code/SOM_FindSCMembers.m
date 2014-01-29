% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2007
%
%
% A routine to return indices of SelfOMap exemplars
% that belong to the same supercluster as the passed index.
%
% function [results scnum] = SOM_FindSCMembers(ExemplarIDX,SCIDX)
%
% Input : 
%
%     ExemplarIDX = Index into SelfOMap (0<#<=nSom)
%
%     SCIDX       = Index map of the supercluster membership.
%
% Output:
% 
%     results     = list of exemplars that belong to same supercluster
%     scnum       = supercluster number.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function [results scnum] = SOM_FindSCMembers(ExemplarIDX,SCIDX)

if ExemplarIDX < 1 || ExemplarIDX > length(SCIDX)
  fprintf('ExemplarIDX is out of range.\n');
  results = [];
  return
end

results = find(SCIDX==SCIDX(ExemplarIDX));

scnum = SCIDX(ExemplarIDX);

return

%
% All done.
%
