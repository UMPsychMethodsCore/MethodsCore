% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2013
%
%
% A routine to calculate the Shannon
% entropy
%
% Input
%
%     theData     = theData(space,time) (this is the 
%                   standard format being used in this SOM
%                   implementation).
%
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_ShannonEntropy(theData)

results = -1;
 
results = zeros(size(theData,1),1);

for iV = 1:size(theData,1)
  results(iV) = wentropy(theData(iV,:),'shannon');
end

return
