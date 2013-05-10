% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2010
%
% A function to take the Time x Space Exemplar map
% and return as a xSpace x ySpace x Time Exemplar map
%
%
% function OutMap = SOM_Grid4SC(InSelfOMap,xGrid,yGrid)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function OutMap = SOM_Grid4SC(InSelfOMap,xGrid,yGrid)

nTime = size(InSelfOMap,1);

nSpace = xGrid*yGrid;

if nSpace ~= size(InSelfOMap,2)
  fprintf('Error, size mismatch. InSelfOMap : %d x %d\n',size(InSelfOMap));
  OutMap = [];
  return
end

OutMap = reshape(InSelfOMap,[nTime xGrid yGrid]);

OutMap = permute(OutMap,[2 3 1]);

%
% All done.
%