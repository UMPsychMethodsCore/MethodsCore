% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2005-2007
%
%
% function results = SOM_CostFunction(slot,theSOM)
%
% IT IS ASSUMED THAT THE DATA AND SOM ARE UNIT NORMED
%
% global SOMMem
%    SOMMem.theData = theData(nSpace,nTime);
%
% theSOM  = theSOM(nTime,nSOM);
%
% idx     = array of indices for best matching SOM vector.
% wts     = cos(angle) or euclidean distance.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function SOM_CostFunction(slot,theSOM,CF);

global SOMMem

switch CF
 case 0
  SOMMem{slot}.dataBySOM = SOMMem{slot}.theData*theSOM;
 case 1
  SOMMem{slot}.dataBySOM = 2*(1.-SOMMem{slot}.theData*theSOM);
 case 2
  SOMMem{slot}.dataBySOM = 4*(1.-SOMMem{slot}.theData*theSOM).^2;
 case 3
  fprintf('Too slow to do mutual information at the moment !\n');
  SOMMem{slot}.dataBySOM = SOM_CostFunctionMI(SOMMem{slot}.theData,theSOM);
  return
end

% Free up memory - hopefully.

clear theSOM

return

%
% All done.
%
