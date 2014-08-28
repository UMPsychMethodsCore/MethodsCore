% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2007
%
% A routine to build a map out of a SOM element. 
% 
% You need to pass the cost function and which element
%
% global SOMMem
%
%      SOMMem{slot}.theData(nVoxel,nTime);
%      SelfOMap(nTime,nSOM);
%   
%      SOMMem{1}.maskInfo.hdr is necessary
%   
% This is a kludge at the moment.
%
% function CFMap = SOM_BuildMap(costFunction,whichElement)
%
% Utilized SOMMem and uses memory slot #1
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function CFMap = SOM_BuildMap(costFunction,whichElement)

global SOMMem

CFMap = zeros(SOMMem{1}.maskInfo.size);

CFMap(SOMMem{1}.maskInfo.iMask) = costFunction(:,whichElement);

return

%
% All done
%
